from app.utils.response_formatter import format_response
from app.modules.auth.auth_service import auth_service
from app.database.db import get_db_connection
from app.logger import logger
from app.payloads import UserRole

async def get_interest_groups(request):
    logger.info("Executing get_interest_groups controller logic.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(status_code=401, message="Authorization header missing or invalid.")
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered:
            return format_response(status_code=401, message="User not registered.")

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """SELECT id, title, description, links, status, timing, created_by, created_at, updated_at
                       FROM interest_groups"""
                )
                interest_groups_data = cur.fetchall()

                interest_groups = [
                    {
                        "id": ig[0],
                        "title": ig[1],
                        "description": ig[2],
                        "links": ig[3],
                        "status": ig[4],
                        "timing": ig[5],
                        "created_by": ig[6],
                        "created_at": ig[7],
                        "updated_at": ig[8],
                    }
                    for ig in interest_groups_data
                ]

        return format_response(
            status_code=200,
            message="Interest groups retrieved successfully.",
            data={"interest_groups": interest_groups},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(status_code=401, message="Authentication failed. Invalid token.")
    except Exception as e:
        logger.error(f"Error retrieving interest groups: {e}")
        return format_response(status_code=500, message="Internal server error.")

async def create_interest_group(request, validated_data):
    logger.info("Executing create_interest_group controller logic.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(status_code=401, message="Authorization header missing or invalid.")
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role != UserRole.INTEREST_GROUP_ADMIN:
            return format_response(status_code=403, message="Access denied. Only interest group admins can create groups.")

        title = validated_data.title
        description = validated_data.description
        links = validated_data.links
        timing = validated_data.timing

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """INSERT INTO interest_groups (title, description, links, timing, created_by)
                       VALUES (%s, %s, %s, %s, %s) RETURNING id""",
                    (
                        title,
                        description,
                        links,
                        timing,
                        user.id,
                    ),
                )
                group_id = cur.fetchone()[0]

        return format_response(
            status_code=201,
            message="Interest group created successfully.",
            data={"group_id": group_id},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(status_code=401, message="Authentication failed. Invalid token.")
    except Exception as e:
        logger.error(f"Error creating interest group: {e}")
        return format_response(status_code=500, message="Internal server error.")

async def get_interest_group(request, groupId):
    logger.info(f"Executing get_interest_group controller logic for group ID: {groupId}.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(status_code=401, message="Authorization header missing or invalid.")
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered:
            return format_response(status_code=401, message="User not registered.")

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """SELECT id, title, description, links, status, timing, created_by, created_at, updated_at
                       FROM interest_groups
                       WHERE id = %s""",
                    (groupId,)
                )
                interest_group_data = cur.fetchone()

                if not interest_group_data:
                    return format_response(status_code=404, message="Interest group not found.")

                interest_group = {
                    "id": interest_group_data[0],
                    "title": interest_group_data[1],
                    "description": interest_group_data[2],
                    "links": interest_group_data[3],
                    "status": interest_group_data[4],
                    "timing": interest_group_data[5],
                    "created_by": interest_group_data[6],
                    "created_at": interest_group_data[7],
                    "updated_at": interest_group_data[8],
                }

        return format_response(
            status_code=200,
            message="Interest group retrieved successfully.",
            data={"interest_group": interest_group},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(status_code=401, message="Authentication failed. Invalid token.")
    except Exception as e:
        logger.error(f"Error retrieving interest group: {e}")
        return format_response(status_code=500, message="Internal server error.")

async def update_interest_group(request, groupId, validated_data):
    logger.info(f"Executing update_interest_group controller logic for group ID: {groupId}.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(status_code=401, message="Authorization header missing or invalid.")
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role != UserRole.INTEREST_GROUP_ADMIN:
            return format_response(status_code=403, message="Access denied. Only interest group admins can update groups.")

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Verify ownership
                cur.execute(
                    "SELECT created_by FROM interest_groups WHERE id = %s",
                    (groupId,)
                )
                group_owner_data = cur.fetchone()
                if not group_owner_data:
                    return format_response(status_code=404, message="Interest group not found.")
                if group_owner_data[0] != user.id:
                    return format_response(status_code=403, message="Access denied. You can only update groups you created.")

                update_fields = []
                update_values = []

                if validated_data.title is not None:
                    update_fields.append("title = %s")
                    update_values.append(validated_data.title)
                if validated_data.description is not None:
                    update_fields.append("description = %s")
                    update_values.append(validated_data.description)
                if validated_data.links is not None:
                    update_fields.append("links = %s")
                    update_values.append(validated_data.links)
                if validated_data.status is not None:
                    update_fields.append("status = %s")
                    update_values.append(validated_data.status)
                if validated_data.timing is not None:
                    update_fields.append("timing = %s")
                    update_values.append(validated_data.timing)

                if not update_fields:
                    return format_response(status_code=400, message="No fields to update.")

                update_values.append(groupId)
                update_query = f"UPDATE interest_groups SET {', '.join(update_fields)}, updated_at = CURRENT_TIMESTAMP WHERE id = %s"

                cur.execute(update_query, tuple(update_values))
                if cur.rowcount == 0:
                    return format_response(status_code=404, message="Interest group not found or no changes made.")

        return format_response(status_code=200, message="Interest group updated successfully.")

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(status_code=401, message="Authentication failed. Invalid token.")
    except Exception as e:
        logger.error(f"Error updating interest group: {e}")
        return format_response(status_code=500, message="Internal server error.")

async def join_interest_group(request, groupId, validated_data):
    logger.info(f"Executing join_interest_group controller logic for group ID: {groupId}.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(status_code=401, message="Authorization header missing or invalid.")
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role != UserRole.SENIOR_CITIZEN:
            return format_response(status_code=403, message="Access denied. Only senior citizens can join interest groups.")

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Check if group exists
                cur.execute("SELECT id FROM interest_groups WHERE id = %s", (groupId,))
                if not cur.fetchone():
                    return format_response(status_code=404, message="Interest group not found.")

                # For now, assuming a simple membership model where we just acknowledge the join.
                # A more robust solution would involve a many-to-many table (e.g., interest_group_members).
                # If a `members` column (e.g., array of user IDs) were added to `interest_groups` table, it would be updated here.
                return format_response(status_code=200, message="Successfully joined interest group (membership not persisted in DB yet).")

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(status_code=401, message="Authentication failed. Invalid token.")
    except Exception as e:
        logger.error(f"Error joining interest group: {e}")
        return format_response(status_code=500, message="Internal server error.")

async def leave_interest_group(request, groupId, validated_data):
    logger.info(f"Executing leave_interest_group controller logic for group ID: {groupId}.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(status_code=401, message="Authorization header missing or invalid.")
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role != UserRole.SENIOR_CITIZEN:
            return format_response(status_code=403, message="Access denied. Only senior citizens can leave interest groups.")

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Check if group exists
                cur.execute("SELECT id FROM interest_groups WHERE id = %s", (groupId,))
                if not cur.fetchone():
                    return format_response(status_code=404, message="Interest group not found.")

                # For now, assuming a simple membership model where we just acknowledge the leave.
                # A more robust solution would involve a many-to-many table (e.g., interest_group_members).
                # If a `members` column (e.g., array of user IDs) were added to `interest_groups` table, it would be updated here.
                return format_response(status_code=200, message="Successfully left interest group (membership not persisted in DB yet).")

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(status_code=401, message="Authentication failed. Invalid token.")
    except Exception as e:
        logger.error(f"Error leaving interest group: {e}")
        return format_response(status_code=500, message="Internal server error.")