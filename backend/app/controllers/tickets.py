from app.database.db import get_db_connection
from app.logger import logger
from app.modules.auth.auth_service import auth_service
from app.payloads import TicketStatus, UserRole
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

        # Get query parameters
        status_filter = request.query_params.get("status")
        priority_filter = request.query_params.get("priority")
        assigned_to_filter = request.query_params.get("assigned_to")

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Base query with user details
                query = """
                    SELECT 
                        t.id, t.user_id, t.assigned_to, t.subject, t.description, 
                        t.priority, t.category, t.status, t.created_at, t.updated_at, t.resolved_at,
                        u1.full_name as created_by_name, u2.full_name as assigned_to_name
                    FROM tickets t
                    LEFT JOIN users u1 ON t.user_id = u1.id
                    LEFT JOIN users u2 ON t.assigned_to = u2.id
                    WHERE 1=1
                """
                params = []

                # Role-based filtering
                if user.role == UserRole.ADMIN.value or user.role == UserRole.SUPPORT_USER.value:
                    # Admin and support see all tickets
                    pass
                else:
                    # Regular users see only their tickets
                    query += " AND t.user_id = %s"
                    params.append(user.id)

                # Apply filters
                if status_filter:
                    query += " AND t.status = %s"
                    params.append(status_filter)
                
                if priority_filter:
                    query += " AND t.priority = %s"
                    params.append(priority_filter)
                
                if assigned_to_filter:
                    query += " AND t.assigned_to = %s"
                    params.append(int(assigned_to_filter))

                query += " ORDER BY t.created_at DESC"
                
                cur.execute(query, params)
                tickets_data = cur.fetchall()

                tickets = [
                    {
                        "id": ticket[0],
                        "user_id": ticket[1],
                        "assigned_to": ticket[2],
                        "subject": ticket[3],
                        "description": ticket[4],
                        "priority": ticket[5],
                        "category": ticket[6],
                        "status": ticket[7],
                        "created_at": ticket[8],
                        "updated_at": ticket[9],
                        "resolved_at": ticket[10],
                        "created_by_name": ticket[11],
                        "assigned_to_name": ticket[12],
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

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """INSERT INTO tickets (user_id, subject, description, priority, category)
                       VALUES (%s, %s, %s, %s, %s) RETURNING id""",
                    (
                        user.id,
                        validated_data.subject,
                        validated_data.description,
                        getattr(validated_data, 'priority', 'medium'),
                        getattr(validated_data, 'category', None),
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
                    """SELECT 
                        t.id, t.user_id, t.assigned_to, t.subject, t.description, 
                        t.priority, t.category, t.status, t.created_at, t.updated_at, t.resolved_at,
                        u1.full_name as created_by_name, u2.full_name as assigned_to_name
                    FROM tickets t
                    LEFT JOIN users u1 ON t.user_id = u1.id
                    LEFT JOIN users u2 ON t.assigned_to = u2.id
                    WHERE t.id = %s""",
                    (ticketId,),
                )
                ticket_data = cur.fetchone()

                if not ticket_data:
                    return format_response(status_code=404, message="Ticket not found.")

                # Check permissions
                if user.role not in [UserRole.ADMIN.value, UserRole.SUPPORT_USER.value]:
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
                    "priority": ticket_data[5],
                    "category": ticket_data[6],
                    "status": ticket_data[7],
                    "created_at": ticket_data[8],
                    "updated_at": ticket_data[9],
                    "resolved_at": ticket_data[10],
                    "created_by_name": ticket_data[11],
                    "assigned_to_name": ticket_data[12],
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
                # Verify ticket exists and check permissions
                cur.execute("SELECT user_id, status FROM tickets WHERE id = %s", (ticketId,))
                ticket_data = cur.fetchone()
                if not ticket_data:
                    return format_response(status_code=404, message="Ticket not found.")
                
                # Permission check - admin/support can update any, others only their own
                if user.role not in [UserRole.ADMIN.value, UserRole.SUPPORT_USER.value]:
                    if ticket_data[0] != user.id:
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
                
                if hasattr(validated_data, 'priority') and validated_data.priority is not None:
                    update_fields.append("priority = %s")
                    update_values.append(validated_data.priority)
                
                if hasattr(validated_data, 'category') and validated_data.category is not None:
                    update_fields.append("category = %s")
                    update_values.append(validated_data.category)
                
                if validated_data.status is not None:
                    update_fields.append("status = %s")
                    update_values.append(validated_data.status.value)
                    # Set resolved_at when closing ticket
                    if validated_data.status.value == 'closed' or validated_data.status.value == 'resolved':
                        update_fields.append("resolved_at = CURRENT_TIMESTAMP")
                
                if hasattr(validated_data, 'assigned_to') and validated_data.assigned_to is not None:
                    # Verify assigned user exists and is support/admin
                    cur.execute(
                        "SELECT role FROM users WHERE id = %s",
                        (validated_data.assigned_to,),
                    )
                    assigned_user = cur.fetchone()
                    if not assigned_user:
                        return format_response(
                            status_code=404, message="Assigned user not found."
                        )
                    if assigned_user[0] not in [UserRole.ADMIN.value, UserRole.SUPPORT_USER.value]:
                        return format_response(
                            status_code=400, 
                            message="Tickets can only be assigned to admin or support users."
                        )
                    update_fields.append("assigned_to = %s")
                    update_values.append(validated_data.assigned_to)

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