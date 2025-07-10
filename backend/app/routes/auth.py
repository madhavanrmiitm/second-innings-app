from app.controllers import auth as auth_controller
from app.payloads import RegistrationRequest, TokenRequest
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


@router.post("/auth/register", response_class=JSONResponse)
@validate_body(RegistrationRequest)
async def register_user(request: Request, validated_data: RegistrationRequest):
    """
    Register a new user with complete profile information.

    Returns:
        201: User registered successfully
        401: Invalid token
        409: User already registered
        500: Server error
    """
    return await auth_controller.register_user(request, validated_data)
