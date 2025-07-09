from datetime import date, datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, field_validator


class UserRole(str, Enum):
    ADMIN = "admin"
    CAREGIVER = "caregiver"
    FAMILY_MEMBER = "family_member"
    SENIOR_CITIZEN = "senior_citizen"
    INTEREST_GROUP_ADMIN = "interest_group_admin"
    SUPPORT_USER = "support_user"


class TokenRequest(BaseModel):
    id_token: str


class User(BaseModel):

    id: int
    gmail_id: str
    firebase_uid: str
    full_name: str
    role: UserRole
    youtube_url: Optional[str] = None
    date_of_birth: Optional[date] = None
    description: Optional[str] = None
    tags: Optional[str] = None
    created_at: datetime
    updated_at: datetime


class UserCreateRequest(BaseModel):
    gmail_id: str
    firebase_uid: str
    full_name: str
    role: UserRole


class UnregisteredUser(BaseModel):
    firebase_uid: str
    gmail_id: str
    full_name: str


class RegistrationRequest(BaseModel):
    id_token: str
    full_name: str
    role: UserRole
    youtube_url: Optional[str] = None
    date_of_birth: Optional[date] = None
    description: Optional[str] = None
    tags: Optional[str] = None

    @field_validator("youtube_url", "description", "tags")
    @classmethod
    def validate_caregiver_fields(cls, v, info):
        """Validate that youtube_url, description, and tags are provided for caregiver role"""
        # Get the role from the model data
        role = info.data.get("role")
        field_name = info.field_name

        if role == UserRole.CAREGIVER and v is None:
            raise ValueError(f"{field_name} is required for caregiver role")

        return v


class RegistrationResponse(BaseModel):
    user: User
    message: str


class AuthResponse(BaseModel):
    user: User
    is_new_user: bool


class UnregisteredUserResponse(BaseModel):
    user_info: UnregisteredUser
    is_registered: bool = False
