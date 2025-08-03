from datetime import date, datetime
from typing import Dict, List

from app.payloads import UnregisteredUser, User, UserRole, UserStatus

# Predefined test users for each role (2 per role)
# These users will be used in test mode to bypass Firebase authentication

TEST_USERS: List[User] = [
    # ADMIN users
    User(
        id=1,
        gmail_id="admin1@test.com",
        firebase_uid="test_admin_uid_001",
        full_name="Test Admin One",
        role=UserRole.ADMIN,
        status=UserStatus.ACTIVE,
        youtube_url=None,
        date_of_birth=date(1970, 1, 15),
        description="Test admin user for development",
        tags="admin,test",
        created_at=datetime.now(),
        updated_at=datetime.now(),
    ),
    User(
        id=2,
        gmail_id="admin2@test.com",
        firebase_uid="test_admin_uid_002",
        full_name="Test Admin Two",
        role=UserRole.ADMIN,
        status=UserStatus.ACTIVE,
        youtube_url=None,
        date_of_birth=date(1975, 3, 20),
        description="Second test admin user for development",
        tags="admin,test",
        created_at=datetime.now(),
        updated_at=datetime.now(),
    ),
    # CAREGIVER users
    User(
        id=3,
        gmail_id="caregiver1@test.com",
        firebase_uid="test_caregiver_uid_001",
        full_name="Test Caregiver One",
        role=UserRole.CAREGIVER,
        status=UserStatus.ACTIVE,
        youtube_url="https://www.youtube.com/watch?v=test1",
        date_of_birth=date(1985, 6, 10),
        description="Experienced caregiver specializing in elderly care",
        tags="caregiver,elderly,compassionate",
        created_at=datetime.now(),
        updated_at=datetime.now(),
    ),
    User(
        id=4,
        gmail_id="caregiver2@test.com",
        firebase_uid="test_caregiver_uid_002",
        full_name="Test Caregiver Two",
        role=UserRole.CAREGIVER,
        status=UserStatus.PENDING_APPROVAL,
        youtube_url="https://www.youtube.com/watch?v=test2",
        date_of_birth=date(1990, 8, 25),
        description="Certified nurse with 5 years of experience in home care",
        tags="caregiver,nurse,home-care",
        created_at=datetime.now(),
        updated_at=datetime.now(),
    ),
    # FAMILY_MEMBER users
    User(
        id=5,
        gmail_id="family1@test.com",
        firebase_uid="test_family_uid_001",
        full_name="Test Family Member One",
        role=UserRole.FAMILY_MEMBER,
        status=UserStatus.ACTIVE,
        youtube_url=None,
        date_of_birth=date(1980, 12, 5),
        description="Caring family member looking after elderly parent",
        tags="family,caring",
        created_at=datetime.now(),
        updated_at=datetime.now(),
    ),
    User(
        id=6,
        gmail_id="family2@test.com",
        firebase_uid="test_family_uid_002",
        full_name="Test Family Member Two",
        role=UserRole.FAMILY_MEMBER,
        status=UserStatus.ACTIVE,
        youtube_url=None,
        date_of_birth=date(1988, 4, 18),
        description="Devoted child managing care for senior citizen",
        tags="family,devoted",
        created_at=datetime.now(),
        updated_at=datetime.now(),
    ),
    # SENIOR_CITIZEN users
    User(
        id=7,
        gmail_id="senior1@test.com",
        firebase_uid="test_senior_uid_001",
        full_name="Test Senior Citizen One",
        role=UserRole.SENIOR_CITIZEN,
        status=UserStatus.ACTIVE,
        youtube_url=None,
        date_of_birth=date(1945, 2, 14),
        description="Retired teacher enjoying second innings of life",
        tags="senior,retired,teacher",
        created_at=datetime.now(),
        updated_at=datetime.now(),
    ),
    User(
        id=8,
        gmail_id="senior2@test.com",
        firebase_uid="test_senior_uid_002",
        full_name="Test Senior Citizen Two",
        role=UserRole.SENIOR_CITIZEN,
        status=UserStatus.ACTIVE,
        youtube_url=None,
        date_of_birth=date(1950, 9, 30),
        description="Former engineer with passion for gardening",
        tags="senior,engineer,gardening",
        created_at=datetime.now(),
        updated_at=datetime.now(),
    ),
    # INTEREST_GROUP_ADMIN users
    User(
        id=9,
        gmail_id="groupadmin1@test.com",
        firebase_uid="test_groupadmin_uid_001",
        full_name="Test Group Admin One",
        role=UserRole.INTEREST_GROUP_ADMIN,
        status=UserStatus.ACTIVE,
        youtube_url="https://www.youtube.com/watch?v=testgroup1",
        date_of_birth=date(1965, 7, 22),
        description="Community leader organizing activities for seniors",
        tags="group-admin,community,activities",
        created_at=datetime.now(),
        updated_at=datetime.now(),
    ),
    User(
        id=10,
        gmail_id="groupadmin2@test.com",
        firebase_uid="test_groupadmin_uid_002",
        full_name="Test Group Admin Two",
        role=UserRole.INTEREST_GROUP_ADMIN,
        status=UserStatus.PENDING_APPROVAL,
        youtube_url="https://www.youtube.com/watch?v=testgroup2",
        date_of_birth=date(1972, 11, 8),
        description="Art therapist creating engaging programs for elderly",
        tags="group-admin,art-therapy,programs",
        created_at=datetime.now(),
        updated_at=datetime.now(),
    ),
    # SUPPORT_USER users
    User(
        id=11,
        gmail_id="support1@test.com",
        firebase_uid="test_support_uid_001",
        full_name="Test Support User One",
        role=UserRole.SUPPORT_USER,
        status=UserStatus.ACTIVE,
        youtube_url=None,
        date_of_birth=date(1992, 1, 12),
        description="Support specialist helping users with platform issues",
        tags="support,specialist",
        created_at=datetime.now(),
        updated_at=datetime.now(),
    ),
    User(
        id=12,
        gmail_id="support2@test.com",
        firebase_uid="test_support_uid_002",
        full_name="Test Support User Two",
        role=UserRole.SUPPORT_USER,
        status=UserStatus.ACTIVE,
        youtube_url=None,
        date_of_birth=date(1987, 5, 7),
        description="Customer service representative for platform support",
        tags="support,customer-service",
        created_at=datetime.now(),
        updated_at=datetime.now(),
    ),
]

