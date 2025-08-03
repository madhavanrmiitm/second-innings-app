from app.controllers import admin as admin_controller
from app.payloads import ResolveTicket, ReviewCaregiver, TokenRequest
from app.utils.request_validator import validate_body
from fastapi import APIRouter, Request

router = APIRouter()


@router.get("/admin/users")
async def get_system_users(request: Request):
    return await admin_controller.get_system_users(request)


@router.delete("/admin/users/{userId}")
@validate_body(TokenRequest)
async def delete_user(request: Request, userId: int, validated_data: TokenRequest):
    return await admin_controller.delete_user(request, userId, validated_data)


@router.get("/admin/caregivers")
async def get_caregivers_for_review(request: Request):
    return await admin_controller.get_caregivers_for_review(request)


@router.post("/admin/caregivers/{caregiverId}/verify")
@validate_body(ReviewCaregiver)
async def review_caregiver(
    request: Request, caregiverId: int, validated_data: ReviewCaregiver
):
    return await admin_controller.review_caregiver(request, caregiverId, validated_data)


@router.get("/admin/interest-group-admins")
async def get_interest_group_admins_for_review(request: Request):
    return await admin_controller.get_interest_group_admins_for_review(request)


@router.post("/admin/interest-group-admins/{interestGroupAdminId}/verify")
@validate_body(ReviewCaregiver)
async def review_interest_group_admin(
    request: Request, interestGroupAdminId: int, validated_data: ReviewCaregiver
):
    return await admin_controller.review_interest_group_admin(
        request, interestGroupAdminId, validated_data
    )


@router.get("/admin/tickets")
async def get_tickets_for_support(request: Request):
    return await admin_controller.get_tickets_for_support(request)


@router.post("/admin/tickets/{ticketId}/resolve")
@validate_body(ResolveTicket)
async def resolve_ticket(
    request: Request, ticketId: int, validated_data: ResolveTicket
):
    return await admin_controller.resolve_ticket(request, ticketId, validated_data)


@router.get("/admin/tickets/stats")
async def get_ticket_stats(request: Request):
    return await admin_controller.get_ticket_stats(request)
