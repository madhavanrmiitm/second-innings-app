from app.controllers import care as care_controller
from app.payloads import (
    AcceptCaregiverRequest,
    AcceptEngagement,
    ApplyCareRequest,
    CreateCareRequest,
    DeclineEngagement,
    RejectCaregiverRequest,
    RequestCaregiver,
    UpdateCareRequest,
)
from app.utils.request_validator import validate_body
from fastapi import APIRouter, Request

router = APIRouter()


@router.get("/care-requests")
async def view_open_requests(request: Request):
    return await care_controller.view_open_requests(request)


@router.get("/care-requests/{requestId}")
async def get_care_request(request: Request, requestId: int):
    return await care_controller.get_care_request(request, requestId)


@router.post("/care-requests")
@validate_body(CreateCareRequest)
async def create_care_request(request: Request, validated_data: CreateCareRequest):
    return await care_controller.create_care_request(request, validated_data)


@router.put("/care-requests/{requestId}")
@validate_body(UpdateCareRequest)
async def update_care_request(
    request: Request, requestId: int, validated_data: UpdateCareRequest
):
    return await care_controller.update_care_request(request, requestId, validated_data)


@router.post("/care-requests/{requestId}/close")
async def close_care_request(request: Request, requestId: int):
    return await care_controller.close_care_request(request, requestId)


@router.get("/caregivers")
async def get_caregivers(request: Request):
    return await care_controller.get_caregivers(request)


@router.get("/caregivers/{caregiverId}")
async def get_caregiver_profile(request: Request, caregiverId: int):
    return await care_controller.get_caregiver_profile(request, caregiverId)


@router.post("/caregivers/requests/{requestId}/apply")
@validate_body(ApplyCareRequest)
async def apply_for_request(
    request: Request, requestId: int, validated_data: ApplyCareRequest
):
    return await care_controller.apply_for_request(request, requestId, validated_data)


@router.post("/caregivers/engagements/{requestId}/accept")
@validate_body(AcceptEngagement)
async def accept_engagement(
    request: Request, requestId: int, validated_data: AcceptEngagement
):
    return await care_controller.accept_engagement(request, requestId, validated_data)


@router.post("/caregivers/engagements/{requestId}/decline")
@validate_body(DeclineEngagement)
async def decline_engagement(
    request: Request, requestId: int, validated_data: DeclineEngagement
):
    return await care_controller.decline_engagement(request, requestId, validated_data)


# Caregiver request endpoints for family members and senior citizens
@router.get("/me/caregiver-requests")
async def get_caregiver_requests(request: Request):
    return await care_controller.get_caregiver_requests(request)


@router.post("/me/request-caregiver")
@validate_body(RequestCaregiver)
async def request_caregiver(request: Request, validated_data: RequestCaregiver):
    return await care_controller.request_caregiver(request, validated_data)


@router.post("/me/accept-caregiver-request")
@validate_body(AcceptCaregiverRequest)
async def accept_caregiver_request(
    request: Request, validated_data: AcceptCaregiverRequest
):
    return await care_controller.accept_caregiver_request(request, validated_data)


@router.post("/me/reject-caregiver-request")
@validate_body(RejectCaregiverRequest)
async def reject_caregiver_request(
    request: Request, validated_data: RejectCaregiverRequest
):
    return await care_controller.reject_caregiver_request(request, validated_data)


@router.get("/me/current-caregiver")
async def get_current_caregiver(request: Request):
    return await care_controller.get_current_caregiver(request)


@router.get("/senior-citizens/{senior_citizen_id}/caregivers")
async def get_caregivers_for_senior_citizen(request: Request, senior_citizen_id: int):
    return await care_controller.get_caregivers_for_senior_citizen(
        request, senior_citizen_id
    )


@router.get("/senior-citizens/{senior_citizen_id}/current-caregiver")
async def get_current_caregiver_for_senior_citizen(
    request: Request, senior_citizen_id: int
):
    return await care_controller.get_current_caregiver_for_senior_citizen(
        request, senior_citizen_id
    )


@router.get("/senior-citizens/{senior_citizen_id}/caregiver-requests")
async def get_caregiver_requests_for_senior_citizen(
    request: Request, senior_citizen_id: int
):
    return await care_controller.get_caregiver_requests_for_senior_citizen(
        request, senior_citizen_id
    )


@router.post("/senior-citizens/{senior_citizen_id}/request-caregiver")
@validate_body(RequestCaregiver)
async def request_caregiver_for_senior_citizen(
    request: Request, senior_citizen_id: int, validated_data: RequestCaregiver
):
    return await care_controller.request_caregiver_for_senior_citizen(
        request, senior_citizen_id, validated_data
    )
