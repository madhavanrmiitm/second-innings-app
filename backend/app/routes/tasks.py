from app.controllers import tasks as tasks_controller
from app.payloads import CreateTask, TokenRequest, UpdateTask
from app.utils.request_validator import validate_body
from fastapi import APIRouter, Request

router = APIRouter()


@router.get("/tasks")
async def get_tasks(request: Request):
    """
    Get tasks for the authenticated user.

    For family members, you can optionally pass a 'senior_citizen_id' query parameter
    to get tasks related to a specific senior citizen they are linked to.

    Example: GET /tasks?senior_citizen_id=9
    """
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
