from app.database.db import get_db_connection
from app.logger import logger
from app.modules.auth.auth_service import auth_service
from app.payloads import TicketStatus
from app.utils.response_formatter import format_response


async def get_tickets(request):
    logger.info("Executing get_tickets controller logic.")
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
                    """SELECT id, user_id, assigned_to, subject, description, status, created_at, resolved_at
                       FROM tickets
                       WHERE user_id = %s""",
                    (user.id,),
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
            message="Tickets retrieved successfully.",
            data={"tickets": tickets},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving tickets: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def create_ticket(request, validated_data):
    logger.info("Executing create_ticket controller logic.")
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

        subject = validated_data.subject
        description = validated_data.description

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """INSERT INTO tickets (user_id, subject, description)
                       VALUES (%s, %s, %s) RETURNING id""",
                    (
                        user.id,
                        subject,
                        description,
                    ),
                )
                ticket_id = cur.fetchone()[0]

        return format_response(
            status_code=201,
            message="Ticket created successfully.",
            data={"ticket_id": ticket_id},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error creating ticket: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def get_ticket(request, ticketId):
    logger.info(f"Executing get_ticket controller logic for ticket ID: {ticketId}.")
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
                    """SELECT id, user_id, assigned_to, subject, description, status, created_at, resolved_at
                       FROM tickets
                       WHERE id = %s""",
                    (ticketId,),
                )
                ticket_data = cur.fetchone()

                if not ticket_data:
                    return format_response(status_code=404, message="Ticket not found.")

                # Check permissions
                if user.id != ticket_data[1]:  # user_id
                    return format_response(
                        status_code=403,
                        message="Access denied. You can only view your own tickets.",
                    )

                ticket = {
                    "id": ticket_data[0],
                    "user_id": ticket_data[1],
                    "assigned_to": ticket_data[2],
                    "subject": ticket_data[3],
                    "description": ticket_data[4],
                    "status": ticket_data[5],
                    "created_at": ticket_data[6],
                    "resolved_at": ticket_data[7],
                }

        return format_response(
            status_code=200,
            message="Ticket retrieved successfully.",
            data={"ticket": ticket},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving ticket: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def update_ticket(request, ticketId, validated_data):
    logger.info(f"Executing update_ticket controller logic for ticket ID: {ticketId}.")
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
                # Verify ownership
                cur.execute("SELECT user_id FROM tickets WHERE id = %s", (ticketId,))
                ticket_owner_data = cur.fetchone()
                if not ticket_owner_data:
                    return format_response(status_code=404, message="Ticket not found.")
                if ticket_owner_data[0] != user.id:
                    return format_response(
                        status_code=403,
                        message="Access denied. You can only update your own tickets.",
                    )

                update_fields = []
                update_values = []

                if validated_data.subject is not None:
                    update_fields.append("subject = %s")
                    update_values.append(validated_data.subject)
                if validated_data.description is not None:
                    update_fields.append("description = %s")
                    update_values.append(validated_data.description)
                if validated_data.status is not None:
                    update_fields.append("status = %s")
                    update_values.append(validated_data.status.value)

                if not update_fields:
                    return format_response(
                        status_code=400, message="No fields to update."
                    )

                update_values.append(ticketId)
                update_query = f"UPDATE tickets SET {', '.join(update_fields)}, updated_at = CURRENT_TIMESTAMP WHERE id = %s"

                cur.execute(update_query, tuple(update_values))
                if cur.rowcount == 0:
                    return format_response(
                        status_code=404, message="Ticket not found or no changes made."
                    )

        return format_response(status_code=200, message="Ticket updated successfully.")

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error updating ticket: {e}")
        return format_response(status_code=500, message="Internal server error.")
