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
                        """SELECT id, title, description, whatsapp_link, category, status, timing, created_by, created_at, updated_at, member_count
                           FROM interest_groups ORDER BY created_at DESC"""
                    )
                elif user.role == UserRole.INTEREST_GROUP_ADMIN:
                    cur.execute(
                        """SELECT id, title, description, whatsapp_link, category, status, timing, created_by, created_at, updated_at, member_count
                           FROM interest_groups WHERE created_by = %s ORDER BY created_at DESC""",
                        (user.id,),
                    )
                else:
                    # Public view - only active groups
                    cur.execute(
                        """SELECT id, title, description, whatsapp_link, category, status, timing, created_by, created_at, updated_at, member_count
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
                        "member_count": ig[10],
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
        if not is_registered or (
            user.role != UserRole.INTEREST_GROUP_ADMIN
            and user.role != UserRole.ADMIN
            and user.role != UserRole.SENIOR_CITIZEN
        ):
            return format_response(
                status_code=403,
                message="Access denied. Only interest group admins, senior citizens, and system admins can create groups.",
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
                print(user.id)
                cur.execute(
                    """INSERT INTO interest_groups (title, description, whatsapp_link, category, timing, created_by, member_count)
                       VALUES (%s, %s, %s, %s, %s, %s, 1) RETURNING id""",
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

                # Add creator as the first member
                cur.execute(
                    """INSERT INTO group_members (group_id, user_id) VALUES (%s, %s)""",
                    (group_id, user.id),
                )

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
                    """SELECT id, title, description, whatsapp_link, category, status, timing, created_by, created_at, updated_at, member_count
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
                    "member_count": interest_group_data[10],
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
        if not is_registered or (
            user.role != UserRole.INTEREST_GROUP_ADMIN
            and user.role != UserRole.ADMIN
            and user.role != UserRole.SENIOR_CITIZEN
        ):
            return format_response(
                status_code=403,
                message="Access denied. Only interest group admins, senior citizens, and system admins can update groups.",
            )

        # Validate WhatsApp link format if provided
        if (
            validated_data.whatsapp_link
            and not validated_data.whatsapp_link.startswith(
                "https://chat.whatsapp.com/"
            )
        ):
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
                if (
                    user.role == UserRole.INTEREST_GROUP_ADMIN
                    and group_owner_data[0] != user.id
                ):
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
        if not is_registered or (
            user.role != UserRole.INTEREST_GROUP_ADMIN
            and user.role != UserRole.ADMIN
            and user.role != UserRole.SENIOR_CITIZEN
        ):
            return format_response(
                status_code=403,
                message="Access denied. Only interest group admins, senior citizens, and system admins can delete groups.",
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Verify ownership (IGAs can only delete their own groups, admins can delete any)
                cur.execute(
                    "SELECT created_by, title FROM interest_groups WHERE id = %s",
                    (groupId,),
                )
                group_data = cur.fetchone()
                if not group_data:
                    return format_response(
                        status_code=404, message="Interest group not found."
                    )

                # Check permissions
                if (
                    user.role == UserRole.INTEREST_GROUP_ADMIN
                    and group_data[0] != user.id
                ):
                    return format_response(
                        status_code=403,
                        message="Access denied. You can only delete groups you created.",
                    )

                # Delete group members first (due to foreign key constraint)
                cur.execute("DELETE FROM group_members WHERE group_id = %s", (groupId,))

                # Delete the group
                cur.execute("DELETE FROM interest_groups WHERE id = %s", (groupId,))

                if cur.rowcount == 0:
                    return format_response(
                        status_code=404, message="Interest group not found."
                    )

        return format_response(
            status_code=200,
            message=f"Interest group '{group_data[1]}' deleted successfully.",
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
                    """SELECT id, title, description, whatsapp_link, category, timing, created_at, member_count
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
                        "member_count": ig[7],
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


async def join_group(request, groupId):
    """Allow users to join an interest group"""
    logger.info(f"Executing join_group controller logic for group ID: {groupId}.")
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
                # Check if group exists and is active
                cur.execute(
                    """SELECT id, title, status, member_count FROM interest_groups WHERE id = %s""",
                    (groupId,),
                )
                group_data = cur.fetchone()

                if not group_data:
                    return format_response(
                        status_code=404, message="Interest group not found."
                    )

                if group_data[2] != "active":
                    return format_response(
                        status_code=400, message="Cannot join inactive interest group."
                    )

                # Check if user is already a member
                cur.execute(
                    """SELECT id FROM group_members WHERE group_id = %s AND user_id = %s""",
                    (groupId, user.id),
                )
                existing_member = cur.fetchone()

                if existing_member:
                    return format_response(
                        status_code=400,
                        message="You are already a member of this group.",
                    )

                # Add user to group
                cur.execute(
                    """INSERT INTO group_members (group_id, user_id) VALUES (%s, %s)""",
                    (groupId, user.id),
                )

                # Update member count
                cur.execute(
                    """UPDATE interest_groups SET member_count = member_count + 1, updated_at = CURRENT_TIMESTAMP WHERE id = %s""",
                    (groupId,),
                )

        return format_response(
            status_code=200,
            message=f"Successfully joined {group_data[1]} group.",
            data={"group_id": groupId, "member_count": group_data[3] + 1},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error joining group: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def leave_group(request, groupId):
    """Allow users to leave an interest group"""
    logger.info(f"Executing leave_group controller logic for group ID: {groupId}.")
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
                # Check if group exists
                cur.execute(
                    """SELECT id, title, member_count FROM interest_groups WHERE id = %s""",
                    (groupId,),
                )
                group_data = cur.fetchone()

                if not group_data:
                    return format_response(
                        status_code=404, message="Interest group not found."
                    )

                # Check if user is a member
                cur.execute(
                    """SELECT id FROM group_members WHERE group_id = %s AND user_id = %s""",
                    (groupId, user.id),
                )
                existing_member = cur.fetchone()

                if not existing_member:
                    return format_response(
                        status_code=400, message="You are not a member of this group."
                    )

                # Remove user from group
                cur.execute(
                    """DELETE FROM group_members WHERE group_id = %s AND user_id = %s""",
                    (groupId, user.id),
                )

                # Update member count
                cur.execute(
                    """UPDATE interest_groups SET member_count = member_count - 1, updated_at = CURRENT_TIMESTAMP WHERE id = %s""",
                    (groupId,),
                )

        return format_response(
            status_code=200,
            message=f"Successfully left {group_data[1]} group.",
            data={"group_id": groupId, "member_count": group_data[2] - 1},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error leaving group: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def get_my_groups(request):
    """Get all groups that the current user has joined"""
    logger.info("Executing get_my_groups controller logic.")
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
                    """SELECT ig.id, ig.title, ig.description, ig.whatsapp_link, ig.category,
                              ig.status, ig.timing, ig.created_by, ig.created_at, ig.updated_at,
                              ig.member_count, gm.joined_at
                       FROM interest_groups ig
                       INNER JOIN group_members gm ON ig.id = gm.group_id
                       WHERE gm.user_id = %s
                       ORDER BY gm.joined_at DESC""",
                    (user.id,),
                )
                groups_data = cur.fetchall()

                groups = [
                    {
                        "id": group[0],
                        "title": group[1],
                        "description": group[2],
                        "whatsapp_link": group[3],
                        "category": group[4],
                        "status": group[5],
                        "timing": group[6],
                        "created_by": group[7],
                        "created_at": group[8],
                        "updated_at": group[9],
                        "member_count": group[10],
                        "joined_at": group[11],
                    }
                    for group in groups_data
                ]

        return format_response(
            status_code=200,
            message="Your groups retrieved successfully.",
            data={"groups": groups},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving user groups: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def get_group_members(request, groupId):
    """Get all members of a specific group (for group admins and admins)"""
    logger.info(
        f"Executing get_group_members controller logic for group ID: {groupId}."
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
                # Check if group exists
                cur.execute(
                    """SELECT id, title, created_by FROM interest_groups WHERE id = %s""",
                    (groupId,),
                )
                group_data = cur.fetchone()

                if not group_data:
                    return format_response(
                        status_code=404, message="Interest group not found."
                    )

                # Check permissions - only group creator, admins, or group members can see members
                if user.role != UserRole.ADMIN and group_data[2] != user.id:
                    # Check if user is a member of this group
                    cur.execute(
                        """SELECT id FROM group_members WHERE group_id = %s AND user_id = %s""",
                        (groupId, user.id),
                    )
                    is_member = cur.fetchone()
                    if not is_member:
                        return format_response(
                            status_code=403,
                            message="Access denied. You can only view members of groups you're part of or created.",
                        )

                # Get group members
                cur.execute(
                    """SELECT u.id, u.full_name, u.role, u.status, gm.joined_at
                       FROM group_members gm
                       INNER JOIN users u ON gm.user_id = u.id
                       WHERE gm.group_id = %s
                       ORDER BY gm.joined_at ASC""",
                    (groupId,),
                )
                members_data = cur.fetchall()

                members = [
                    {
                        "user_id": member[0],
                        "full_name": member[1],
                        "role": member[2],
                        "status": member[3],
                        "joined_at": member[4],
                    }
                    for member in members_data
                ]

        return format_response(
            status_code=200,
            message=f"Group members for '{group_data[1]}' retrieved successfully.",
            data={
                "group_id": groupId,
                "group_title": group_data[1],
                "members": members,
            },
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving group members: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def get_my_created_groups(request):
    """Get all groups that the current user has created"""
    logger.info("Executing get_my_created_groups controller logic.")
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

        print(user.id)

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """SELECT id, title, description, whatsapp_link, category, status, timing,
                              created_by, created_at, updated_at, member_count
                       FROM interest_groups
                       WHERE created_by = %s
                       ORDER BY created_at DESC""",
                    (user.id,),
                )
                groups_data = cur.fetchall()

                groups = [
                    {
                        "id": group[0],
                        "title": group[1],
                        "description": group[2],
                        "whatsapp_link": group[3],
                        "category": group[4],
                        "status": group[5],
                        "timing": group[6],
                        "created_by": group[7],
                        "created_at": group[8],
                        "updated_at": group[9],
                        "member_count": group[10],
                    }
                    for group in groups_data
                ]

        return format_response(
            status_code=200,
            message="Your created groups retrieved successfully.",
            data={"groups": groups},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving user's created groups: {e}")
        return format_response(status_code=500, message="Internal server error.")
