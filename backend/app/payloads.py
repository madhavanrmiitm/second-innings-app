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


class CareRequestStatus(str, Enum):
    PENDING = "pending"
    ACCEPTED = "accepted"
    REJECTED = "rejected"
    CANCELLED = "cancelled"


class TaskStatus(str, Enum):
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    CANCELLED = "cancelled"


class TicketStatus(str, Enum):
    OPEN = "open"
    IN_PROGRESS = "in_progress"
    RESOLVED = "resolved"
    CLOSED = "closed"


class NotificationType(str, Enum):
    TASK = "task"
    CARE_REQUEST = "care_request"
    RELATION = "relation"
    INTEREST_GROUP = "interest_group"
    SUPPORT_TICKET = "support_ticket"


class NotificationPriority(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"


class TokenRequest(BaseModel):
    id_token: str


class AddFamilyMemberRequest(BaseModel):
    id_token: str
    family_member_firebase_uid: str
    senior_citizen_relation: str
    family_member_relation: str


class RemoveFamilyMemberRequest(BaseModel):
    id_token: str
    family_member_firebase_uid: str


class CreateCareRequest(BaseModel):
    id_token: str
    caregiver_firebase_uid: str
    timing_to_visit: datetime
    location: str


class UpdateCareRequest(BaseModel):
    id_token: str
    status: Optional[CareRequestStatus] = None
    timing_to_visit: Optional[datetime] = None
    location: Optional[str] = None


class ApplyCareRequest(BaseModel):
    id_token: str


class AcceptEngagement(BaseModel):
    id_token: str


class DeclineEngagement(BaseModel):
    id_token: str


class CreateTask(BaseModel):
    id_token: str
    title: str
    description: Optional[str] = None
    time_of_completion: Optional[datetime] = None
    assigned_to_firebase_uid: Optional[str] = None


class UpdateTask(BaseModel):
    id_token: str
    title: Optional[str] = None
    description: Optional[str] = None
    time_of_completion: Optional[datetime] = None
    status: Optional[TaskStatus] = None
    assigned_to_firebase_uid: Optional[str] = None


class CreateReminder(BaseModel):
    id_token: str
    title: str
    description: Optional[str] = None
    time: datetime


class UpdateReminder(BaseModel):
    id_token: str
    title: Optional[str] = None
    description: Optional[str] = None
    time: Optional[datetime] = None


class CreateInterestGroup(BaseModel):
    id_token: str
    title: str
    description: Optional[str] = None
    links: Optional[str] = None
    timing: Optional[datetime] = None


class UpdateInterestGroup(BaseModel):
    id_token: str
    title: Optional[str] = None
    description: Optional[str] = None
    links: Optional[str] = None
    status: Optional[str] = None
    timing: Optional[datetime] = None


class CreateTicket(BaseModel):
    id_token: str
    subject: str
    description: Optional[str] = None


class UpdateTicket(BaseModel):
    id_token: str
    subject: Optional[str] = None
    description: Optional[str] = None
    status: Optional[TicketStatus] = None


class MarkNotificationAsRead(BaseModel):
    id_token: str


class ReviewCaregiver(BaseModel):
    id_token: str
    status: UserStatus


class ResolveTicket(BaseModel):
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
