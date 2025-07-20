from app.database.db import get_db_connection
from app.logger import logger
from app.modules.auth.auth_service import auth_service
from app.payloads import TicketStatus, UserRole, UserStatus
from app.utils.response_formatter import format_response


async def get_system_users(request):
    logger.info("Executing get_system_users controller logic.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role != UserRole.ADMIN:
            return format_response(
                status_code=403,
                message="Access denied. Only admins can view system users.",
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """SELECT id, gmail_id, full_name, role, status, created_at
                       FROM users"""
                )
                users_data = cur.fetchall()

                users = [
                    {
                        "id": u[0],
                        "gmail_id": u[1],
                        "full_name": u[2],
                        "role": u[3],
                        "status": u[4],
                        "created_at": u[5],
                    }
                    for u in users_data
                ]

        return format_response(
            status_code=200,
            message="System users retrieved successfully.",
            data={"users": users},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving system users: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def delete_user(request, userId, validated_data):
    logger.info(f"Executing delete_user controller logic for user ID: {userId}.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role != UserRole.ADMIN:
            return format_response(
                status_code=403, message="Access denied. Only admins can delete users."
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("DELETE FROM users WHERE id = %s", (userId,))
                if cur.rowcount == 0:
                    return format_response(status_code=404, message="User not found.")

        return format_response(status_code=200, message="User deleted successfully.")

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error deleting user: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def get_caregivers_for_review(request):
    logger.info("Executing get_caregivers_for_review controller logic.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role != UserRole.ADMIN:
            return format_response(
                status_code=403,
                message="Access denied. Only admins can view caregivers for review.",
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """SELECT id, full_name, gmail_id, youtube_url, description, tags, created_at
                       FROM users
                       WHERE role = %s AND status = %s""",
                    (
                        UserRole.CAREGIVER.value,
                        UserStatus.PENDING_APPROVAL.value,
                    ),
                )
                caregivers_data = cur.fetchall()

                caregivers = [
                    {
                        "id": cg[0],
                        "full_name": cg[1],
                        "gmail_id": cg[2],
                        "youtube_url": cg[3],
                        "description": cg[4],
                        "tags": cg[5],
                        "created_at": cg[6],
                    }
                    for cg in caregivers_data
                ]

        return format_response(
            status_code=200,
            message="Caregivers for review retrieved successfully.",
            data={"caregivers": caregivers},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving caregivers for review: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def review_caregiver(request, caregiverId, validated_data):
    logger.info(
        f"Executing review_caregiver controller logic for caregiver ID: {caregiverId}."
    )
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role != UserRole.ADMIN:
            return format_response(
                status_code=403,
                message="Access denied. Only admins can review caregivers.",
            )

        new_status = validated_data.status

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """UPDATE users SET status = %s, updated_at = CURRENT_TIMESTAMP
                       WHERE id = %s AND role = %s AND status = %s""",
                    (
                        new_status.value,
                        caregiverId,
                        UserRole.CAREGIVER.value,
                        UserStatus.PENDING_APPROVAL.value,
                    ),
                )
                if cur.rowcount == 0:
                    return format_response(
                        status_code=404,
                        message="Caregiver not found or not in pending approval status.",
                    )

        return format_response(
            status_code=200,
            message=f"Caregiver status updated to {new_status.value} successfully.",
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error reviewing caregiver: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def get_tickets_for_support(request):
    logger.info("Executing get_tickets_for_support controller logic.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role not in [
            UserRole.ADMIN,
            UserRole.SUPPORT_USER,
        ]:
            return format_response(
                status_code=403,
                message="Access denied. Only admins or support users can view all tickets.",
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """SELECT id, user_id, assigned_to, subject, description, status, created_at, resolved_at
                       FROM tickets
                       ORDER BY created_at DESC"""
                )
                tickets_data = cur.fetchall()

                tickets = [
                    {
                        "id": ticket[0],
                        "user_id": ticket[1],
                        "assigned_to": ticket[2],
                        "subject": ticket[3],
                        "description": ticket[4],
                        "status": ticket[5],
                        "created_at": ticket[6],
                        "resolved_at": ticket[7],
                    }
                    for ticket in tickets_data
                ]

        return format_response(
            status_code=200,
            message="All support tickets retrieved successfully.",
            data={"tickets": tickets},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving support tickets: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def resolve_ticket(request, ticketId, validated_data):
    logger.info(f"Executing resolve_ticket controller logic for ticket ID: {ticketId}.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role not in [
            UserRole.ADMIN,
            UserRole.SUPPORT_USER,
        ]:
            return format_response(
                status_code=403,
                message="Access denied. Only admins or support users can resolve tickets.",
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT status FROM tickets WHERE id = %s", (ticketId,))
                ticket_status_data = cur.fetchone()
                if not ticket_status_data:
                    return format_response(status_code=404, message="Ticket not found.")
                if ticket_status_data[0] == TicketStatus.RESOLVED.value:
                    return format_response(
                        status_code=400, message="Ticket is already resolved."
                    )

                cur.execute(
                    "UPDATE tickets SET status = %s, resolved_at = CURRENT_TIMESTAMP WHERE id = %s",
                    (TicketStatus.RESOLVED.value, ticketId),
                )
                if cur.rowcount == 0:
                    return format_response(
                        status_code=404, message="Ticket not found or no changes made."
                    )

        return format_response(status_code=200, message="Ticket resolved successfully.")

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error resolving ticket: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def get_ticket_stats(request):
    logger.info("Executing get_ticket_stats controller logic.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role not in [
            UserRole.ADMIN,
            UserRole.SUPPORT_USER,
        ]:
            return format_response(
                status_code=403,
                message="Access denied. Only admins or support users can view ticket statistics.",
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("""SELECT status, COUNT(*) FROM tickets GROUP BY status""")
                stats_data = cur.fetchall()

                ticket_stats = {status: count for status, count in stats_data}

        return format_response(
            status_code=200,
            message="Ticket statistics retrieved successfully.",
            data={"ticket_stats": ticket_stats},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving ticket statistics: {e}")
        return format_response(status_code=500, message="Internal server error.")
