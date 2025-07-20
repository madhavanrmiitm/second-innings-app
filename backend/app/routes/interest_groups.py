from app.controllers import interest_groups as interest_groups_controller
from app.payloads import CreateInterestGroup, TokenRequest, UpdateInterestGroup
from app.utils.request_validator import validate_body
from fastapi import APIRouter, Request

router = APIRouter()


@router.get("/interest-groups")
async def get_interest_groups(request: Request):
    return await interest_groups_controller.get_interest_groups(request)


@router.post("/interest-groups")
@validate_body(CreateInterestGroup)
async def create_interest_group(request: Request, validated_data: CreateInterestGroup):
    return await interest_groups_controller.create_interest_group(
        request, validated_data
    )


@router.get("/interest-groups/{groupId}")
async def get_interest_group(request: Request, groupId: int):
    return await interest_groups_controller.get_interest_group(request, groupId)


@router.put("/interest-groups/{groupId}")
@validate_body(UpdateInterestGroup)
async def update_interest_group(
    request: Request, groupId: int, validated_data: UpdateInterestGroup
):
    return await interest_groups_controller.update_interest_group(
        request, groupId, validated_data
    )


@router.post("/interest-groups/{groupId}/join")
@validate_body(TokenRequest)
async def join_interest_group(
    request: Request, groupId: int, validated_data: TokenRequest
):
    return await interest_groups_controller.join_interest_group(
        request, groupId, validated_data
    )


@router.post("/interest-groups/{groupId}/leave")
@validate_body(TokenRequest)
async def leave_interest_group(
    request: Request, groupId: int, validated_data: TokenRequest
):
    return await interest_groups_controller.leave_interest_group(
        request, groupId, validated_data
    )
