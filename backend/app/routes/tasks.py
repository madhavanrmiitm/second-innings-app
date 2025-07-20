from app.controllers import tasks as tasks_controller
from app.payloads import (
    CreateReminder,
    CreateTask,
    TokenRequest,
    UpdateReminder,
    UpdateTask,
)
from app.utils.request_validator import validate_body
from fastapi import APIRouter, Request

router = APIRouter()


@router.get("/tasks")
async def get_tasks(request: Request):
    return await tasks_controller.get_tasks(request)


@router.post("/tasks")
@validate_body(CreateTask)
async def create_task(request: Request, validated_data: CreateTask):
    return await tasks_controller.create_task(request, validated_data)


@router.get("/tasks/{taskId}")
async def get_task(request: Request, taskId: int):
    return await tasks_controller.get_task(request, taskId)


@router.put("/tasks/{taskId}")
@validate_body(UpdateTask)
async def update_task(request: Request, taskId: int, validated_data: UpdateTask):
    return await tasks_controller.update_task(request, taskId, validated_data)


@router.post("/tasks/{taskId}/complete")
@validate_body(TokenRequest)
async def mark_task_done(request: Request, taskId: int, validated_data: TokenRequest):
    return await tasks_controller.mark_task_done(request, taskId, validated_data)


@router.delete("/tasks/{taskId}")
@validate_body(TokenRequest)
async def delete_task(request: Request, taskId: int, validated_data: TokenRequest):
    return await tasks_controller.delete_task(request, taskId, validated_data)


@router.get("/reminders")
async def get_reminders(request: Request):
    return await tasks_controller.get_reminders(request)


@router.post("/reminders")
@validate_body(CreateReminder)
async def create_reminder(request: Request, validated_data: CreateReminder):
    return await tasks_controller.create_reminder(request, validated_data)


@router.put("/reminders/{reminderId}")
@validate_body(UpdateReminder)
async def update_reminder(
    request: Request, reminderId: int, validated_data: UpdateReminder
):
    return await tasks_controller.update_reminder(request, reminderId, validated_data)


@router.post("/reminders/{reminderId}/snooze")
@validate_body(TokenRequest)
async def snooze_reminder(
    request: Request, reminderId: int, validated_data: TokenRequest
):
    return await tasks_controller.snooze_reminder(request, reminderId, validated_data)


@router.delete("/reminders/{reminderId}")
@validate_body(TokenRequest)
async def cancel_reminder(
    request: Request, reminderId: int, validated_data: TokenRequest
):
    return await tasks_controller.cancel_reminder(request, reminderId, validated_data)
