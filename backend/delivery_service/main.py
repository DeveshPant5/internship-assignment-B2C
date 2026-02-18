from datetime import datetime, timezone
from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from database import db, get_next_id
from models import DeliveryStatusResponse, StatusUpdateRequest, STATUS_FLOW

app = FastAPI(title="Delivery & Order Status Service", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    return {"service": "Delivery & Order Status Service", "status": "running"}


@app.get("/health")
def health():
    return {"status": "healthy", "service": "delivery_service"}


@app.get("/order/{order_id}/status", response_model=DeliveryStatusResponse)
async def get_order_status(order_id: int):
    delivery = await db.delivery_statuses.find_one({"order_id": order_id})

    if not delivery:
        doc_id = await get_next_id("delivery_statuses")
        delivery = {
            "id": doc_id,
            "order_id": order_id,
            "status": "PLACED",
            "updated_at": datetime.now(timezone.utc),
        }
        await db.delivery_statuses.insert_one(delivery)

    return DeliveryStatusResponse(
        id=delivery["id"],
        order_id=delivery["order_id"],
        status=delivery["status"],
        updated_at=delivery["updated_at"],
    )


@app.post("/order/{order_id}/update-status", response_model=DeliveryStatusResponse)
async def update_order_status(order_id: int, request: StatusUpdateRequest = None):
    delivery = await db.delivery_statuses.find_one({"order_id": order_id})

    if not delivery:
        doc_id = await get_next_id("delivery_statuses")
        delivery = {
            "id": doc_id,
            "order_id": order_id,
            "status": "PLACED",
            "updated_at": datetime.now(timezone.utc),
        }
        await db.delivery_statuses.insert_one(delivery)

    if request and request.status:
        if request.status not in STATUS_FLOW:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Invalid status. Must be one of: {STATUS_FLOW}",
            )
        new_status = request.status
    else:
        current_index = STATUS_FLOW.index(delivery["status"])
        if current_index >= len(STATUS_FLOW) - 1:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Order is already delivered",
            )
        new_status = STATUS_FLOW[current_index + 1]

    now = datetime.now(timezone.utc)
    await db.delivery_statuses.update_one(
        {"order_id": order_id},
        {"$set": {"status": new_status, "updated_at": now}},
    )

    return DeliveryStatusResponse(
        id=delivery["id"],
        order_id=order_id,
        status=new_status,
        updated_at=now,
    )