# Create lookup dictionaries for quick access
TEST_USERS_BY_UID: Dict[str, User] = {user.firebase_uid: user for user in TEST_USERS}
TEST_USERS_BY_EMAIL: Dict[str, User] = {user.gmail_id: user for user in TEST_USERS}

# Test tokens that map to test users (simple format for testing)
TEST_TOKENS = {
    # Admin tokens
    "test_admin_token_001": "test_admin_uid_001",
    "test_admin_token_002": "test_admin_uid_002",
    # Caregiver tokens
    "test_caregiver_token_001": "test_caregiver_uid_001",
    "test_caregiver_token_002": "test_caregiver_uid_002",
    # Family member tokens
    "test_family_token_001": "test_family_uid_001",
    "test_family_token_002": "test_family_uid_002",
    # Senior citizen tokens
    "test_senior_token_001": "test_senior_uid_001",
    "test_senior_token_002": "test_senior_uid_002",
    # Interest group admin tokens
    "test_groupadmin_token_001": "test_groupadmin_uid_001",
    "test_groupadmin_token_002": "test_groupadmin_uid_002",
    # Support user tokens
    "test_support_token_001": "test_support_uid_001",
    "test_support_token_002": "test_support_uid_002",
}

# Unregistered test users for testing registration flow
TEST_UNREGISTERED_USERS = [
    UnregisteredUser(
        firebase_uid="test_unregistered_uid_001",
        gmail_id="unregistered1@test.com",
        full_name="Test Unregistered User One",
    ),
    UnregisteredUser(
        firebase_uid="test_unregistered_uid_002",
        gmail_id="unregistered2@test.com",
        full_name="Test Unregistered User Two",
    ),
]

# Test tokens for unregistered users
TEST_UNREGISTERED_TOKENS = {
    "test_unregistered_token_001": "test_unregistered_uid_001",
    "test_unregistered_token_002": "test_unregistered_uid_002",
}
