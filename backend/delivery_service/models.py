from datetime import datetime
from pydantic import BaseModel

STATUS_FLOW = ["PLACED", "PACKED", "OUT_FOR_DELIVERY", "DELIVERED"]

class DeliveryStatusResponse(BaseModel):
    id: int
    order_id: int
    status: str
    updated_at: datetime

class StatusUpdateRequest(BaseModel):
    status: str | None = None
