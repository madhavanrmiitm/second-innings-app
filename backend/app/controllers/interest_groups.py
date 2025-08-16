from app.database.db import get_db_connection
from app.logger import logger
from app.modules.auth.auth_service import auth_service
from app.payloads import UserRole
from app.utils.response_formatter import format_response


async def get_interest_groups(request):
    logger.info("Executing get_interest_groups controller logic.")
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
                # If user is admin, show all groups; if IGA, show only their groups
                if user.role == UserRole.ADMIN:
                    cur.execute(
                        """SELECT id, title, description, whatsapp_link, category, status, timing, created_by, created_at, updated_at
                           FROM interest_groups ORDER BY created_at DESC"""
                    )
                elif user.role == UserRole.INTEREST_GROUP_ADMIN:
                    cur.execute(
                        """SELECT id, title, description, whatsapp_link, category, status, timing, created_by, created_at, updated_at
                           FROM interest_groups WHERE created_by = %s ORDER BY created_at DESC""",
                        (user.id,)
                    )
                else:
                    # Public view - only active groups
                    cur.execute(
                        """SELECT id, title, description, whatsapp_link, category, status, timing, created_by, created_at, updated_at
                           FROM interest_groups WHERE status = 'active' ORDER BY created_at DESC"""
                    )
                
                interest_groups_data = cur.fetchall()

                interest_groups = [
                    {
                        "id": ig[0],
                        "title": ig[1],
                        "description": ig[2],
                        "whatsapp_link": ig[3],
                        "category": ig[4],
                        "status": ig[5],
                        "timing": ig[6],
                        "created_by": ig[7],
                        "created_at": ig[8],
                        "updated_at": ig[9],
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
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving interest groups: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def create_interest_group(request, validated_data):
    logger.info("Executing create_interest_group controller logic.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or (user.role != UserRole.INTEREST_GROUP_ADMIN and user.role != UserRole.ADMIN):
            return format_response(
                status_code=403,
                message="Access denied. Only interest group admins and system admins can create groups.",
            )

        title = validated_data.title
        description = validated_data.description
        whatsapp_link = validated_data.whatsapp_link
        category = validated_data.category
        timing = validated_data.timing

        # Validate WhatsApp link format if provided
        if whatsapp_link and not whatsapp_link.startswith("https://chat.whatsapp.com/"):
            return format_response(
                status_code=400,
                message="Invalid WhatsApp link format. Must start with 'https://chat.whatsapp.com/'",
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """INSERT INTO interest_groups (title, description, whatsapp_link, category, timing, created_by)
                       VALUES (%s, %s, %s, %s, %s, %s) RETURNING id""",
                    (
                        title,
                        description,
                        whatsapp_link,
                        category,
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
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error creating interest group: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def get_interest_group(request, groupId):
    logger.info(
        f"Executing get_interest_group controller logic for group ID: {groupId}."
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
                    """SELECT id, title, description, whatsapp_link, category, status, timing, created_by, created_at, updated_at
                       FROM interest_groups
                       WHERE id = %s""",
                    (groupId,),
                )
                interest_group_data = cur.fetchone()

                if not interest_group_data:
                    return format_response(
                        status_code=404, message="Interest group not found."
                    )

                interest_group = {
                    "id": interest_group_data[0],
                    "title": interest_group_data[1],
                    "description": interest_group_data[2],
                    "whatsapp_link": interest_group_data[3],
                    "category": interest_group_data[4],
                    "status": interest_group_data[5],
                    "timing": interest_group_data[6],
                    "created_by": interest_group_data[7],
                    "created_at": interest_group_data[8],
                    "updated_at": interest_group_data[9],
                }

        return format_response(
            status_code=200,
            message="Interest group retrieved successfully.",
            data={"interest_group": interest_group},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving interest group: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def update_interest_group(request, groupId, validated_data):
    logger.info(
        f"Executing update_interest_group controller logic for group ID: {groupId}."
    )
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or (user.role != UserRole.INTEREST_GROUP_ADMIN and user.role != UserRole.ADMIN):
            return format_response(
                status_code=403,
                message="Access denied. Only interest group admins and system admins can update groups.",
            )

        # Validate WhatsApp link format if provided
        if validated_data.whatsapp_link and not validated_data.whatsapp_link.startswith("https://chat.whatsapp.com/"):
            return format_response(
                status_code=400,
                message="Invalid WhatsApp link format. Must start with 'https://chat.whatsapp.com/'",
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Verify ownership (IGAs can only edit their own groups, admins can edit any)
                cur.execute(
                    "SELECT created_by FROM interest_groups WHERE id = %s", (groupId,)
                )
                group_owner_data = cur.fetchone()
                if not group_owner_data:
                    return format_response(
                        status_code=404, message="Interest group not found."
                    )
                
                # Check permissions
                if user.role == UserRole.INTEREST_GROUP_ADMIN and group_owner_data[0] != user.id:
                    return format_response(
                        status_code=403,
                        message="Access denied. You can only update groups you created.",
                    )

                update_fields = []
                update_values = []

                if validated_data.title is not None:
                    update_fields.append("title = %s")
                    update_values.append(validated_data.title)
                if validated_data.description is not None:
                    update_fields.append("description = %s")
                    update_values.append(validated_data.description)
                if validated_data.whatsapp_link is not None:
                    update_fields.append("whatsapp_link = %s")
                    update_values.append(validated_data.whatsapp_link)
                if validated_data.category is not None:
                    update_fields.append("category = %s")
                    update_values.append(validated_data.category)
                if validated_data.status is not None:
                    update_fields.append("status = %s")
                    update_values.append(validated_data.status)
                if validated_data.timing is not None:
                    update_fields.append("timing = %s")
                    update_values.append(validated_data.timing)

                if not update_fields:
                    return format_response(
                        status_code=400, message="No fields to update."
                    )

                update_values.append(groupId)
                update_query = f"UPDATE interest_groups SET {', '.join(update_fields)}, updated_at = CURRENT_TIMESTAMP WHERE id = %s"

                cur.execute(update_query, tuple(update_values))
                if cur.rowcount == 0:
                    return format_response(
                        status_code=404,
                        message="Interest group not found or no changes made.",
                    )

        return format_response(
            status_code=200, message="Interest group updated successfully."
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error updating interest group: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def delete_interest_group(request, groupId):
    logger.info(
        f"Executing delete_interest_group controller logic for group ID: {groupId}."
    )
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or (user.role != UserRole.INTEREST_GROUP_ADMIN and user.role != UserRole.ADMIN):
            return format_response(
                status_code=403,
                message="Access denied. Only interest group admins and system admins can delete groups.",
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Verify ownership (IGAs can only delete their own groups, admins can delete any)
                cur.execute(
                    "SELECT created_by, title FROM interest_groups WHERE id = %s", (groupId,)
                )
                group_data = cur.fetchone()
                if not group_data:
                    return format_response(
                        status_code=404, message="Interest group not found."
                    )
                
                # Check permissions
                if user.role == UserRole.INTEREST_GROUP_ADMIN and group_data[0] != user.id:
                    return format_response(
                        status_code=403,
                        message="Access denied. You can only delete groups you created.",
                    )

                # Delete the group
                cur.execute("DELETE FROM interest_groups WHERE id = %s", (groupId,))
                
                if cur.rowcount == 0:
                    return format_response(
                        status_code=404, message="Interest group not found."
                    )

        return format_response(
            status_code=200, 
            message=f"Interest group '{group_data[1]}' deleted successfully."
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error deleting interest group: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def get_public_interest_groups(request):
    """Public endpoint to get active interest groups for senior citizens to browse"""
    logger.info("Executing get_public_interest_groups controller logic.")
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """SELECT id, title, description, whatsapp_link, category, timing, created_at
                       FROM interest_groups 
                       WHERE status = 'active' 
                       ORDER BY created_at DESC"""
                )
                interest_groups_data = cur.fetchall()

                interest_groups = [
                    {
                        "id": ig[0],
                        "title": ig[1],
                        "description": ig[2],
                        "whatsapp_link": ig[3],
                        "category": ig[4],
                        "timing": ig[5],
                        "created_at": ig[6],
                    }
                    for ig in interest_groups_data
                ]

        return format_response(
            status_code=200,
            message="Public interest groups retrieved successfully.",
            data={"interest_groups": interest_groups},
        )

    except Exception as e:
        logger.error(f"Error retrieving public interest groups: {e}")
        return format_response(status_code=500, message="Internal server error.")
