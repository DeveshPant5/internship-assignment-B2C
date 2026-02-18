from datetime import datetime
from pydantic import BaseModel


class UserRegister(BaseModel):
    name: str
    email: str
    password: str
    otp: str


class UserLogin(BaseModel):
    email: str
    password: str


class UserProfile(BaseModel):
    id: int
    name: str
    email: str
    created_at: datetime


class Token(BaseModel):
    access_token: str
    token_type: str
    user_id: int
    name: str
