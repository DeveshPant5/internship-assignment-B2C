import uuid
from datetime import datetime, timezone
from fastapi import FastAPI, HTTPException, status, Query
from fastapi.middleware.cors import CORSMiddleware
from database import db, get_next_id
from models import (
    CartAddRequest, CartRemoveRequest, CartItemResponse,
    OrderCreateRequest, OrderResponse, OrderItemResponse,
)

app = FastAPI(title="Cart & Order Service", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    return {"service": "Cart & Order Service", "status": "running"}


@app.get("/health")
def health():
    return {"status": "healthy", "service": "cart_order_service"}


@app.post("/cart/add", response_model=CartItemResponse)
async def add_to_cart(request: CartAddRequest):
    existing = await db.cart_items.find_one(
        {"user_id": request.user_id, "product_id": request.product_id}
    )

    if existing:
        update_fields = {"$inc": {"quantity": request.quantity}}
        set_fields = {}
        if request.product_name:
            set_fields["product_name"] = request.product_name
        if request.product_price:
            set_fields["product_price"] = request.product_price
        if set_fields:
            update_fields["$set"] = set_fields
        await db.cart_items.update_one(
            {"_id": existing["_id"]}, update_fields
        )
        updated = await db.cart_items.find_one({"_id": existing["_id"]})
        return CartItemResponse(
            id=updated["id"],
            user_id=updated["user_id"],
            product_id=updated["product_id"],
            product_name=updated.get("product_name"),
            product_price=updated.get("product_price"),
            quantity=updated["quantity"],
        )

    item_id = await get_next_id("cart_items")
    cart_doc = {
        "id": item_id,
        "user_id": request.user_id,
        "product_id": request.product_id,
        "product_name": request.product_name,
        "product_price": request.product_price,
        "quantity": request.quantity,
    }
    await db.cart_items.insert_one(cart_doc)
    return CartItemResponse(**{k: v for k, v in cart_doc.items() if k != "_id"})


@app.post("/cart/remove")
async def remove_from_cart(request: CartRemoveRequest):
    result = await db.cart_items.delete_one(
        {"user_id": request.user_id, "product_id": request.product_id}
    )
    if result.deleted_count == 0:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not found in cart",
        )
    return {"message": "Item removed from cart"}


@app.get("/cart", response_model=list[CartItemResponse])
async def get_cart(user_id: int = Query(...)):
    items = await db.cart_items.find(
        {"user_id": user_id}, {"_id": 0}
    ).to_list(length=100)
    return items


@app.post("/order/create", response_model=OrderResponse)
async def create_order(request: OrderCreateRequest):
    cart_items = await db.cart_items.find(
        {"user_id": request.user_id}
    ).to_list(length=100)

    if not cart_items:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cart is empty",
        )

    total = sum((item.get("product_price") or 0) * item["quantity"] for item in cart_items)
    order_ref = f"ORD-{uuid.uuid4().hex[:8].upper()}"
    order_id = await get_next_id("orders")

    order_items = [
        {
            "product_id": item["product_id"],
            "product_name": item.get("product_name"),
            "quantity": item["quantity"],
            "price": item.get("product_price") or 0,
        }
        for item in cart_items
    ]

    order_doc = {
        "id": order_id,
        "user_id": request.user_id,
        "order_ref": order_ref,
        "total": total,
        "created_at": datetime.now(timezone.utc),
        "items": order_items,
    }
    await db.orders.insert_one(order_doc)
    await db.cart_items.delete_many({"user_id": request.user_id})

    return OrderResponse(
        id=order_doc["id"],
        user_id=order_doc["user_id"],
        order_ref=order_doc["order_ref"],
        total=order_doc["total"],
        created_at=order_doc["created_at"],
        items=[OrderItemResponse(**item) for item in order_items],
    )


@app.get("/orders", response_model=list[OrderResponse])
async def get_orders(user_id: int = Query(...)):
    orders = await db.orders.find(
        {"user_id": user_id}, {"_id": 0}
    ).sort("created_at", -1).to_list(length=100)

    result = []
    for order in orders:
        items = [OrderItemResponse(**item) for item in order.get("items", [])]
        result.append(OrderResponse(
            id=order["id"],
            user_id=order["user_id"],
            order_ref=order["order_ref"],
            total=order["total"],
            created_at=order["created_at"],
            items=items,
        ))
    return result
