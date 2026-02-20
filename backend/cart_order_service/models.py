from datetime import datetime
from pydantic import BaseModel

class CartAddRequest(BaseModel):
    user_id: int
    product_id: int
    product_name: str | None = None
    product_price: float | None = None
    quantity: int = 1

class CartRemoveRequest(BaseModel):
    user_id: int
    product_id: int

class CartItemResponse(BaseModel):
    id: int
    user_id: int
    product_id: int
    product_name: str | None
    product_price: float | None
    quantity: int

class OrderCreateRequest(BaseModel):
    user_id: int

class OrderItemResponse(BaseModel):
    product_id: int
    product_name: str | None
    quantity: int
    price: float

class OrderResponse(BaseModel):
    id: int
    user_id: int
    order_ref: str
    total: float
    created_at: datetime
    items: list[OrderItemResponse]
