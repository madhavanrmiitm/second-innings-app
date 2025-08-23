from app.database.db import get_db_connection
from app.logger import logger
from app.modules.auth.auth_service import auth_service
from app.payloads import (
    AcceptCaregiverRequest,
    AcceptEngagement,
    ApplyCareRequest,
    CareRequestStatus,
    CreateCareRequest,
    DeclineEngagement,
    RejectCaregiverRequest,
    RequestCaregiver,
    UpdateCareRequest,
    UserRole,
    UserStatus,
)
from app.utils.response_formatter import format_response


def check_duplicate_care_request(cursor, senior_citizen_id, caregiver_id, made_by):
    """
    Check for duplicate care requests based on business rules:
    - PENDING/ACCEPTED: No duplicates allowed
    - CANCELLED: Can create new (duplicate allowed)
    - REJECTED: Can create new up to 3 times maximum
    """
    # Check for existing PENDING or ACCEPTED requests (no duplicates allowed)
    cursor.execute(
        """SELECT id, status FROM care_requests
           WHERE senior_citizen_id = %s AND caregiver_id = %s AND made_by = %s
           AND status IN ('pending', 'accepted')""",
        (senior_citizen_id, caregiver_id, made_by),
    )
    active_requests = cursor.fetchall()

    if active_requests:
        return (
            False,
            f"Duplicate care request not allowed. You already have a {active_requests[0][1]} request with this caregiver.",
        )

    # Check for REJECTED requests (max 3 times)
    cursor.execute(
        """SELECT COUNT(*) FROM care_requests
           WHERE senior_citizen_id = %s AND caregiver_id = %s AND made_by = %s
           AND status = 'rejected'""",
        (senior_citizen_id, caregiver_id, made_by),
    )
    rejected_count = cursor.fetchone()[0]

    if rejected_count >= 3:
        return (
            False,
            "Maximum limit of 3 rejected requests with this caregiver reached. Cannot create new request.",
        )

    # CANCELLED requests are allowed to create new ones
    return True, None


