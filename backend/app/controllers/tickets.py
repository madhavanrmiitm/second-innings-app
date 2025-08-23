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
                if (
                    user.role == UserRole.ADMIN.value
                    or user.role == UserRole.SUPPORT_USER.value
                ):
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
                # Auto-assign ticket to a support user with balanced workload
                assigned_to_id = _get_balanced_assignment(cur)

                if assigned_to_id:
                    logger.info(
                        f"Auto-assigned ticket to support user ID: {assigned_to_id} (balanced workload)"
                    )
                else:
                    logger.warning("No active support users found for auto-assignment")

                cur.execute(
                    """INSERT INTO tickets (user_id, subject, description, priority, category, assigned_to)
                       VALUES (%s, %s, %s, %s, %s, %s) RETURNING id""",
                    (
                        user.id,
                        validated_data.subject,
                        validated_data.description,
                        getattr(validated_data, "priority", "medium"),
                        getattr(validated_data, "category", None),
                        assigned_to_id,
                    ),
                )
                ticket_id = cur.fetchone()[0]

        # Prepare response data
        response_data = {"ticket_id": ticket_id}
        if assigned_to_id:
            response_data["auto_assigned_to"] = assigned_to_id
            response_data["message"] = (
                "Ticket created and auto-assigned to support team"
            )
        else:
            response_data["message"] = (
                "Ticket created (no support users available for assignment)"
            )

        return format_response(
            status_code=201,
            message="Ticket created successfully."
            + (" (Auto-assigned)" if assigned_to_id else ""),
            data=response_data,
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
                cur.execute(
                    "SELECT user_id, status FROM tickets WHERE id = %s", (ticketId,)
                )
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

                # Handle subject update
                if (
                    hasattr(validated_data, "subject")
                    and validated_data.subject is not None
                ):
                    update_fields.append("subject = %s")
                    update_values.append(validated_data.subject)

                # Handle description update
                if (
                    hasattr(validated_data, "description")
                    and validated_data.description is not None
                ):
                    update_fields.append("description = %s")
                    update_values.append(validated_data.description)

                # Handle priority update with validation
                if (
                    hasattr(validated_data, "priority")
                    and validated_data.priority is not None
                ):
                    # Validate priority value
                    valid_priorities = ["low", "medium", "high"]
                    if validated_data.priority not in valid_priorities:
                        return format_response(
                            status_code=400,
                            message=f"Invalid priority. Must be one of: {', '.join(valid_priorities)}",
                        )
                    update_fields.append("priority = %s")
                    update_values.append(validated_data.priority)

                # Handle category update
                if (
                    hasattr(validated_data, "category")
                    and validated_data.category is not None
                ):
                    update_fields.append("category = %s")
                    update_values.append(validated_data.category)

                # Handle status update with validation - FIXED
                if (
                    hasattr(validated_data, "status")
                    and validated_data.status is not None
                ):
                    # Validate status value
                    valid_statuses = ["open", "in_progress", "closed"]
                    status_value = validated_data.status

                    # Handle if it's an enum object with .value attribute or just a string
                    if hasattr(status_value, "value"):
                        status_value = status_value.value

                    # Validate the status value
                    if status_value not in valid_statuses:
                        return format_response(
                            status_code=400,
                            message=f"Invalid status. Must be one of: {', '.join(valid_statuses)}",
                        )

                    update_fields.append("status = %s")
                    update_values.append(status_value)

                    # Set resolved_at timestamp when closing ticket
                    if status_value == "closed":
                        update_fields.append("resolved_at = CURRENT_TIMESTAMP")

                # Handle assigned_to update
                if (
                    hasattr(validated_data, "assigned_to")
                    and validated_data.assigned_to is not None
                ):
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
                    if assigned_user[0] not in [
                        UserRole.ADMIN.value,
                        UserRole.SUPPORT_USER.value,
                    ]:
                        return format_response(
                            status_code=400,
                            message="Tickets can only be assigned to admin or support users.",
                        )
                    update_fields.append("assigned_to = %s")
                    update_values.append(validated_data.assigned_to)

                # Check if there are any fields to update
                if not update_fields:
                    return format_response(
                        status_code=400, message="No fields to update."
                    )

                # Build and execute update query
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


async def get_assignable_users(request):
    """Get users who can be assigned tickets (admin and support users)"""
    logger.info("Executing get_assignable_users controller logic.")
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
                    """
                    SELECT id, full_name, role
                    FROM users
                    WHERE role IN ('admin', 'support_user')
                    AND status = 'active'
                    ORDER BY full_name
                """
                )
                users_data = cur.fetchall()

                users = [
                    {"id": user[0], "name": user[1], "role": user[2]}
                    for user in users_data
                ]

        return format_response(
            status_code=200,
            message="Assignable users retrieved successfully.",
            data={"users": users},
        )

    except Exception as e:
        logger.error(f"Error retrieving assignable users: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def get_support_workload_stats(request):
    """Get workload statistics for support users to help with balanced auto-assignment"""
    logger.info("Executing get_support_workload_stats controller logic.")
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

        # Only admins can view workload statistics
        if user.role != UserRole.ADMIN.value:
            return format_response(
                status_code=403,
                message="Access denied. Only admins can view support workload statistics.",
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """
                    SELECT
                        u.id,
                        u.full_name,
                        u.role,
                        COUNT(t.id) as total_tickets,
                        COUNT(CASE WHEN t.status = 'open' THEN 1 END) as open_tickets,
                        COUNT(CASE WHEN t.status = 'in_progress' THEN 1 END) as in_progress_tickets,
                        COUNT(CASE WHEN t.status = 'closed' THEN 1 END) as closed_tickets,
                        AVG(CASE WHEN t.resolved_at IS NOT NULL
                            THEN EXTRACT(EPOCH FROM (t.resolved_at - t.created_at))/3600
                            END) as avg_resolution_hours
                    FROM users u
                    LEFT JOIN tickets t ON u.id = t.assigned_to
                    WHERE u.role IN ('support_user')
                    AND u.status = 'active'
                    GROUP BY u.id, u.full_name, u.role
                    ORDER BY open_tickets DESC, total_tickets ASC
                """
                )
                stats_data = cur.fetchall()

                stats = [
                    {
                        "user_id": stat[0],
                        "full_name": stat[1],
                        "role": stat[2],
                        "total_tickets": stat[3],
                        "open_tickets": stat[4],
                        "in_progress_tickets": stat[5],
                        "closed_tickets": stat[6],
                        "avg_resolution_hours": round(stat[7], 2) if stat[7] else None,
                    }
                    for stat in stats_data
                ]

        return format_response(
            status_code=200,
            message="Support workload statistics retrieved successfully.",
            data={"workload_stats": stats},
        )

    except Exception as e:
        logger.error(f"Error retrieving support workload statistics: {e}")
        return format_response(status_code=500, message="Internal server error.")


def _get_balanced_assignment(cursor):
    """
    Helper function to get balanced ticket assignment based on workload.
    Returns the user ID of the support user with the least open tickets.
    """
    try:
        cursor.execute(
            """
            SELECT u.id, COUNT(t.id) as open_tickets
            FROM users u
            LEFT JOIN tickets t ON u.id = t.assigned_to AND t.status IN ('open', 'in_progress')
            WHERE u.role IN ('support_user')
            AND u.status = 'active'
            GROUP BY u.id
            ORDER BY open_tickets ASC, RANDOM()
            LIMIT 1
        """
        )
        result = cursor.fetchone()
        return result[0] if result else None
    except Exception as e:
        logger.error(f"Error in balanced assignment: {e}")
        return None
