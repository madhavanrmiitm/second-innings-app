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


class UserStatus(str, Enum):
    PENDING_APPROVAL = "pending_approval"
    ACTIVE = "active"
    BLOCKED = "blocked"


class TokenRequest(BaseModel):
    id_token: str


class User(BaseModel):

    id: int
    gmail_id: str
    firebase_uid: str
    full_name: str
    role: UserRole
    status: UserStatus
    youtube_url: Optional[str] = None
    date_of_birth: Optional[date] = None
    description: Optional[str] = None
    tags: Optional[str] = None
    created_at: datetime
    updated_at: datetime


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

    @field_validator("youtube_url")
    @classmethod
    def validate_youtube_url_for_roles(cls, v, info):
        """Validate that youtube_url is provided for caregiver and interest_group_admin roles (tags and description will be auto-generated)"""
        # Get the role from the model data
        role = info.data.get("role")

        if role in [UserRole.CAREGIVER, UserRole.INTEREST_GROUP_ADMIN] and v is None:
            raise ValueError(f"youtube_url is required for {role.value} role")

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


class ProfileResponse(BaseModel):
    user: User
