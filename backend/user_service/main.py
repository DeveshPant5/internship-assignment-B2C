from datetime import datetime, timezone
from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from database import db, get_next_id
from models import UserRegister, UserLogin, UserProfile, Token
from auth import hash_password, verify_password, create_access_token

app = FastAPI(title="User Service", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def root():
    return {"service": "User Service", "status": "running"}

@app.get("/health")
def health():
    return {"status": "healthy", "service": "user_service"}

@app.post("/register", response_model=Token)
async def register(user_data: UserRegister):
    existing = await db.users.find_one({"email": user_data.email})
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered",
        )

    user_id = await get_next_id("users")
    user_doc = {
        "id": user_id,
        "name": user_data.name,
        "email": user_data.email,
        "hashed_password": hash_password(user_data.password),
        "created_at": datetime.now(timezone.utc),
    }
    await db.users.insert_one(user_doc)

    token = create_access_token({"user_id": user_id, "email": user_data.email})
    return Token(
        access_token=token,
        token_type="bearer",
        user_id=user_id,
        name=user_data.name,
    )

@app.post("/login", response_model=Token)
async def login(credentials: UserLogin):
    user = await db.users.find_one({"email": credentials.email})
    if not user or not verify_password(credentials.password, user["hashed_password"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    token = create_access_token({"user_id": user["id"], "email": user["email"]})
    return Token(
        access_token=token,
        token_type="bearer",
        user_id=user["id"],
        name=user["name"],
    )

@app.get("/profile", response_model=UserProfile)
async def get_profile(user_id: int):
    user = await db.users.find_one({"id": user_id})
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
    return UserProfile(
        id=user["id"],
        name=user["name"],
        email=user["email"],
        created_at=user["created_at"],
    )
