from pydantic import BaseModel


class ProductResponse(BaseModel):
    id: int
    name: str
    description: str | None
    price: float
    category: str
    image_url: str | None
    is_available: bool


class CategoryResponse(BaseModel):
    name: str
    product_count: int
