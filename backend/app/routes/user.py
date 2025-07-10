from app.controllers import user as user_controller
from app.payloads import TokenRequest
from app.utils.request_validator import validate_body
from fastapi import APIRouter, Request
from fastapi.responses import JSONResponse

router = APIRouter()


@router.post("/user/profile", response_class=JSONResponse)
@validate_body(TokenRequest)
async def get_profile(request: Request, validated_data: TokenRequest):
    """
    Get user profile information using Firebase ID token.

    Returns:
        200: User profile retrieved successfully
        401: Invalid token
        404: User not found (not registered)
        500: Server error
    """
    return await user_controller.get_profile(request, validated_data)
