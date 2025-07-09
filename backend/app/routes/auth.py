from app.controllers import auth as auth_controller
from app.payloads import TokenRequest
from app.utils.request_validator import validate_body
from fastapi import APIRouter, Request
from fastapi.responses import JSONResponse

router = APIRouter()


@router.post("/auth/verify-token", response_class=JSONResponse)
@validate_body(TokenRequest)
async def verify_token(request: Request, validated_data: TokenRequest):
    """
    Verify Firebase ID token and authenticate user.

    Returns:
        200: Existing user authenticated
        201: New user created and authenticated
        401: Invalid token
        500: Server error
    """
    return await auth_controller.authenticate_user(request, validated_data)
