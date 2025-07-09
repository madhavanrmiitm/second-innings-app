from typing import Optional, Tuple, Union

import firebase_admin
from app.config import settings
from app.database.db import get_db_connection
from app.logger import logger
from app.payloads import RegistrationRequest, UnregisteredUser, User, UserCreateRequest
from firebase_admin import auth, credentials


class AuthService:
    def __init__(self):
        """Initialize Firebase Admin SDK."""
        if not firebase_admin._apps:
            cred = credentials.Certificate(settings.FIREBASE_ADMIN_SDK_PATH)
            firebase_admin.initialize_app(cred)
        logger.info("Firebase Admin SDK initialized")

    def verify_id_token(self, id_token: str) -> dict:
        """
        Verify Firebase ID token and return decoded token.

        Args:
            id_token: The Firebase ID token to verify

        Returns:
            Decoded token containing user information

        Raises:
            ValueError: If token is invalid
        """
        try:
            decoded_token = auth.verify_id_token(id_token)
            logger.info(f"Token verified for user: {decoded_token.get('uid')}")
            return decoded_token
        except Exception as e:
            logger.error(f"Token verification failed: {e}")
            raise ValueError("Invalid token")

    def get_user_by_firebase_uid(self, firebase_uid: str) -> Optional[User]:
        """
        Retrieve user from database by Firebase UID.

        Args:
            firebase_uid: The Firebase UID to search for

        Returns:
            User object if found, None otherwise
        """
        try:
            with get_db_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute(
                        """SELECT id, gmail_id, firebase_uid, full_name, role, youtube_url, date_of_birth, description, tags, created_at, updated_at
                           FROM users WHERE firebase_uid = %s""",
                        (firebase_uid,),
                    )
                    user_data = cur.fetchone()

                    if user_data:
                        return User(
                            id=user_data[0],
                            gmail_id=user_data[1],
                            firebase_uid=user_data[2],
                            full_name=user_data[3],
                            role=user_data[4],
                            youtube_url=user_data[5],
                            date_of_birth=user_data[6],
                            description=user_data[7],
                            tags=user_data[8],
                            created_at=user_data[9],
                            updated_at=user_data[10],
                        )
                    return None
        except Exception as e:
            logger.error(f"Error retrieving user: {e}")
            raise

    def create_user(self, user_data: UserCreateRequest) -> User:
        """
        Create a new user in the database.

        Args:
            user_data: The user data to create

        Returns:
            The created User object
        """
        try:
            with get_db_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute(
                        """INSERT INTO users (gmail_id, firebase_uid, full_name, role)
                           VALUES (%s, %s, %s, %s)
                           RETURNING id, gmail_id, firebase_uid, full_name, role, youtube_url, date_of_birth, description, tags, created_at, updated_at""",
                        (
                            user_data.gmail_id,
                            user_data.firebase_uid,
                            user_data.full_name,
                            user_data.role,
                        ),
                    )
                    created_user = cur.fetchone()

                    if created_user:
                        logger.info(f"User created with ID: {created_user[0]}")
                        return User(
                            id=created_user[0],
                            gmail_id=created_user[1],
                            firebase_uid=created_user[2],
                            full_name=created_user[3],
                            role=created_user[4],
                            youtube_url=created_user[5],
                            date_of_birth=created_user[6],
                            description=created_user[7],
                            tags=created_user[8],
                            created_at=created_user[9],
                            updated_at=created_user[10],
                        )
                    raise Exception("Failed to create user")
        except Exception as e:
            logger.error(f"Error creating user: {e}")
            raise

    def authenticate_user(
        self, id_token: str
    ) -> Tuple[Union[User, UnregisteredUser], bool]:
        """
        Authenticate user using Firebase ID token.

        Args:
            id_token: The Firebase ID token

        Returns:
            Tuple of (User object if registered or UnregisteredUser if not, is_registered boolean)
        """
        # Verify the token
        decoded_token = self.verify_id_token(id_token)

        # Extract user information from token
        firebase_uid = decoded_token["uid"]
        email = decoded_token.get("email", "")
        name = decoded_token.get(
            "name", email.split("@")[0]
        )  # Fallback to email prefix if no name

        # Check if user exists
        existing_user = self.get_user_by_firebase_uid(firebase_uid)

        if existing_user:
            logger.info(f"Existing user found: {existing_user.gmail_id}")
            return existing_user, True
        else:
            # Return unregistered user info without creating in database
            unregistered_user = UnregisteredUser(
                firebase_uid=firebase_uid, gmail_id=email, full_name=name
            )
            logger.info(f"Unregistered user detected: {email}")
            return unregistered_user, False

    def register_user(self, registration_data: RegistrationRequest) -> User:
        """
        Register a new user with complete profile information.

        Args:
            registration_data: The registration data containing ID token and user details

        Returns:
            The created User object

        Raises:
            ValueError: If token is invalid or user already exists
        """
        # Verify the token
        decoded_token = self.verify_id_token(registration_data.id_token)

        # Extract user information from token
        firebase_uid = decoded_token["uid"]
        email = decoded_token.get("email", "")

        # Check if user already exists
        existing_user = self.get_user_by_firebase_uid(firebase_uid)
        if existing_user:
            raise ValueError("User already registered")

        try:
            with get_db_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute(
                        """INSERT INTO users (gmail_id, firebase_uid, full_name, role, youtube_url, date_of_birth, description, tags)
                           VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                           RETURNING id, gmail_id, firebase_uid, full_name, role, youtube_url, date_of_birth, description, tags, created_at, updated_at""",
                        (
                            email,
                            firebase_uid,
                            registration_data.full_name,
                            registration_data.role,
                            registration_data.youtube_url,
                            registration_data.date_of_birth,
                            registration_data.description,
                            registration_data.tags,
                        ),
                    )
                    created_user = cur.fetchone()

                    if created_user:
                        logger.info(f"User registered with ID: {created_user[0]}")
                        return User(
                            id=created_user[0],
                            gmail_id=created_user[1],
                            firebase_uid=created_user[2],
                            full_name=created_user[3],
                            role=created_user[4],
                            youtube_url=created_user[5],
                            date_of_birth=created_user[6],
                            description=created_user[7],
                            tags=created_user[8],
                            created_at=created_user[9],
                            updated_at=created_user[10],
                        )
                    raise Exception("Failed to register user")
        except Exception as e:
            logger.error(f"Error registering user: {e}")
            raise


# Singleton instance
auth_service = AuthService()
