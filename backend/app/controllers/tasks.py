from app.database.db import get_db_connection
from app.logger import logger
from app.modules.auth.auth_service import auth_service
from app.payloads import TaskStatus, UserRole
from app.utils.response_formatter import format_response


async def get_tasks(request):
    logger.info("Executing get_tasks controller logic.")
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
                # Get tasks created by and assigned to the user
                cur.execute(
                    """SELECT id, title, description, time_of_completion, status, created_by, assigned_to, created_at, updated_at
                       FROM tasks
                       WHERE created_by = %s OR assigned_to = %s""",
                    (user.id, user.id),
                )
                own_tasks = cur.fetchall()

                # If user is a family member and senior_citizen_id is provided, get tasks for that specific senior citizen
                linked_senior_tasks = []
                if user.role == UserRole.FAMILY_MEMBER:
                    # Check if senior_citizen_id query parameter is provided
                    senior_citizen_id = request.query_params.get("senior_citizen_id")
                    if senior_citizen_id:
                        try:
                            senior_citizen_id = int(senior_citizen_id)
                            # Verify the family member has a relationship with this senior citizen
                            cur.execute(
                                "SELECT 1 FROM relations WHERE family_member_id = %s AND senior_citizen_id = %s",
                                (user.id, senior_citizen_id),
                            )
                            if cur.fetchone():
                                # Get tasks for the specified senior citizen
                                cur.execute(
                                    """SELECT t.id, t.title, t.description, t.time_of_completion, t.status,
                                              t.created_by, t.assigned_to, t.created_at, t.updated_at
                                       FROM tasks t
                                       WHERE t.created_by = %s OR t.assigned_to = %s""",
                                    (senior_citizen_id, senior_citizen_id),
                                )
                                linked_senior_tasks = cur.fetchall()
                        except ValueError:
                            # Invalid senior_citizen_id parameter, ignore it
                            pass

                # Combine and format all tasks
                all_tasks = own_tasks
                if senior_citizen_id:
                    all_tasks = linked_senior_tasks

                tasks = [
                    {
                        "id": task[0],
                        "title": task[1],
                        "description": task[2],
                        "time_of_completion": task[3],
                        "status": task[4],
                        "created_by": task[5],
                        "assigned_to": task[6],
                        "created_at": task[7],
                        "updated_at": task[8],
                    }
                    for task in all_tasks
                ]

        return format_response(
            status_code=200,
            message="Tasks retrieved successfully.",
            data={"tasks": tasks},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving tasks: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def create_task(request, validated_data):
    logger.info("Executing create_task controller logic.")
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

        title = validated_data.title
        description = validated_data.description
        time_of_completion = validated_data.time_of_completion
        assigned_to_firebase_uid = validated_data.assigned_to_firebase_uid

        assigned_to_id = None
        if assigned_to_firebase_uid:
            with get_db_connection() as conn:
                with conn.cursor() as cur:
                    cur.execute(
                        "SELECT id FROM users WHERE firebase_uid = %s",
                        (assigned_to_firebase_uid,),
                    )
                    assigned_to_data = cur.fetchone()
                    if not assigned_to_data:
                        return format_response(
                            status_code=404, message="Assigned user not found."
                        )
                    assigned_to_id = assigned_to_data[0]

                    # If user is a family member, verify they can assign tasks to the senior citizen
                    if user.role == UserRole.FAMILY_MEMBER and assigned_to_id:
                        cur.execute(
                            """SELECT 1 FROM relations
                               WHERE family_member_id = %s AND senior_citizen_id = %s""",
                            (user.id, assigned_to_id),
                        )
                        if not cur.fetchone():
                            return format_response(
                                status_code=403,
                                message="You can only assign tasks to senior citizens linked to you.",
                            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """INSERT INTO tasks (title, description, time_of_completion, created_by, assigned_to)
                       VALUES (%s, %s, %s, %s, %s) RETURNING id""",
                    (
                        title,
                        description,
                        time_of_completion,
                        user.id,
                        assigned_to_id,
                    ),
                )
                task_id = cur.fetchone()[0]

        return format_response(
            status_code=201,
            message="Task created successfully.",
            data={"task_id": task_id},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error creating task: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def get_task(request, taskId):
    logger.info(f"Executing get_task controller logic for task ID: {taskId}.")
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
                    """SELECT id, title, description, time_of_completion, status, created_by, assigned_to, created_at, updated_at
                       FROM tasks
                       WHERE id = %s""",
                    (taskId,),
                )
                task_data = cur.fetchone()

                if not task_data:
                    return format_response(status_code=404, message="Task not found.")

                # Check permissions - user can view if they created, are assigned to, or are a family member linked to the senior citizen
                created_by_id = task_data[5]
                assigned_to_id = task_data[6]

                has_access = False
                if user.id == created_by_id or user.id == assigned_to_id:
                    has_access = True
                elif user.role == UserRole.FAMILY_MEMBER:
                    # Check if user is linked to the senior citizen involved in the task
                    senior_citizen_id = (
                        created_by_id if created_by_id else assigned_to_id
                    )
                    if senior_citizen_id:
                        cur.execute(
                            """SELECT 1 FROM relations
                               WHERE family_member_id = %s AND senior_citizen_id = %s""",
                            (user.id, senior_citizen_id),
                        )
                        has_access = cur.fetchone() is not None

                if not has_access:
                    return format_response(
                        status_code=403,
                        message="Access denied. You can only view tasks you created, are assigned to, or are linked to as a family member.",
                    )

                task = {
                    "id": task_data[0],
                    "title": task_data[1],
                    "description": task_data[2],
                    "time_of_completion": task_data[3],
                    "status": task_data[4],
                    "created_by": task_data[5],
                    "assigned_to": task_data[6],
                    "created_at": task_data[7],
                    "updated_at": task_data[8],
                }

        return format_response(
            status_code=200,
            message="Task retrieved successfully.",
            data={"task": task},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving task: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def update_task(request, taskId, validated_data):
    logger.info(f"Executing update_task controller logic for task ID: {taskId}.")
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
                # Verify ownership/permission
                cur.execute(
                    "SELECT created_by, assigned_to FROM tasks WHERE id = %s", (taskId,)
                )
                task_owner_data = cur.fetchone()
                if not task_owner_data:
                    return format_response(status_code=404, message="Task not found.")

                created_by_id = task_owner_data[0]
                assigned_to_id = task_owner_data[1]

                # Check permissions - user can update if they created, are assigned to, or are a family member linked to the senior citizen
                has_access = False
                if user.id == created_by_id or user.id == assigned_to_id:
                    has_access = True
                elif user.role == UserRole.FAMILY_MEMBER:
                    # Check if user is linked to the senior citizen involved in the task
                    senior_citizen_id = (
                        created_by_id if created_by_id else assigned_to_id
                    )
                    if senior_citizen_id:
                        cur.execute(
                            """SELECT 1 FROM relations
                               WHERE family_member_id = %s AND senior_citizen_id = %s""",
                            (user.id, senior_citizen_id),
                        )
                        has_access = cur.fetchone() is not None

                if not has_access:
                    return format_response(
                        status_code=403,
                        message="Access denied. You can only update tasks you created, are assigned to, or are linked to as a family member.",
                    )

                update_fields = []
                update_values = []

                if validated_data.title is not None:
                    update_fields.append("title = %s")
                    update_values.append(validated_data.title)
                if validated_data.description is not None:
                    update_fields.append("description = %s")
                    update_values.append(validated_data.description)
                if validated_data.time_of_completion is not None:
                    update_fields.append("time_of_completion = %s")
                    update_values.append(validated_data.time_of_completion)
                if validated_data.status is not None:
                    update_fields.append("status = %s")
                    update_values.append(validated_data.status.value)
                if validated_data.assigned_to_firebase_uid is not None:
                    cur.execute(
                        "SELECT id FROM users WHERE firebase_uid = %s",
                        (validated_data.assigned_to_firebase_uid,),
                    )
                    new_assigned_to_data = cur.fetchone()
                    if not new_assigned_to_data:
                        return format_response(
                            status_code=404, message="New assigned user not found."
                        )

                    # If user is a family member, verify they can assign tasks to the senior citizen
                    if user.role == UserRole.FAMILY_MEMBER:
                        cur.execute(
                            """SELECT 1 FROM relations
                               WHERE family_member_id = %s AND senior_citizen_id = %s""",
                            (user.id, new_assigned_to_data[0]),
                        )
                        if not cur.fetchone():
                            return format_response(
                                status_code=403,
                                message="You can only assign tasks to senior citizens linked to you.",
                            )

                    update_fields.append("assigned_to = %s")
                    update_values.append(new_assigned_to_data[0])

                if not update_fields:
                    return format_response(
                        status_code=400, message="No fields to update."
                    )

                update_values.append(taskId)
                update_query = f"UPDATE tasks SET {', '.join(update_fields)}, updated_at = CURRENT_TIMESTAMP WHERE id = %s"

                cur.execute(update_query, tuple(update_values))
                if cur.rowcount == 0:
                    return format_response(
                        status_code=404, message="Task not found or no changes made."
                    )

        return format_response(status_code=200, message="Task updated successfully.")

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error updating task: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def mark_task_done(request, taskId, validated_data):
    logger.info(f"Executing mark_task_done controller logic for task ID: {taskId}.")
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
                # Verify ownership/permission
                cur.execute(
                    "SELECT created_by, assigned_to, status FROM tasks WHERE id = %s",
                    (taskId,),
                )
                task_data = cur.fetchone()
                if not task_data:
                    return format_response(status_code=404, message="Task not found.")

                created_by_id = task_data[0]
                assigned_to_id = task_data[1]
                current_status = task_data[2]

                # Check permissions - user can mark as done if they created, are assigned to, or are a family member linked to the senior citizen
                has_access = False
                if user.id == created_by_id or user.id == assigned_to_id:
                    has_access = True
                elif user.role == UserRole.FAMILY_MEMBER:
                    # Check if user is linked to the senior citizen involved in the task
                    senior_citizen_id = (
                        created_by_id if created_by_id else assigned_to_id
                    )
                    if senior_citizen_id:
                        cur.execute(
                            """SELECT 1 FROM relations
                               WHERE family_member_id = %s AND senior_citizen_id = %s""",
                            (user.id, senior_citizen_id),
                        )
                        has_access = cur.fetchone() is not None

                if not has_access:
                    return format_response(
                        status_code=403,
                        message="Access denied. You can only mark tasks as done that you created, are assigned to, or are linked to as a family member.",
                    )

                if current_status == TaskStatus.COMPLETED.value:
                    return format_response(
                        status_code=400, message="Task is already completed."
                    )

                cur.execute(
                    "UPDATE tasks SET status = %s, updated_at = CURRENT_TIMESTAMP WHERE id = %s",
                    (TaskStatus.COMPLETED.value, taskId),
                )
                if cur.rowcount == 0:
                    return format_response(
                        status_code=404, message="Task not found or no changes made."
                    )

        return format_response(
            status_code=200, message="Task marked as done successfully."
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error marking task as done: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def delete_task(request, taskId, validated_data):
    logger.info(f"Executing delete_task controller logic for task ID: {taskId}.")
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
                # Verify ownership/permission
                cur.execute(
                    "SELECT created_by, assigned_to FROM tasks WHERE id = %s", (taskId,)
                )
                task_owner_data = cur.fetchone()
                if not task_owner_data:
                    return format_response(status_code=404, message="Task not found.")

                created_by_id = task_owner_data[0]
                assigned_to_id = task_owner_data[1]

                # Check permissions - user can delete if they created, are assigned to, or are a family member linked to the senior citizen
                has_access = False
                if user.id == created_by_id or user.id == assigned_to_id:
                    has_access = True
                elif user.role == UserRole.FAMILY_MEMBER:
                    # Check if user is linked to the senior citizen involved in the task
                    senior_citizen_id = (
                        created_by_id if created_by_id else assigned_to_id
                    )
                    if senior_citizen_id:
                        cur.execute(
                            """SELECT 1 FROM relations
                               WHERE family_member_id = %s AND senior_citizen_id = %s""",
                            (user.id, senior_citizen_id),
                        )
                        has_access = cur.fetchone() is not None

                if not has_access:
                    return format_response(
                        status_code=403,
                        message="Access denied. You can only delete tasks you created, are assigned to, or are linked to as a family member.",
                    )

                cur.execute("DELETE FROM tasks WHERE id = %s", (taskId,))
                if cur.rowcount == 0:
                    return format_response(
                        status_code=404, message="Task not found or no changes made."
                    )

        return format_response(status_code=200, message="Task deleted successfully.")

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error deleting task: {e}")
        return format_response(status_code=500, message="Internal server error.")
