import os
import asyncio
import certifi
from pathlib import Path
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient

# Load .env from project root (two levels up from this file)
load_dotenv(Path(__file__).resolve().parent.parent.parent / ".env")

MONGO_URL = os.getenv("MONGO_URL")
if not MONGO_URL:
    raise RuntimeError("MONGO_URL environment variable is not set")
DB_NAME = "thriftapp_products"

SEED_PRODUCTS = [
    # Fruits & Vegetables
    {"name": "Fresh Bananas", "description": "A bunch of ripe yellow bananas", "price": 40.0, "category": "Fruits & Vegetables", "image_url": "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&q=80", "is_available": True},
    {"name": "Red Apples", "description": "Crisp and juicy red apples (1 kg)", "price": 120.0, "category": "Fruits & Vegetables", "image_url": "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400&q=80", "is_available": True},
    {"name": "Tomatoes", "description": "Farm fresh tomatoes (500g)", "price": 30.0, "category": "Fruits & Vegetables", "image_url": "https://images.unsplash.com/photo-1546470427-e26264be0b0d?w=400&q=80", "is_available": True},
    {"name": "Onions", "description": "Fresh onions (1 kg)", "price": 35.0, "category": "Fruits & Vegetables", "image_url": "https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?w=400&q=80", "is_available": True},
    {"name": "Potatoes", "description": "Fresh potatoes (1 kg)", "price": 25.0, "category": "Fruits & Vegetables", "image_url": "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400&q=80", "is_available": True},
    {"name": "Green Grapes", "description": "Seedless green grapes (500g)", "price": 90.0, "category": "Fruits & Vegetables", "image_url": "https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=400&q=80", "is_available": True},
    {"name": "Carrots", "description": "Crunchy orange carrots (500g)", "price": 28.0, "category": "Fruits & Vegetables", "image_url": "https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400&q=80", "is_available": True},
    {"name": "Mango", "description": "Sweet Alphonso mangoes (1 kg)", "price": 150.0, "category": "Fruits & Vegetables", "image_url": "https://images.unsplash.com/photo-1553279768-865429fa0078?w=400&q=80", "is_available": True},
    {"name": "Spinach", "description": "Fresh green spinach bunch", "price": 20.0, "category": "Fruits & Vegetables", "image_url": "https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400&q=80", "is_available": True},
    {"name": "Watermelon", "description": "Juicy seedless watermelon (1 pc)", "price": 60.0, "category": "Fruits & Vegetables", "image_url": "https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=400&q=80", "is_available": True},
    {"name": "Lemon", "description": "Fresh lemons (250g)", "price": 15.0, "category": "Fruits & Vegetables", "image_url": "https://images.unsplash.com/photo-1582087677879-6a01d8e4cf1e?w=400&q=80", "is_available": True},
    {"name": "Capsicum", "description": "Fresh green capsicum (250g)", "price": 22.0, "category": "Fruits & Vegetables", "image_url": "https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=400&q=80", "is_available": True},
    {"name": "Aashirvaad Atta", "description": "Whole wheat flour (5 kg)", "price": 260.0, "category": "Fruits & Vegetables", "image_url": "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=400&q=80", "is_available": True},
    {"name": "Basmati Rice", "description": "Premium basmati rice (1 kg)", "price": 120.0, "category": "Fruits & Vegetables", "image_url": "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400&q=80", "is_available": True},
    {"name": "Dal", "description": "Toor dal / lentils (1 kg)", "price": 110.0, "category": "Fruits & Vegetables", "image_url": "https://images.unsplash.com/photo-1585032226651-759b368d7246?w=400&q=80", "is_available": True},

    # Dairy & Bakery
    {"name": "Amul Toned Milk", "description": "Pasteurized toned milk (500ml)", "price": 27.0, "category": "Dairy & Bakery", "image_url": "https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400&q=80", "is_available": True},
    {"name": "Amul Butter", "description": "Creamy butter (100g)", "price": 52.0, "category": "Dairy & Bakery", "image_url": "https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=400&q=80", "is_available": True},
    {"name": "Curd Cup", "description": "Fresh curd (400g)", "price": 35.0, "category": "Dairy & Bakery", "image_url": "https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400&q=80", "is_available": True},
    {"name": "Paneer", "description": "Fresh cottage cheese (200g)", "price": 80.0, "category": "Dairy & Bakery", "image_url": "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=400&q=80", "is_available": True},
    {"name": "Eggs", "description": "Farm fresh eggs (pack of 6)", "price": 42.0, "category": "Dairy & Bakery", "image_url": "https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&q=80", "is_available": True},
    {"name": "Cheese Slices", "description": "Processed cheese slices (10 pcs)", "price": 95.0, "category": "Dairy & Bakery", "image_url": "https://images.unsplash.com/photo-1618164435735-413d3b066c9a?w=400&q=80", "is_available": True},
    {"name": "Cream", "description": "Fresh cream (200ml)", "price": 55.0, "category": "Dairy & Bakery", "image_url": "https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&q=80", "is_available": True},
    {"name": "Yogurt", "description": "Flavored yogurt cup (100g)", "price": 25.0, "category": "Dairy & Bakery", "image_url": "https://images.unsplash.com/photo-1571212515416-fca988083f0b?w=400&q=80", "is_available": True},
    {"name": "Tata Salt", "description": "Iodized salt (1 kg)", "price": 24.0, "category": "Dairy & Bakery", "image_url": "https://images.unsplash.com/photo-1518110925495-5fe2fda0442c?w=400&q=80", "is_available": True},
    {"name": "Sunflower Oil", "description": "Refined sunflower oil (1L)", "price": 140.0, "category": "Dairy & Bakery", "image_url": "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&q=80", "is_available": True},
    {"name": "Ghee", "description": "Pure desi ghee (500ml)", "price": 280.0, "category": "Dairy & Bakery", "image_url": "https://images.unsplash.com/photo-1631451095765-2c91616fc9e6?w=400&q=80", "is_available": True},
    {"name": "Croissant", "description": "Butter croissant (2 pcs)", "price": 60.0, "category": "Dairy & Bakery", "image_url": "https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400&q=80", "is_available": True},
    {"name": "Sandwich Bread", "description": "Whole wheat bread loaf", "price": 45.0, "category": "Dairy & Bakery", "image_url": "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&q=80", "is_available": True},
    {"name": "Muffin", "description": "Chocolate chip muffin", "price": 35.0, "category": "Dairy & Bakery", "image_url": "https://images.unsplash.com/photo-1607958996333-41aef7caefaa?w=400&q=80", "is_available": True},
    {"name": "Pizza Base", "description": "Ready pizza base (2 pcs)", "price": 65.0, "category": "Dairy & Bakery", "image_url": "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&q=80", "is_available": True},

    # Snacks & Beverages
    {"name": "Lays Classic Salted", "description": "Crispy potato chips (52g)", "price": 20.0, "category": "Snacks & Beverages", "image_url": "https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400&q=80", "is_available": True},
    {"name": "Kurkure Masala Munch", "description": "Crunchy corn puffs (75g)", "price": 20.0, "category": "Snacks & Beverages", "image_url": "https://images.unsplash.com/photo-1621447504864-d8686e12698c?w=400&q=80", "is_available": True},
    {"name": "Oreo Biscuits", "description": "Chocolate cream biscuits (120g)", "price": 30.0, "category": "Snacks & Beverages", "image_url": "https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=400&q=80", "is_available": True},
    {"name": "Dark Fantasy", "description": "Choco-filled cookies (75g)", "price": 40.0, "category": "Snacks & Beverages", "image_url": "https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=400&q=80", "is_available": True},
    {"name": "Peanuts", "description": "Roasted salted peanuts (200g)", "price": 35.0, "category": "Snacks & Beverages", "image_url": "https://images.unsplash.com/photo-1567892737950-30c4db37cd89?w=400&q=80", "is_available": True},
    {"name": "Popcorn", "description": "Butter popcorn pack (100g)", "price": 45.0, "category": "Snacks & Beverages", "image_url": "https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=400&q=80", "is_available": True},
    {"name": "Bread", "description": "Fresh white bread loaf", "price": 35.0, "category": "Snacks & Beverages", "image_url": "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&q=80", "is_available": True},
    {"name": "Cake Rusk", "description": "Crispy cake rusk (300g)", "price": 50.0, "category": "Snacks & Beverages", "image_url": "https://images.unsplash.com/photo-1607958996333-41aef7caefaa?w=400&q=80", "is_available": True},
    {"name": "Coca-Cola", "description": "Chilled cola drink (750ml)", "price": 38.0, "category": "Snacks & Beverages", "image_url": "https://images.unsplash.com/photo-1554866585-cd94860890b7?w=400&q=80", "is_available": True},
    {"name": "Orange Juice", "description": "Fresh orange juice (400ml)", "price": 25.0, "category": "Snacks & Beverages", "image_url": "https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400&q=80", "is_available": True},
    {"name": "Red Bull", "description": "Energy drink (250ml)", "price": 115.0, "category": "Snacks & Beverages", "image_url": "https://images.unsplash.com/photo-1622543925917-763c34d1a86e?w=400&q=80", "is_available": True},
    {"name": "Water Bottle", "description": "Packaged drinking water (1L)", "price": 20.0, "category": "Snacks & Beverages", "image_url": "https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=400&q=80", "is_available": True},
    {"name": "Green Tea", "description": "Organic green tea (25 bags)", "price": 140.0, "category": "Snacks & Beverages", "image_url": "https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400&q=80", "is_available": True},
    {"name": "Coffee", "description": "Instant coffee (100g)", "price": 180.0, "category": "Snacks & Beverages", "image_url": "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400&q=80", "is_available": True},
    {"name": "Lassi", "description": "Mango lassi (200ml)", "price": 30.0, "category": "Snacks & Beverages", "image_url": "https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=400&q=80", "is_available": True},
    {"name": "Coconut Water", "description": "Fresh coconut water (300ml)", "price": 35.0, "category": "Snacks & Beverages", "image_url": "https://images.unsplash.com/photo-1550461716-dbf266b2a8a7?w=400&q=80", "is_available": True},
    {"name": "Maggi Noodles", "description": "Instant noodles (pack of 4)", "price": 48.0, "category": "Snacks & Beverages", "image_url": "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&q=80", "is_available": True},
    {"name": "Sugar", "description": "Refined sugar (1 kg)", "price": 42.0, "category": "Snacks & Beverages", "image_url": "https://images.unsplash.com/photo-1581441363689-1f3c3c413b41?w=400&q=80", "is_available": True},

    # Meat & Fish
    {"name": "Chicken Breast", "description": "Boneless chicken breast (500g)", "price": 180.0, "category": "Meat & Fish", "image_url": "https://images.unsplash.com/photo-1604503468506-a8da13d11bea?w=400&q=80", "is_available": True},
    {"name": "Mutton Curry Cut", "description": "Fresh mutton pieces (500g)", "price": 450.0, "category": "Meat & Fish", "image_url": "https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=400&q=80", "is_available": True},
    {"name": "Fish Fillet", "description": "Boneless fish fillet (500g)", "price": 220.0, "category": "Meat & Fish", "image_url": "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=400&q=80", "is_available": True},
    {"name": "Prawns", "description": "Fresh prawns (250g)", "price": 300.0, "category": "Meat & Fish", "image_url": "https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=400&q=80", "is_available": True},
]


async def seed():
    client = AsyncIOMotorClient(MONGO_URL)
    database = client[DB_NAME]

    existing = await database.products.count_documents({})
    if existing > 0:
        print(f"Database already has {existing} products. Clearing and re-seeding...")
        await database.products.delete_many({})
        await database.counters.delete_one({"_id": "products"})

    for i, product_data in enumerate(SEED_PRODUCTS, start=1):
        product_data["id"] = i
        await database.products.insert_one(product_data)

    await database.counters.update_one(
        {"_id": "products"},
        {"$set": {"seq": len(SEED_PRODUCTS)}},
        upsert=True,
    )

    print(f"Seeded {len(SEED_PRODUCTS)} products successfully!")
    client.close()


if __name__ == "__main__":
    asyncio.run(seed())
