from datetime import date, datetime
from typing import Dict, List

from app.payloads import UnregisteredUser, User, UserRole, UserStatus

# Predefined test users for each role (including story characters)
# These users will be used in test mode to bypass Firebase authentication

TEST_USERS: List[User] = [
    # ADMIN users (IDs 1-2 to match database)
    User(
        id=1,
        gmail_id="21f3001600@ds.study.iitm.ac.in",
        firebase_uid="qEGg9NTOjfgSaw646IhSRCXKtaZ2",
        full_name="Ashwin Narayanan S",
        role=UserRole.ADMIN,
        status=UserStatus.ACTIVE,
        youtube_url=None,
        date_of_birth=None,
        description=None,
        tags=None,
        created_at=datetime.now(),
        updated_at=datetime.now(),
    ),
    User(
        id=2,
        gmail_id="nakshatra.nsb@gmail.com",
        firebase_uid="4N2P7ZAWGPgXXoQmp2YAKXJTw253",
        full_name="Nakshatra Gupta",
        role=UserRole.ADMIN,
        status=UserStatus.ACTIVE,
        youtube_url=None,
        date_of_birth=None,
        description=None,
        tags=None,
        created_at=datetime.now(),
        updated_at=datetime.now(),
    ),
    # STORY CHARACTERS
    # Asha - Senior Citizen (ID 3)
    User(
        id=3,
        gmail_id="asha.senior@example.com",
        firebase_uid="story_asha_uid_001",
        full_name="Asha",
        role=UserRole.SENIOR_CITIZEN,
        status=UserStatus.ACTIVE,
        youtube_url=None,
        date_of_birth=date(1945, 3, 15),
        description="80-year-old Indian woman with kind eyes, short grey hair, and glasses. Enjoys gardening and staying active.",
        tags="senior,indian,gardening,active",
        created_at=datetime.now(),
        updated_at=datetime.now(),
    ),
    # Rohan - Family Member (ID 4) - Asha's son
    User(
        id=4,
        gmail_id="rohan.family@example.com",
        firebase_uid="story_rohan_uid_001",
        full_name="Rohan",
        role=UserRole.FAMILY_MEMBER,
        status=UserStatus.ACTIVE,
        youtube_url=None,
        date_of_birth=date(1980, 8, 22),
        description="45-year-old professional Indian man with short black hair and grey streaks at temples. Caring son managing his mother Asha's care.",
        tags="family,professional,caring,indian",
        created_at=datetime.now(),
        updated_at=datetime.now(),
    ),
    # Priya - Caregiver (ID 5)
    User(
        id=5,
        gmail_id="priya.caregiver@example.com",
        firebase_uid="story_priya_uid_001",
        full_name="Priya",
        role=UserRole.CAREGIVER,
        status=UserStatus.ACTIVE,
        youtube_url="https://www.youtube.com/watch?v=priya_intro",
        date_of_birth=date(1997, 11, 8),
        description="28-year-old Indian woman with warm smile and long dark hair in ponytail. Specializes in physiotherapy and companionship.",
        tags="caregiver,physiotherapy,companionship,indian",
        created_at=datetime.now(),
        updated_at=datetime.now(),
    ),
    # Mr. Verma - Interest Group Admin (ID 6)
    User(
        id=6,
        gmail_id="verma.groupadmin@example.com",
        firebase_uid="story_verma_uid_001",
        full_name="Mr. Verma",
        role=UserRole.INTEREST_GROUP_ADMIN,
        status=UserStatus.ACTIVE,
        youtube_url="https://www.youtube.com/watch?v=verma_intro",
        date_of_birth=date(1955, 6, 10),
        description="70-year-old retired Indian gentleman with cheerful demeanor, neat white mustache, and glasses. Community leader organizing activities for seniors.",
        tags="group-admin,retired,community,indian",
        created_at=datetime.now(),
        updated_at=datetime.now(),
    ),
    # Additional test users for variety
    # Test Caregiver Two (ID 7)
    User(
        id=7,
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
    # Test Family Member Two (ID 8)
    User(
        id=8,
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
    # Test Senior Citizen Two (ID 9)
    User(
        id=9,
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
    # Test Group Admin Two (ID 10)
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
    # Support users (IDs 11-12)
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

# Test tokens that map to test users (including story character tokens)
TEST_TOKENS = {
    # Admin tokens
    "test_admin_token_001": "qEGg9NTOjfgSaw646IhSRCXKtaZ2",
    "test_admin_token_002": "4N2P7ZAWGPgXXoQmp2YAKXJTw253",
    # Story character tokens
    "story_asha_token_001": "story_asha_uid_001",
    "story_rohan_token_001": "story_rohan_uid_001",
    "story_priya_token_001": "story_priya_uid_001",
    "story_verma_token_001": "story_verma_uid_001",
    # Additional test user tokens (including backward compatibility)
    "test_caregiver_token_001": "story_priya_uid_001",  # Maps to Priya for backward compatibility
    "test_caregiver_token_002": "test_caregiver_uid_002",
    "test_family_token_001": "story_rohan_uid_001",  # Maps to Rohan for backward compatibility
    "test_family_token_002": "test_family_uid_002",
    "test_senior_token_001": "story_asha_uid_001",  # Maps to Asha for backward compatibility
    "test_senior_token_002": "test_senior_uid_002",
    "test_groupadmin_token_001": "story_verma_uid_001",  # Maps to Mr. Verma for backward compatibility
    "test_groupadmin_token_002": "test_groupadmin_uid_002",
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
