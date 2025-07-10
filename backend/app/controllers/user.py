from app.logger import logger
from app.modules.auth.auth_service import auth_service
from app.payloads import ProfileResponse, TokenRequest
from app.utils.response_formatter import format_response


async def get_profile(_, validated_data: TokenRequest):
    """
    Controller logic to get user profile using Firebase ID token.

    Args:
        request: The FastAPI request object
        validated_data: TokenRequest containing the ID token

    Returns:
        Response with status code 200 (user profile) or error codes
    """
    logger.info("Executing get user profile controller logic.")

    try:
        # Authenticate user using the auth service
        user_or_info, is_registered = auth_service.authenticate_user(
            validated_data.id_token
        )

        if is_registered:
            # User exists in database - return profile
            profile_response = ProfileResponse(user=user_or_info)
            return format_response(
                status_code=200,
                message="User profile retrieved successfully.",
                data=profile_response.model_dump(),
            )
        else:
            # User not in database - return 404
            return format_response(
                status_code=404,
                message="User not found. Please register first.",
            )

    except ValueError as e:
        # Token verification failed
        logger.error(f"Profile retrieval failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )

    except Exception as e:
        # Other errors (database, etc.)
        logger.error(f"Error during profile retrieval: {e}")
        return format_response(
            status_code=500, message="Internal server error during profile retrieval."
        )
