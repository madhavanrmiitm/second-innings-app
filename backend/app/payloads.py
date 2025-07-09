from datetime import datetime

from pydantic import BaseModel


class Item(BaseModel):
    name: str
    description: str | None = None
    price: float
    tax: float | None = None


class TokenRequest(BaseModel):
    id_token: str


class User(BaseModel):
    id: int
    gmail_id: str
    firebase_uid: str
    full_name: str
    created_at: datetime
    updated_at: datetime


class UserCreateRequest(BaseModel):
    gmail_id: str
    firebase_uid: str
    full_name: str


class UnregisteredUser(BaseModel):
    firebase_uid: str
    gmail_id: str
    full_name: str


class AuthResponse(BaseModel):
    user: User
    is_new_user: bool


class UnregisteredUserResponse(BaseModel):
    user_info: UnregisteredUser
    is_registered: bool = False
