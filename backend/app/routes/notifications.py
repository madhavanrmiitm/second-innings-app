from fastapi import APIRouter, Request
from app.controllers import notifications as notifications_controller
from app.payloads import TokenRequest, MarkNotificationAsRead
from app.utils.request_validator import validate_body

router = APIRouter()

@router.get("/notifications")
async def get_notifications(request: Request):
    return await notifications_controller.get_notifications(request)

@router.post("/notifications/{notificationId}/read")
@validate_body(MarkNotificationAsRead)
async def mark_as_read(request: Request, notificationId: int, validated_data: MarkNotificationAsRead):
    return await notifications_controller.mark_as_read(request, notificationId, validated_data)