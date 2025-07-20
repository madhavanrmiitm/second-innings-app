from app.controllers import tickets as tickets_controller
from app.payloads import CreateTicket, TokenRequest, UpdateTicket
from app.utils.request_validator import validate_body
from fastapi import APIRouter, Request

router = APIRouter()


@router.get("/tickets")
async def get_tickets(request: Request):
    return await tickets_controller.get_tickets(request)


@router.post("/tickets")
@validate_body(CreateTicket)
async def create_ticket(request: Request, validated_data: CreateTicket):
    return await tickets_controller.create_ticket(request, validated_data)


@router.get("/tickets/{ticketId}")
async def get_ticket(request: Request, ticketId: int):
    return await tickets_controller.get_ticket(request, ticketId)


@router.put("/tickets/{ticketId}")
@validate_body(UpdateTicket)
async def update_ticket(request: Request, ticketId: int, validated_data: UpdateTicket):
    return await tickets_controller.update_ticket(request, ticketId, validated_data)
