from app.controllers import family as family_controller
from app.payloads import (
    AddFamilyMemberRequest,
    LinkSeniorCitizenRequest,
    RemoveFamilyMemberRequest,
    TokenRequest,
)
from app.utils.request_validator import validate_body
from fastapi import APIRouter, Request

router = APIRouter()


@router.get("/senior-citizens/me/family-members")
async def get_family_members(request: Request):
    return await family_controller.get_family_members(request)


@router.post("/senior-citizens/me/family-members")
@validate_body(AddFamilyMemberRequest)
async def add_family_member(request: Request, validated_data: AddFamilyMemberRequest):
    return await family_controller.add_family_member(request, validated_data)


@router.delete("/senior-citizens/me/family-members/{memberId}")
@validate_body(RemoveFamilyMemberRequest)
async def remove_family_member(
    request: Request, memberId: int, validated_data: RemoveFamilyMemberRequest
):
    return await family_controller.remove_family_member(
        request, memberId, validated_data
    )


# Family member endpoints for managing linked senior citizens
@router.get("/family-members/me/linked-senior-citizens")
async def get_linked_senior_citizens(request: Request):
    return await family_controller.get_linked_senior_citizens(request)


@router.post("/family-members/me/link-senior-citizen")
@validate_body(LinkSeniorCitizenRequest)
async def link_senior_citizen(
    request: Request, validated_data: LinkSeniorCitizenRequest
):
    return await family_controller.link_senior_citizen(request, validated_data)
