from typing import Optional, Tuple, Union

from app.logger import logger
from app.payloads import (
    RegistrationRequest,
    UnregisteredUser,
    User,
    UserRole,
    UserStatus,
)

from .test_data import (
    TEST_TOKENS,
    TEST_UNREGISTERED_TOKENS,
    TEST_UNREGISTERED_USERS,
    TEST_USERS_BY_EMAIL,
    TEST_USERS_BY_UID,
)


class TestAuthService:
    """
    Test authentication service that bypasses Firebase authentication.
    Uses predefined test users and tokens for local development and testing.
    """

    def __init__(self):
        """Initialize test auth service."""
        logger.info("Test Auth Service initialized - Firebase authentication bypassed")

    def verify_id_token(self, id_token: str) -> dict:
        """
        Mock Firebase ID token verification using predefined test tokens.

        Args:
            id_token: The test token to verify

        Returns:
            Mocked decoded token containing user information

        Raises:
            ValueError: If token is not a valid test token
        """
        try:
            # Check if token is in our test tokens
            if id_token in TEST_TOKENS:
                firebase_uid = TEST_TOKENS[id_token]
                user = TEST_USERS_BY_UID.get(firebase_uid)
                if user:
                    decoded_token = {
                        "uid": user.firebase_uid,
                        "email": user.gmail_id,
                        "name": user.full_name,
                        "iss": "test-issuer",
                        "aud": "test-audience",
                        "auth_time": 1234567890,
                        "user_id": user.firebase_uid,
                        "sub": user.firebase_uid,
                        "iat": 1234567890,
                        "exp": 9999999999,
                        "firebase": {
                            "identities": {"email": [user.gmail_id]},
                            "sign_in_provider": "password",
                        },
                    }
                    logger.info(f"Test token verified for user: {user.firebase_uid}")
                    return decoded_token

            # Check if token is for unregistered users
            if id_token in TEST_UNREGISTERED_TOKENS:
                firebase_uid = TEST_UNREGISTERED_TOKENS[id_token]
                unregistered_user = next(
                    (
                        u
                        for u in TEST_UNREGISTERED_USERS
                        if u.firebase_uid == firebase_uid
                    ),
                    None,
                )
                if unregistered_user:
                    decoded_token = {
                        "uid": unregistered_user.firebase_uid,
                        "email": unregistered_user.gmail_id,
                        "name": unregistered_user.full_name,
                        "iss": "test-issuer",
                        "aud": "test-audience",
                        "auth_time": 1234567890,
                        "user_id": unregistered_user.firebase_uid,
                        "sub": unregistered_user.firebase_uid,
                        "iat": 1234567890,
                        "exp": 9999999999,
                        "firebase": {
                            "identities": {"email": [unregistered_user.gmail_id]},
                            "sign_in_provider": "password",
                        },
                    }
                    logger.info(
                        f"Test token verified for unregistered user: {unregistered_user.firebase_uid}"
                    )
                    return decoded_token

            # Token not found in test data
            logger.error(f"Invalid test token: {id_token}")
            raise ValueError("Invalid test token")

        except Exception as e:
            logger.error(f"Test token verification failed: {e}")
            raise ValueError("Invalid token")

    def get_user_by_firebase_uid(self, firebase_uid: str) -> Optional[User]:
        """
        Retrieve user from test data by Firebase UID.

        Args:
            firebase_uid: The Firebase UID to search for

        Returns:
            User object if found in test data, None otherwise
        """
        try:
            user = TEST_USERS_BY_UID.get(firebase_uid)
            if user:
                logger.info(f"Test user found: {user.gmail_id}")
                return user
            logger.info(f"Test user not found for UID: {firebase_uid}")
            return None
        except Exception as e:
            logger.error(f"Error retrieving test user: {e}")
            raise

    def authenticate_user(
        self, id_token: str
    ) -> Tuple[Union[User, UnregisteredUser], bool]:
        """
        Authenticate user using test token (bypasses Firebase).

        Args:
            id_token: The test ID token

        Returns:
            Tuple of (User object if registered or UnregisteredUser if not, is_registered boolean)
        """
        # Verify the test token
        decoded_token = self.verify_id_token(id_token)

        # Extract user information from test token
        firebase_uid = decoded_token["uid"]
        email = decoded_token.get("email", "")
        name = decoded_token.get("name", email.split("@")[0])

        # Check if user exists in test data
        existing_user = self.get_user_by_firebase_uid(firebase_uid)

        if existing_user:
            logger.info(f"Existing test user authenticated: {existing_user.gmail_id}")
            return existing_user, True
        else:
            # Check if this is a known unregistered test user
            unregistered_user = next(
                (u for u in TEST_UNREGISTERED_USERS if u.firebase_uid == firebase_uid),
                None,
            )

            if unregistered_user:
                logger.info(
                    f"Unregistered test user detected: {unregistered_user.gmail_id}"
                )
                return unregistered_user, False
            else:
                # Create a new unregistered user for unknown test tokens
                unregistered_user = UnregisteredUser(
                    firebase_uid=firebase_uid, gmail_id=email, full_name=name
                )
                logger.info(f"New unregistered test user created: {email}")
                return unregistered_user, False

    def register_user(self, registration_data: RegistrationRequest) -> User:
        """
        Mock user registration for test mode.
        In test mode, we don't actually create users in database,
        but return a mock registered user.

        Args:
            registration_data: The registration data containing ID token and user details

        Returns:
            The mocked created User object

        Raises:
            ValueError: If token is invalid or user already exists in test data
        """
        # Verify the test token
        decoded_token = self.verify_id_token(registration_data.id_token)

        # Extract user information from token
        firebase_uid = decoded_token["uid"]
        email = decoded_token.get("email", "")

        # Check if user already exists in test data
        existing_user = self.get_user_by_firebase_uid(firebase_uid)
        if existing_user:
            raise ValueError("User already registered")

        # Determine status based on role
        if registration_data.role in [
            UserRole.CAREGIVER,
            UserRole.INTEREST_GROUP_ADMIN,
        ]:
            user_status = UserStatus.PENDING_APPROVAL
        else:
            user_status = UserStatus.ACTIVE

        # Create a mock registered user (not saved to database in test mode)
        from datetime import datetime

        mock_user = User(
            id=999,  # Mock ID
            gmail_id=email,
            firebase_uid=firebase_uid,
            full_name=registration_data.full_name,
            role=registration_data.role,
            status=user_status,
            youtube_url=registration_data.youtube_url,
            date_of_birth=registration_data.date_of_birth,
            description=registration_data.description,
            tags=registration_data.tags,
            created_at=datetime.now(),
            updated_at=datetime.now(),
        )

        logger.info(
            f"Mock user registration completed for: {registration_data.full_name} with status: {user_status}"
        )
        logger.warning("Test mode: User not actually saved to database")

        return mock_user


# Singleton instance for test auth service
test_auth_service = TestAuthService()