async def view_open_requests(request):
    logger.info("Executing view_open_requests controller logic.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role != UserRole.CAREGIVER:
            return format_response(
                status_code=403,
                message="Access denied. Only caregivers can view care requests.",
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Get all care requests for this caregiver, grouped by senior citizen and sorted by latest first
                cur.execute(
                    """SELECT
                           cr.id,
                           cr.senior_citizen_id,
                           sc.full_name as senior_citizen_name,
                           cr.status,
                           cr.timing_to_visit,
                           cr.location,
                           cr.created_at,
                           cr.updated_at,
                           cr.made_by,
                           u.full_name as requester_name
                       FROM care_requests cr
                       JOIN users sc ON cr.senior_citizen_id = sc.id
                       JOIN users u ON cr.made_by = u.id
                       WHERE cr.caregiver_id = %s
                       ORDER BY cr.senior_citizen_id, cr.created_at DESC""",
                    (user.id,),
                )
                all_requests_data = cur.fetchall()

                # Group requests by senior citizen
                grouped_requests = {}
                for req in all_requests_data:
                    senior_citizen_id = req[1]
                    if senior_citizen_id not in grouped_requests:
                        grouped_requests[senior_citizen_id] = {
                            "senior_citizen_id": senior_citizen_id,
                            "senior_citizen_name": req[2],
                            "requests": [],
                        }

                    grouped_requests[senior_citizen_id]["requests"].append(
                        {
                            "id": req[0],
                            "status": req[3],
                            "timing_to_visit": req[4],
                            "location": req[5],
                            "created_at": req[6],
                            "updated_at": req[7],
                            "made_by": req[8],
                            "requester_name": req[9],
                        }
                    )

                # Convert to list and sort by latest request first
                result = list(grouped_requests.values())
                result.sort(key=lambda x: x["requests"][0]["created_at"], reverse=True)

        return format_response(
            status_code=200,
            message="Care requests retrieved successfully.",
            data={"care_requests": result},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving care requests: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def get_caregiver_requests(request):
    logger.info("Executing get_caregiver_requests controller logic.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role not in [
            UserRole.FAMILY_MEMBER,
            UserRole.SENIOR_CITIZEN,
        ]:
            return format_response(
                status_code=403,
                message="Access denied. Only family members and senior citizens can view caregiver requests.",
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                if user.role == UserRole.FAMILY_MEMBER:
                    logger.info(
                        f"Family member {user.id} requesting caregiver requests"
                    )

                    # Get sent requests (requests made by this family member)
                    cur.execute(
                        """SELECT cr.id, cr.caregiver_id, cg.full_name as caregiver_name, cr.status, cr.created_at,
                                  cr.senior_citizen_id, sc.full_name as senior_citizen_name
                           FROM care_requests cr
                           JOIN users cg ON cr.caregiver_id = cg.id
                           LEFT JOIN users sc ON cr.senior_citizen_id = sc.id
                           WHERE cr.made_by = %s""",
                        (user.id,),
                    )
                    sent_requests_data = cur.fetchall()
                    logger.info(
                        f"Found {len(sent_requests_data)} sent requests for family member {user.id}"
                    )

                    sent_requests = [
                        {
                            "id": req[0],
                            "caregiver_id": req[1],
                            "caregiver_name": req[2],
                            "status": req[3],
                            "created_at": req[4],
                            "senior_citizen_id": req[5],
                            "senior_citizen_name": req[6],
                        }
                        for req in sent_requests_data
                    ]

                    # Get received requests (requests for senior citizens linked to this family member)
                    cur.execute(
                        """SELECT cr.id, cr.caregiver_id, cg.full_name as caregiver_name, cr.status, cr.created_at,
                                  cr.senior_citizen_id, sc.full_name as senior_citizen_name
                           FROM care_requests cr
                           JOIN users cg ON cr.caregiver_id = cg.id
                           JOIN users sc ON cr.senior_citizen_id = sc.id
                           JOIN relations r ON cr.senior_citizen_id = r.senior_citizen_id
                           WHERE r.family_member_id = %s AND cr.made_by != %s""",
                        (user.id, user.id),
                    )
                    received_requests_data = cur.fetchall()
                    logger.info(
                        f"Found {len(received_requests_data)} received requests for family member {user.id}"
                    )

                    received_requests = [
                        {
                            "id": req[0],
                            "caregiver_id": req[1],
                            "caregiver_name": req[2],
                            "status": req[3],
                            "created_at": req[4],
                            "senior_citizen_id": req[5],
                            "senior_citizen_name": req[6],
                        }
                        for req in received_requests_data
                    ]
                else:  # SENIOR_CITIZEN
                    logger.info(
                        f"Senior citizen {user.id} requesting caregiver requests"
                    )

                    # Get sent requests (requests made by this senior citizen)
                    cur.execute(
                        """SELECT cr.id, cr.caregiver_id, cg.full_name as caregiver_name, cr.status, cr.created_at
                           FROM care_requests cr
                           JOIN users cg ON cr.caregiver_id = cg.id
                           WHERE cr.made_by = %s""",
                        (user.id,),
                    )
                    sent_requests_data = cur.fetchall()
                    logger.info(
                        f"Found {len(sent_requests_data)} sent requests for senior citizen {user.id}"
                    )

                    sent_requests = [
                        {
                            "id": req[0],
                            "caregiver_id": req[1],
                            "caregiver_name": req[2],
                            "status": req[3],
                            "created_at": req[4],
                        }
                        for req in sent_requests_data
                    ]

                    # Get received requests (requests for this senior citizen)
                    cur.execute(
                        """SELECT cr.id, cr.caregiver_id, cg.full_name as caregiver_name, cr.status, cr.created_at
                           FROM care_requests cr
                           JOIN users cg ON cr.caregiver_id = cg.id
                           WHERE cr.senior_citizen_id = %s AND cr.made_by != %s""",
                        (user.id, user.id),
                    )
                    received_requests_data = cur.fetchall()
                    logger.info(
                        f"Found {len(received_requests_data)} received requests for senior citizen {user.id}"
                    )

                    received_requests = [
                        {
                            "id": req[0],
                            "caregiver_id": req[1],
                            "caregiver_name": req[2],
                            "status": req[3],
                            "created_at": req[4],
                        }
                        for req in received_requests_data
                    ]

        # Log summary for debugging
        logger.info(
            f"Returning {len(sent_requests)} sent requests and {len(received_requests)} received requests for user {user.id} ({user.role.value})"
        )

        return format_response(
            status_code=200,
            message="Caregiver requests retrieved successfully.",
            data={
                "sent_requests": sent_requests,
                "received_requests": received_requests,
                "user_role": user.role.value,
                "user_id": user.id,
            },
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving caregiver requests: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def request_caregiver(request, validated_data):
    logger.info("Executing request_caregiver controller logic.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role not in [
            UserRole.FAMILY_MEMBER,
            UserRole.SENIOR_CITIZEN,
        ]:
            return format_response(
                status_code=403,
                message="Access denied. Only family members and senior citizens can request caregivers.",
            )

        caregiver_id = validated_data.caregiver_id
        message = validated_data.message

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Check if caregiver exists and is active
                cur.execute(
                    "SELECT id FROM users WHERE id = %s AND role = %s AND status = %s",
                    (caregiver_id, UserRole.CAREGIVER, UserStatus.ACTIVE),
                )
                if not cur.fetchone():
                    return format_response(
                        status_code=404, message="Caregiver not found or not available."
                    )

                # Check for duplicate care request
                senior_citizen_id = None
                if user.role == UserRole.FAMILY_MEMBER:
                    # For family members, we need to check against their linked senior citizens
                    cur.execute(
                        "SELECT senior_citizen_id FROM relations WHERE family_member_id = %s LIMIT 1",
                        (user.id,),
                    )
                    sc_data = cur.fetchone()
                    if sc_data:
                        senior_citizen_id = sc_data[0]
                else:
                    # For senior citizens, use their own ID
                    senior_citizen_id = user.id

                if senior_citizen_id:
                    is_duplicate, error_message = check_duplicate_care_request(
                        cur, senior_citizen_id, caregiver_id, user.id
                    )
                    if not is_duplicate:
                        return format_response(status_code=400, message=error_message)

                # Create care request
                if user.role == UserRole.FAMILY_MEMBER:
                    # Family member creates request without specific senior citizen
                    cur.execute(
                        """INSERT INTO care_requests (senior_citizen_id, made_by, caregiver_id, status, timing_to_visit, location, created_at)
                           VALUES (%s, %s, %s, %s, %s, %s, NOW()) RETURNING id""",
                        (
                            None,  # No specific senior citizen for direct caregiver requests
                            user.id,
                            caregiver_id,
                            CareRequestStatus.PENDING.value,
                            None,  # No specific timing for direct caregiver requests
                            "Home",  # Default location
                        ),
                    )
                else:  # SENIOR_CITIZEN
                    # Senior citizen creates request for themselves
                    cur.execute(
                        """INSERT INTO care_requests (senior_citizen_id, made_by, caregiver_id, status, timing_to_visit, location, created_at)
                           VALUES (%s, %s, %s, %s, %s, %s, NOW()) RETURNING id""",
                        (
                            user.id,  # Senior citizen ID
                            user.id,
                            caregiver_id,
                            CareRequestStatus.PENDING.value,
                            None,  # No specific timing for direct caregiver requests
                            "Home",  # Default location
                        ),
                    )
                request_id = cur.fetchone()[0]

        return format_response(
            status_code=201,
            message="Caregiver request created successfully.",
            data={"request_id": request_id},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error creating caregiver request: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def accept_caregiver_request(request, validated_data):
    logger.info("Executing accept_caregiver_request controller logic.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role not in [
            UserRole.FAMILY_MEMBER,
            UserRole.SENIOR_CITIZEN,
        ]:
            return format_response(
                status_code=403,
                message="Access denied. Only family members and senior citizens can accept caregiver requests.",
            )

        request_id = validated_data.request_id

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Check if request exists and user has permission to accept it
                if user.role == UserRole.FAMILY_MEMBER:
                    # Family member can accept requests for senior citizens they are related to
                    cur.execute(
                        """SELECT cr.id FROM care_requests cr
                           JOIN relations r ON cr.senior_citizen_id = r.senior_citizen_id
                           WHERE cr.id = %s AND r.family_member_id = %s""",
                        (request_id, user.id),
                    )
                else:  # SENIOR_CITIZEN
                    # Senior citizen can accept requests made for them
                    cur.execute(
                        """SELECT cr.id FROM care_requests cr
                           WHERE cr.id = %s AND cr.senior_citizen_id = %s""",
                        (request_id, user.id),
                    )

                if not cur.fetchone():
                    return format_response(
                        status_code=404,
                        message="Caregiver request not found or access denied.",
                    )

                # Update request status to accepted
                cur.execute(
                    "UPDATE care_requests SET status = %s WHERE id = %s",
                    (CareRequestStatus.ACCEPTED.value, request_id),
                )

        return format_response(
            status_code=200,
            message="Caregiver request accepted successfully.",
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error accepting caregiver request: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def reject_caregiver_request(request, validated_data):
    logger.info("Executing reject_caregiver_request controller logic.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role not in [
            UserRole.FAMILY_MEMBER,
            UserRole.SENIOR_CITIZEN,
        ]:
            return format_response(
                status_code=403,
                message="Access denied. Only family members and senior citizens can reject caregiver requests.",
            )

        request_id = validated_data.request_id

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Check if request exists and user has permission to reject it
                if user.role == UserRole.FAMILY_MEMBER:
                    # Family member can reject requests for senior citizens they are related to
                    cur.execute(
                        """SELECT cr.id FROM care_requests cr
                           JOIN relations r ON cr.senior_citizen_id = r.senior_citizen_id
                           WHERE cr.id = %s AND r.family_member_id = %s""",
                        (request_id, user.id),
                    )
                else:  # SENIOR_CITIZEN
                    # Senior citizen can reject requests made for them
                    cur.execute(
                        """SELECT cr.id FROM care_requests cr
                           WHERE cr.id = %s AND cr.senior_citizen_id = %s""",
                        (request_id, user.id),
                    )

                if not cur.fetchone():
                    return format_response(
                        status_code=404,
                        message="Caregiver request not found or access denied.",
                    )

                # Update request status to rejected
                cur.execute(
                    "UPDATE care_requests SET status = %s WHERE id = %s",
                    (CareRequestStatus.REJECTED.value, request_id),
                )

        return format_response(
            status_code=200,
            message="Caregiver request rejected successfully.",
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error rejecting caregiver request: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def get_current_caregiver(request):
    logger.info("Executing get_current_caregiver controller logic.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role not in [
            UserRole.FAMILY_MEMBER,
            UserRole.SENIOR_CITIZEN,
        ]:
            return format_response(
                status_code=403,
                message="Access denied. Only family members and senior citizens can view current caregiver.",
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                if user.role == UserRole.FAMILY_MEMBER:
                    # Get current caregiver for senior citizens linked to this family member
                    cur.execute(
                        """SELECT cg.id, cg.full_name, cg.gmail_id, cg.description, cg.tags
                           FROM care_requests cr
                           JOIN users cg ON cr.caregiver_id = cg.id
                           JOIN relations r ON cr.senior_citizen_id = r.senior_citizen_id
                           WHERE r.family_member_id = %s AND cr.status = %s""",
                        (user.id, CareRequestStatus.ACCEPTED.value),
                    )
                else:  # SENIOR_CITIZEN
                    # Get current caregiver for this senior citizen
                    cur.execute(
                        """SELECT cg.id, cg.full_name, cg.gmail_id, cg.description, cg.tags
                           FROM care_requests cr
                           JOIN users cg ON cr.caregiver_id = cg.id
                           WHERE cr.senior_citizen_id = %s AND cr.status = %s""",
                        (user.id, CareRequestStatus.ACCEPTED.value),
                    )

                caregiver_data = cur.fetchone()

                if not caregiver_data:
                    return format_response(
                        status_code=404, message="No current caregiver found."
                    )

                caregiver = {
                    "id": caregiver_data[0],
                    "full_name": caregiver_data[1],
                    "gmail_id": caregiver_data[2],
                    "description": caregiver_data[3],
                    "tags": caregiver_data[4].split(",") if caregiver_data[4] else [],
                }

        return format_response(
            status_code=200,
            message="Current caregiver retrieved successfully.",
            data=caregiver,
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving current caregiver: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def get_care_request(request, requestId):
    logger.info(
        f"Executing get_care_request controller logic for request ID: {requestId}."
    )
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered:
            return format_response(status_code=401, message="User not registered.")

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """SELECT cr.id, cr.senior_citizen_id, sc.full_name as senior_citizen_name, cr.caregiver_id, cg.full_name as caregiver_name, cr.made_by, mb.full_name as made_by_name, cr.status, cr.timing_to_visit, cr.location, cr.created_at, cr.updated_at
                       FROM care_requests cr
                       JOIN users sc ON cr.senior_citizen_id = sc.id
                       LEFT JOIN users cg ON cr.caregiver_id = cg.id
                       JOIN users mb ON cr.made_by = mb.id
                       WHERE cr.id = %s""",
                    (requestId,),
                )
                care_request_data = cur.fetchone()

                if not care_request_data:
                    return format_response(
                        status_code=404, message="Care request not found."
                    )

                # Check permissions
                if (
                    user.role == UserRole.SENIOR_CITIZEN
                    and user.id != care_request_data[1]
                ):  # senior_citizen_id
                    return format_response(
                        status_code=403,
                        message="Access denied. You can only view your own care requests.",
                    )
                if (
                    user.role == UserRole.FAMILY_MEMBER
                    and user.id != care_request_data[5]
                ):  # made_by
                    # A family member can view requests they made, or requests for their senior citizen
                    cur.execute(
                        "SELECT 1 FROM relations WHERE senior_citizen_id = %s AND family_member_id = %s",
                        (care_request_data[1], user.id),
                    )
                    if not cur.fetchone():
                        return format_response(
                            status_code=403,
                            message="Access denied. You can only view care requests for your associated senior citizen or those you created.",
                        )
                if (
                    user.role == UserRole.CAREGIVER and user.id != care_request_data[3]
                ):  # caregiver_id
                    # Caregivers can only view requests they are assigned to, or open requests (handled by view_open_requests)
                    return format_response(
                        status_code=403,
                        message="Access denied. You can only view care requests you are assigned to.",
                    )

                care_request = {
                    "id": care_request_data[0],
                    "senior_citizen_id": care_request_data[1],
                    "senior_citizen_name": care_request_data[2],
                    "caregiver_id": care_request_data[3],
                    "caregiver_name": care_request_data[4],
                    "made_by": care_request_data[5],
                    "made_by_name": care_request_data[6],
                    "status": care_request_data[7],
                    "timing_to_visit": care_request_data[8],
                    "location": care_request_data[9],
                    "created_at": care_request_data[10],
                    "updated_at": care_request_data[11],
                }

        return format_response(
            status_code=200,
            message="Care request retrieved successfully.",
            data={"care_request": care_request},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving care request: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def create_care_request(request, validated_data):
    logger.info("Executing create_care_request controller logic.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role not in [
            UserRole.SENIOR_CITIZEN,
            UserRole.FAMILY_MEMBER,
        ]:
            return format_response(
                status_code=403,
                message="Access denied. Only senior citizens or family members can create care requests.",
            )

        caregiver_firebase_uid = validated_data.caregiver_firebase_uid
        timing_to_visit = validated_data.timing_to_visit
        location = validated_data.location

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Get caregiver ID
                cur.execute(
                    "SELECT id FROM users WHERE firebase_uid = %s AND role = %s",
                    (caregiver_firebase_uid, UserRole.CAREGIVER.value),
                )
                caregiver_data = cur.fetchone()
                if not caregiver_data:
                    return format_response(
                        status_code=404, message="Caregiver not found."
                    )
                caregiver_id = caregiver_data[0]

                senior_citizen_id = user.id  # If senior citizen creates it
                if user.role == UserRole.FAMILY_MEMBER:
                    # If family member creates it, they must specify which senior citizen it's for
                    # For simplicity, assuming the family member is creating for themselves or their primary senior citizen
                    # A more robust solution would involve a senior_citizen_id in the request payload for family members
                    # For now, let's assume the family member is creating for a senior citizen they are related to.
                    cur.execute(
                        "SELECT senior_citizen_id FROM relations WHERE family_member_id = %s LIMIT 1",
                        (user.id,),
                    )
                    sc_data = cur.fetchone()
                    if not sc_data:
                        return format_response(
                            status_code=400,
                            message="Family member not associated with any senior citizen.",
                        )
                    senior_citizen_id = sc_data[0]

                # Check for duplicate care request
                is_duplicate, error_message = check_duplicate_care_request(
                    cur, senior_citizen_id, caregiver_id, user.id
                )
                if not is_duplicate:
                    return format_response(status_code=400, message=error_message)

                cur.execute(
                    """INSERT INTO care_requests (senior_citizen_id, caregiver_id, made_by, status, timing_to_visit, location)
                       VALUES (%s, %s, %s, %s, %s, %s) RETURNING id""",
                    (
                        senior_citizen_id,
                        caregiver_id,
                        user.id,
                        CareRequestStatus.PENDING.value,
                        timing_to_visit,
                        location,
                    ),
                )
                care_request_id = cur.fetchone()[0]

        return format_response(
            status_code=201,
            message="Care request created successfully.",
            data={"care_request_id": care_request_id},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error creating care request: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def update_care_request(request, requestId, validated_data):
    logger.info(
        f"Executing update_care_request controller logic for request ID: {requestId}."
    )
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role not in [
            UserRole.SENIOR_CITIZEN,
            UserRole.FAMILY_MEMBER,
        ]:
            return format_response(
                status_code=403,
                message="Access denied. Only senior citizens or family members can update care requests.",
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Verify ownership/permission
                cur.execute(
                    "SELECT senior_citizen_id, made_by FROM care_requests WHERE id = %s",
                    (requestId,),
                )
                req_owner_data = cur.fetchone()
                if not req_owner_data:
                    return format_response(
                        status_code=404, message="Care request not found."
                    )

                senior_citizen_id = req_owner_data[0]
                made_by_id = req_owner_data[1]

                if user.id != senior_citizen_id and user.id != made_by_id:
                    # If family member, check if they are related to the senior citizen of the request
                    if user.role == UserRole.FAMILY_MEMBER:
                        cur.execute(
                            "SELECT 1 FROM relations WHERE senior_citizen_id = %s AND family_member_id = %s",
                            (senior_citizen_id, user.id),
                        )
                        if not cur.fetchone():
                            return format_response(
                                status_code=403,
                                message="Access denied. You can only update care requests for your associated senior citizen or those you created.",
                            )
                    else:
                        return format_response(
                            status_code=403,
                            message="Access denied. You can only update your own care requests.",
                        )

                update_fields = []
                update_values = []

                if validated_data.status is not None:
                    update_fields.append("status = %s")
                    update_values.append(validated_data.status.value)
                if validated_data.timing_to_visit is not None:
                    update_fields.append("timing_to_visit = %s")
                    update_values.append(validated_data.timing_to_visit)
                if validated_data.location is not None:
                    update_fields.append("location = %s")
                    update_values.append(validated_data.location)

                if not update_fields:
                    return format_response(
                        status_code=400, message="No fields to update."
                    )

                update_values.append(requestId)
                update_query = f"UPDATE care_requests SET {', '.join(update_fields)}, updated_at = CURRENT_TIMESTAMP WHERE id = %s"

                cur.execute(update_query, tuple(update_values))
                if cur.rowcount == 0:
                    return format_response(
                        status_code=404,
                        message="Care request not found or no changes made.",
                    )

        return format_response(
            status_code=200, message="Care request updated successfully."
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error updating care request: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def close_care_request(request, requestId):
    logger.info(
        f"Executing close_care_request controller logic for request ID: {requestId}."
    )
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role not in [
            UserRole.SENIOR_CITIZEN,
            UserRole.FAMILY_MEMBER,
        ]:
            return format_response(
                status_code=403,
                message="Access denied. Only senior citizens or family members can close care requests.",
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Verify ownership/permission and current status
                cur.execute(
                    "SELECT senior_citizen_id, made_by, status FROM care_requests WHERE id = %s",
                    (requestId,),
                )
                req_data = cur.fetchone()
                if not req_data:
                    return format_response(
                        status_code=404, message="Care request not found."
                    )

                senior_citizen_id = req_data[0]
                made_by_id = req_data[1]
                current_status = req_data[2]

                if user.id != senior_citizen_id and user.id != made_by_id:
                    # If family member, check if they are related to the senior citizen of the request
                    if user.role == UserRole.FAMILY_MEMBER:
                        cur.execute(
                            "SELECT 1 FROM relations WHERE senior_citizen_id = %s AND family_member_id = %s",
                            (senior_citizen_id, user.id),
                        )
                        if not cur.fetchone():
                            return format_response(
                                status_code=403,
                                message="Access denied. You can only close care requests for your associated senior citizen or those you created.",
                            )
                    else:
                        return format_response(
                            status_code=403,
                            message="Access denied. You can only close your own care requests.",
                        )

                if current_status == CareRequestStatus.CANCELLED.value:
                    return format_response(
                        status_code=400, message="Care request is already cancelled."
                    )

                cur.execute(
                    "UPDATE care_requests SET status = %s, updated_at = CURRENT_TIMESTAMP WHERE id = %s",
                    (CareRequestStatus.CANCELLED.value, requestId),
                )
                if cur.rowcount == 0:
                    return format_response(
                        status_code=404,
                        message="Care request not found or no changes made.",
                    )

        return format_response(
            status_code=200, message="Care request closed successfully."
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error closing care request: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def get_caregivers(request):
    logger.info("Executing get_caregivers controller logic.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered:
            return format_response(status_code=401, message="User not registered.")

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """SELECT id, full_name, description, tags, youtube_url
                       FROM users
                       WHERE role = %s AND status = %s""",
                    (
                        UserRole.CAREGIVER.value,
                        UserStatus.ACTIVE.value,
                    ),
                )
                caregivers_data = cur.fetchall()

                caregivers = [
                    {
                        "id": cg[0],
                        "full_name": cg[1],
                        "description": cg[2],
                        "tags": cg[3],
                        "youtube_url": cg[4],
                    }
                    for cg in caregivers_data
                ]

        return format_response(
            status_code=200,
            message="Caregivers retrieved successfully.",
            data={"caregivers": caregivers},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving caregivers: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def get_caregiver_profile(request, caregiverId):
    logger.info(
        f"Executing get_caregiver_profile controller logic for caregiver ID: {caregiverId}."
    )
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered:
            return format_response(status_code=401, message="User not registered.")

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """SELECT id, full_name, description, tags, youtube_url
                       FROM users
                       WHERE id = %s AND role = %s AND status = %s""",
                    (
                        caregiverId,
                        UserRole.CAREGIVER.value,
                        UserStatus.ACTIVE.value,
                    ),
                )
                caregiver_data = cur.fetchone()

                if not caregiver_data:
                    return format_response(
                        status_code=404, message="Caregiver not found or not active."
                    )

                caregiver_profile = {
                    "id": caregiver_data[0],
                    "full_name": caregiver_data[1],
                    "description": caregiver_data[2],
                    "tags": caregiver_data[3],
                    "youtube_url": caregiver_data[4],
                }

        return format_response(
            status_code=200,
            message="Caregiver profile retrieved successfully.",
            data={"caregiver_profile": caregiver_profile},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving caregiver profile: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def apply_for_request(request, requestId, validated_data):
    logger.info(
        f"Executing apply_for_request controller logic for request ID: {requestId}."
    )
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role != UserRole.CAREGIVER:
            return format_response(
                status_code=403,
                message="Access denied. Only caregivers can apply for requests.",
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Check if request exists and is pending
                cur.execute(
                    "SELECT status FROM care_requests WHERE id = %s", (requestId,)
                )
                req_status_data = cur.fetchone()
                if not req_status_data:
                    return format_response(
                        status_code=404, message="Care request not found."
                    )
                if req_status_data[0] != CareRequestStatus.PENDING.value:
                    return format_response(
                        status_code=400, message="Care request is not pending."
                    )

                # Update care request with caregiver_id and status to accepted
                cur.execute(
                    "UPDATE care_requests SET caregiver_id = %s, status = %s, updated_at = CURRENT_TIMESTAMP WHERE id = %s",
                    (user.id, CareRequestStatus.ACCEPTED.value, requestId),
                )
                if cur.rowcount == 0:
                    return format_response(
                        status_code=404,
                        message="Care request not found or no changes made.",
                    )

        return format_response(
            status_code=200, message="Successfully applied for care request."
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error applying for care request: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def accept_engagement(request, requestId, validated_data):
    logger.info(
        f"Executing accept_engagement controller logic for request ID: {requestId}."
    )
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role != UserRole.CAREGIVER:
            return format_response(
                status_code=403,
                message="Access denied. Only caregivers can accept engagements.",
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Check if request exists and is assigned to this caregiver and is pending
                cur.execute(
                    "SELECT status, caregiver_id FROM care_requests WHERE id = %s",
                    (requestId,),
                )
                req_data = cur.fetchone()
                if not req_data:
                    return format_response(
                        status_code=404, message="Care request not found."
                    )
                if req_data[1] != user.id:
                    return format_response(
                        status_code=403,
                        message="Access denied. This engagement is not offered to you.",
                    )
                if req_data[0] != CareRequestStatus.PENDING.value:
                    return format_response(
                        status_code=400, message="Care request is not pending."
                    )

                # Update care request status to accepted
                cur.execute(
                    "UPDATE care_requests SET status = %s, updated_at = CURRENT_TIMESTAMP WHERE id = %s",
                    (CareRequestStatus.ACCEPTED.value, requestId),
                )
                if cur.rowcount == 0:
                    return format_response(
                        status_code=404,
                        message="Care request not found or no changes made.",
                    )

        return format_response(
            status_code=200, message="Engagement accepted successfully."
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error accepting engagement: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def decline_engagement(request, requestId, validated_data):
    logger.info(
        f"Executing decline_engagement controller logic for request ID: {requestId}."
    )
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role != UserRole.CAREGIVER:
            return format_response(
                status_code=403,
                message="Access denied. Only caregivers can decline engagements.",
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Check if request exists and is assigned to this caregiver and is pending
                cur.execute(
                    "SELECT status, caregiver_id FROM care_requests WHERE id = %s",
                    (requestId,),
                )
                req_data = cur.fetchone()
                if not req_data:
                    return format_response(
                        status_code=404, message="Care request not found."
                    )
                if req_data[1] != user.id:
                    return format_response(
                        status_code=403,
                        message="Access denied. This engagement is not offered to you.",
                    )
                if req_data[0] != CareRequestStatus.PENDING.value:
                    return format_response(
                        status_code=400, message="Care request is not pending."
                    )

                # Update care request status to declined (or pending again if you want to allow other caregivers to apply)
                # For now, setting to cancelled, as it's a decline from the assigned caregiver
                cur.execute(
                    "UPDATE care_requests SET status = %s, caregiver_id = NULL, updated_at = CURRENT_TIMESTAMP WHERE id = %s",
                    (CareRequestStatus.CANCELLED.value, requestId),
                )
                if cur.rowcount == 0:
                    return format_response(
                        status_code=404,
                        message="Care request not found or no changes made.",
                    )

        return format_response(
            status_code=200, message="Engagement declined successfully."
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error declining engagement: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def get_caregivers_for_senior_citizen(request, senior_citizen_id):
    """Get all available caregivers for a specific senior citizen (for family members)"""
    logger.info(
        f"Executing get_caregivers_for_senior_citizen controller logic for senior citizen ID: {senior_citizen_id}."
    )
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role != UserRole.FAMILY_MEMBER:
            return format_response(
                status_code=403,
                message="Access denied. Only family members can view caregivers for senior citizens.",
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Verify that the family member is linked to this senior citizen
                cur.execute(
                    """SELECT id FROM relations
                       WHERE family_member_id = %s AND senior_citizen_id = %s""",
                    (user.id, senior_citizen_id),
                )
                relation = cur.fetchone()

                if not relation:
                    return format_response(
                        status_code=403,
                        message="Access denied. You can only view caregivers for senior citizens you are linked to.",
                    )

                # Get all available caregivers
                cur.execute(
                    """SELECT id, full_name, gmail_id, description, tags, youtube_url, date_of_birth
                       FROM users
                       WHERE role = %s AND status = %s
                       ORDER BY full_name""",
                    (UserRole.CAREGIVER.value, UserStatus.ACTIVE.value),
                )
                caregivers_data = cur.fetchall()

                caregivers = [
                    {
                        "id": cg[0],
                        "full_name": cg[1],
                        "gmail_id": cg[2],
                        "description": cg[3],
                        "tags": cg[4].split(",") if cg[4] else [],
                        "youtube_url": cg[5],
                        "date_of_birth": cg[6],
                    }
                    for cg in caregivers_data
                ]

        return format_response(
            status_code=200,
            message="Caregivers for senior citizen retrieved successfully.",
            data={"caregivers": caregivers, "senior_citizen_id": senior_citizen_id},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving caregivers for senior citizen: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def get_current_caregiver_for_senior_citizen(request, senior_citizen_id):
    """Get current hired caregiver for a specific senior citizen (for family members)"""
    logger.info(
        f"Executing get_current_caregiver_for_senior_citizen controller logic for senior citizen ID: {senior_citizen_id}."
    )
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role != UserRole.FAMILY_MEMBER:
            return format_response(
                status_code=403,
                message="Access denied. Only family members can view current caregiver for senior citizens.",
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Verify that the family member is linked to this senior citizen
                cur.execute(
                    """SELECT id FROM relations
                       WHERE family_member_id = %s AND senior_citizen_id = %s""",
                    (user.id, senior_citizen_id),
                )
                relation = cur.fetchone()

                if not relation:
                    return format_response(
                        status_code=403,
                        message="Access denied. You can only view current caregiver for senior citizens you are linked to.",
                    )

                # Get current caregiver for this senior citizen
                cur.execute(
                    """SELECT cg.id, cg.full_name, cg.gmail_id, cg.description, cg.tags
                       FROM care_requests cr
                       JOIN users cg ON cr.caregiver_id = cg.id
                       WHERE cr.senior_citizen_id = %s AND cr.status = %s""",
                    (senior_citizen_id, CareRequestStatus.ACCEPTED.value),
                )
                caregiver_data = cur.fetchone()

                if not caregiver_data:
                    return format_response(
                        status_code=404,
                        message="No current caregiver found for this senior citizen.",
                    )

                caregiver = {
                    "id": caregiver_data[0],
                    "full_name": caregiver_data[1],
                    "gmail_id": caregiver_data[2],
                    "description": caregiver_data[3],
                    "tags": caregiver_data[4].split(",") if caregiver_data[4] else [],
                }

        return format_response(
            status_code=200,
            message="Current caregiver for senior citizen retrieved successfully.",
            data={"caregiver": caregiver, "senior_citizen_id": senior_citizen_id},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving current caregiver for senior citizen: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def get_caregiver_requests_for_senior_citizen(request, senior_citizen_id):
    """Get caregiver requests for a specific senior citizen (for family members)"""
    logger.info(
        f"Executing get_caregiver_requests_for_senior_citizen controller logic for senior citizen ID: {senior_citizen_id}."
    )
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role != UserRole.FAMILY_MEMBER:
            return format_response(
                status_code=403,
                message="Access denied. Only family members can view caregiver requests for senior citizens.",
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Verify that the family member is linked to this senior citizen
                cur.execute(
                    """SELECT id FROM relations
                       WHERE family_member_id = %s AND senior_citizen_id = %s""",
                    (user.id, senior_citizen_id),
                )
                relation = cur.fetchone()

                if not relation:
                    return format_response(
                        status_code=403,
                        message="Access denied. You can only view caregiver requests for senior citizens you are linked to.",
                    )

                # Get all caregiver requests for this senior citizen
                cur.execute(
                    """SELECT cr.id, cr.caregiver_id, cg.full_name as caregiver_name,
                              cr.status, cr.timing_to_visit, cr.location, cr.created_at, cr.updated_at
                       FROM care_requests cr
                       JOIN users cg ON cr.caregiver_id = cg.id
                       WHERE cr.senior_citizen_id = %s
                       ORDER BY cr.created_at DESC""",
                    (senior_citizen_id,),
                )
                requests_data = cur.fetchall()

                requests = [
                    {
                        "id": req[0],
                        "caregiver_id": req[1],
                        "caregiver_name": req[2],
                        "status": req[3],
                        "timing_to_visit": req[4],
                        "location": req[5],
                        "created_at": req[6],
                        "updated_at": req[7],
                    }
                    for req in requests_data
                ]

        return format_response(
            status_code=200,
            message="Caregiver requests for senior citizen retrieved successfully.",
            data={"requests": requests, "senior_citizen_id": senior_citizen_id},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving caregiver requests for senior citizen: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def request_caregiver_for_senior_citizen(
    request, senior_citizen_id, validated_data
):
    """Request a caregiver for a specific senior citizen (for family members)"""
    logger.info(
        f"Executing request_caregiver_for_senior_citizen controller logic for senior citizen ID: {senior_citizen_id}."
    )
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role != UserRole.FAMILY_MEMBER:
            return format_response(
                status_code=403,
                message="Access denied. Only family members can request caregivers for senior citizens.",
            )

        caregiver_id = validated_data.caregiver_id
        message = validated_data.message

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Verify that the family member is linked to this senior citizen
                cur.execute(
                    """SELECT id FROM relations
                       WHERE family_member_id = %s AND senior_citizen_id = %s""",
                    (user.id, senior_citizen_id),
                )
                relation = cur.fetchone()

                if not relation:
                    return format_response(
                        status_code=403,
                        message="Access denied. You can only request caregivers for senior citizens you are linked to.",
                    )

                # Check if caregiver exists and is active
                cur.execute(
                    "SELECT id FROM users WHERE id = %s AND role = %s AND status = %s",
                    (caregiver_id, UserRole.CAREGIVER, UserStatus.ACTIVE),
                )
                if not cur.fetchone():
                    return format_response(
                        status_code=404, message="Caregiver not found or not available."
                    )

                # Check for duplicate care request
                is_duplicate, error_message = check_duplicate_care_request(
                    cur, senior_citizen_id, caregiver_id, user.id
                )
                if not is_duplicate:
                    return format_response(status_code=400, message=error_message)

                # Create care request for the specific senior citizen
                cur.execute(
                    """INSERT INTO care_requests (senior_citizen_id, made_by, caregiver_id, status, timing_to_visit, location, created_at)
                       VALUES (%s, %s, %s, %s, %s, %s, NOW()) RETURNING id""",
                    (
                        senior_citizen_id,  # Specific senior citizen
                        user.id,  # Family member making the request
                        caregiver_id,  # Requested caregiver
                        CareRequestStatus.PENDING.value,
                        None,  # No specific timing for direct caregiver requests
                        "Home",  # Default location
                    ),
                )
                request_id = cur.fetchone()[0]

        return format_response(
            status_code=201,
            message="Caregiver request created successfully for the senior citizen.",
            data={"request_id": request_id, "senior_citizen_id": senior_citizen_id},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error creating caregiver request for senior citizen: {e}")
        return format_response(status_code=500, message="Internal server error.")
