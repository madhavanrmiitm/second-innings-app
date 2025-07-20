from fastapi import APIRouter, Request
from app.controllers import family as family_controller
from app.payloads import TokenRequest, AddFamilyMemberRequest, RemoveFamilyMemberRequest
from app.utils.request_validator import validate_body

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
async def remove_family_member(request: Request, memberId: int, validated_data: RemoveFamilyMemberRequest):
    return await family_controller.remove_family_member(request, memberId, validated_data)