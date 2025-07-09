from app.logger import logger
from app.modules.auth.auth_service import auth_service
from app.payloads import AuthResponse, TokenRequest, UnregisteredUserResponse, User
from app.utils.response_formatter import format_response


async def authenticate_user(request, validated_data: TokenRequest):
    """
    Controller logic to authenticate a user using Firebase ID token.

    Args:
        request: The FastAPI request object
        validated_data: TokenRequest containing the ID token

    Returns:
        Response with status code 200 (existing user) or 201 (new user)
    """
    logger.info("Executing user authentication controller logic.")

    try:
        # Authenticate user using the auth service
        user_or_info, is_registered = auth_service.authenticate_user(
            validated_data.id_token
        )

        if is_registered:
            # User exists in database - return 200
            auth_response = AuthResponse(user=user_or_info, is_new_user=False)
            return format_response(
                status_code=200,
                message="User authenticated successfully.",
                data=auth_response.model_dump(),
            )
        else:
            # User not in database - return 201 with user info only
            unregistered_response = UnregisteredUserResponse(user_info=user_or_info)
            return format_response(
                status_code=201,
                message="User verified but not registered in system.",
                data=unregistered_response.model_dump(),
            )

    except ValueError as e:
        # Token verification failed
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )

    except Exception as e:
        # Other errors (database, etc.)
        logger.error(f"Error during authentication: {e}")
        return format_response(
            status_code=500, message="Internal server error during authentication."
        )
