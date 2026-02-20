from fastapi import FastAPI, HTTPException, status, Query
from fastapi.middleware.cors import CORSMiddleware
from database import db
from models import ProductResponse, CategoryResponse
from typing import Optional

app = FastAPI(title="Product Catalog Service", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def root():
    return {"service": "Product Catalog Service", "status": "running"}

@app.get("/health")
def health():
    return {"status": "healthy", "service": "product_service"}

@app.get("/products", response_model=list[ProductResponse])
async def get_products(category: Optional[str] = Query(None)):
    query = {}
    if category:
        query["category"] = category
    products = await db.products.find(query, {"_id": 0}).to_list(length=200)
    return products

@app.get("/products/{product_id}", response_model=ProductResponse)
async def get_product(product_id: int):
    product = await db.products.find_one({"id": product_id}, {"_id": 0})
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found",
        )
    return product

@app.get("/categories", response_model=list[CategoryResponse])
async def get_categories():
    pipeline = [
        {"$group": {"_id": "$category", "product_count": {"$sum": 1}}},
        {"$project": {"name": "$_id", "product_count": 1, "_id": 0}},
    ]
    results = await db.products.aggregate(pipeline).to_list(length=100)
    return results
