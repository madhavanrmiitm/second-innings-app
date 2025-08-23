import json

from app.database.db import get_db_connection
from app.logger import logger
from app.modules.auth.auth_service import auth_service
from app.modules.youtube.youtube_processor import youtube_processor
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

        # Get query parameters for filtering
        priority_filter = request.query_params.get("priority")
        category_filter = request.query_params.get("category")
        status_filter = request.query_params.get("status")
        ai_generated_filter = request.query_params.get(
            "ai_generated"
        )  # true/false string
        estimated_duration_min = request.query_params.get("estimated_duration_min")
        estimated_duration_max = request.query_params.get("estimated_duration_max")

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Build dynamic query with filters
                base_query = """SELECT id, title, description, time_of_completion, status,
                                      created_by, assigned_to, created_at, updated_at,
                                      priority, category, estimated_duration
                               FROM tasks
                               WHERE (created_by = %s OR assigned_to = %s)"""

                query_params = [user.id, user.id]

                # Add filters
                if priority_filter:
                    base_query += " AND priority = %s"
                    query_params.append(priority_filter)

                if category_filter:
                    base_query += " AND category = %s"
                    query_params.append(category_filter)

                if status_filter:
                    base_query += " AND status = %s"
                    query_params.append(status_filter)

                if ai_generated_filter is not None:
                    if ai_generated_filter.lower() == "true":
                        base_query += (
                            " AND priority IS NOT NULL AND category IS NOT NULL"
                        )
                    elif ai_generated_filter.lower() == "false":
                        base_query += " AND (priority IS NULL OR category IS NULL)"

                if estimated_duration_min:
                    try:
                        base_query += " AND estimated_duration >= %s"
                        query_params.append(int(estimated_duration_min))
                    except ValueError:
                        pass  # Ignore invalid duration filter

                if estimated_duration_max:
                    try:
                        base_query += " AND estimated_duration <= %s"
                        query_params.append(int(estimated_duration_max))
                    except ValueError:
                        pass  # Ignore invalid duration filter

                # Add ordering
                base_query += " ORDER BY created_at DESC"

                cur.execute(base_query, tuple(query_params))
                own_tasks = cur.fetchall()

                # If user is a family member and senior_citizen_id is provided, get tasks for that specific senior citizen
                linked_senior_tasks = []
                senior_citizen_id = None
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
                                # Build query for senior citizen tasks with same filters
                                senior_query = """SELECT t.id, t.title, t.description, t.time_of_completion, t.status,
                                                      t.created_by, t.assigned_to, t.created_at, t.updated_at,
                                                      t.priority, t.category, t.estimated_duration
                                               FROM tasks t
                                               WHERE (t.created_by = %s OR t.assigned_to = %s)"""

                                senior_params = [senior_citizen_id, senior_citizen_id]

                                # Add same filters for senior citizen tasks
                                if priority_filter:
                                    senior_query += " AND t.priority = %s"
                                    senior_params.append(priority_filter)

                                if category_filter:
                                    senior_query += " AND t.category = %s"
                                    senior_params.append(category_filter)

                                if status_filter:
                                    senior_query += " AND t.status = %s"
                                    senior_params.append(status_filter)

                                if ai_generated_filter is not None:
                                    if ai_generated_filter.lower() == "true":
                                        senior_query += " AND t.priority IS NOT NULL AND t.category IS NOT NULL"
                                    elif ai_generated_filter.lower() == "false":
                                        senior_query += " AND (t.priority IS NULL OR t.category IS NULL)"

                                if estimated_duration_min:
                                    try:
                                        senior_query += (
                                            " AND t.estimated_duration >= %s"
                                        )
                                        senior_params.append(
                                            int(estimated_duration_min)
                                        )
                                    except ValueError:
                                        pass

                                if estimated_duration_max:
                                    try:
                                        senior_query += (
                                            " AND t.estimated_duration <= %s"
                                        )
                                        senior_params.append(
                                            int(estimated_duration_max)
                                        )
                                    except ValueError:
                                        pass

                                senior_query += " ORDER BY t.created_at DESC"

                                cur.execute(senior_query, tuple(senior_params))
                                linked_senior_tasks = cur.fetchall()
                        except ValueError:
                            # Invalid senior_citizen_id parameter, ignore it
                            senior_citizen_id = None

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
                        "priority": task[9],
                        "category": task[10],
                        "estimated_duration": task[11],
                        "ai_generated": task[9] is not None
                        and task[10] is not None,  # Determine if AI generated
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

        # Check if AI mode is enabled
        ai_mode = getattr(validated_data, "ai_mode", False)
        ai_prompt = getattr(validated_data, "ai_prompt", None)

        if ai_mode and ai_prompt:
            # AI Mode: Process prompt with Gemini and extract task metadata
            try:
                # Create AI prompt for task analysis
                ai_system_prompt = """
                You are an intelligent task analysis AI that helps create detailed, actionable task metadata from natural language descriptions.

                Your job is to analyze the user's request and extract meaningful, contextual information to create a well-structured task.

                IMPORTANT: Think carefully about the context, urgency, and practical implications of the request.

                Analyze the given prompt and extract the following information in VALID JSON format:
                {
                    "title": "Clear, concise, actionable task title (max 100 chars)",
                    "description": "Detailed, step-by-step description of what needs to be done",
                    "time_of_completion": "YYYY-MM-DD HH:MM:SS format if specific time mentioned, otherwise null",
                    "assigned_to_firebase_uid": "Firebase UID if a specific person is mentioned, otherwise null",
                    "priority": "high/medium/low based on urgency, importance, and health implications",
                    "category": "health/medication/appointment/shopping/companionship/other - choose the most appropriate",
                    "estimated_duration": "estimated time in minutes based on task complexity, otherwise null"
                }

                ANALYSIS RULES:

                PRIORITY DETERMINATION:
                - HIGH: Health-critical tasks, medication, urgent appointments, safety concerns
                - MEDIUM: Regular appointments, shopping, routine care, moderate importance
                - LOW: Social activities, entertainment, non-urgent requests

                CATEGORY CLASSIFICATION:
                - HEALTH: Medical checkups, health monitoring, wellness activities
                - MEDICATION: Medicine reminders, prescription refills, dosage management
                - APPOINTMENT: Doctor visits, therapy sessions, scheduled meetings
                - SHOPPING: Groceries, supplies, personal items, household needs
                - COMPANIONSHIP: Social interaction, emotional support, recreational activities
                - OTHER: Administrative tasks, documentation, miscellaneous requests

                TIME ANALYSIS:
                - Extract specific dates and times mentioned
                - Consider urgency indicators (tomorrow, next week, urgent, etc.)
                - Format as YYYY-MM-DD HH:MM:SS or null if not specified

                DURATION ESTIMATION:
                - Consider task complexity and type
        - Medication: 2-5 minutes
        - Shopping: 30-120 minutes
        - Appointments: 15-60 minutes
        - Companionship: 30-180 minutes
        - Health monitoring: 10-30 minutes

                TITLE CREATION:
                - Be specific and actionable
                - Include key details (person, action, urgency)
                - Keep under 100 characters
                - Make it clear what needs to be done

                DESCRIPTION ENHANCEMENT:
                - Provide step-by-step instructions
                - Include important context and details
                - Mention any specific requirements or considerations
                - Make it actionable for caregivers or family members

                CONTEXT AWARENESS:
                - Consider the senior citizen context
                - Think about health and safety implications
                - Understand family dynamics and relationships
                - Consider practical implementation challenges

                EXAMPLES:

                Input: "Remind dad to take his diabetes medication tomorrow at 9 AM. This is critical for his health."
                Output: {
                    "title": "Diabetes Medication Reminder - Critical",
                    "description": "Remind dad to take his diabetes medication tomorrow at 9 AM. This is critical for his health and must not be missed. Check if medication is available and ensure he takes it with food if required.",
                    "time_of_completion": "2025-01-25 09:00:00",
                    "assigned_to_firebase_uid": null,
                    "priority": "high",
                    "category": "medication",
                    "estimated_duration": 5
                }

                Input: "Help grandma buy groceries for the week. She needs vegetables, fruits, and some basic supplies."
                Output: {
                    "title": "Weekly Grocery Shopping for Grandma",
                    "description": "Help grandma buy groceries for the week including fresh vegetables, fruits, and basic household supplies. Consider her dietary restrictions and preferences. Plan for a week's worth of meals.",
                    "time_of_completion": null,
                    "assigned_to_firebase_uid": null,
                    "priority": "medium",
                    "category": "shopping",
                    "estimated_duration": 90
                }

                Input: "Accompany mom to her cardiologist appointment next Tuesday at 2 PM. It's important."
                Output: {
                    "title": "Cardiologist Appointment - Mom",
                    "description": "Accompany mom to her cardiologist appointment next Tuesday at 2 PM. This is an important health check. Bring her medical history, current medications list, and any recent symptoms. Plan for 1 hour including travel time.",
                    "time_of_completion": "2025-01-28 14:00:00",
                    "assigned_to_firebase_uid": null,
                    "priority": "high",
                    "category": "appointment",
                    "estimated_duration": 60
                }

                Now analyze this user prompt and provide a detailed, contextually appropriate response: Don't send ``` in response. Directly send the raw JSON response.
                """

                # Combine system prompt with user prompt
                full_prompt = f"{ai_system_prompt}\n\nUSER PROMPT: {ai_prompt}\n\nProvide your analysis in valid JSON format:"

                # Process with Gemini
                ai_response = await youtube_processor.process_with_gemini_parsed(
                    full_prompt
                )

                # Validate required fields
                required_fields = ["title", "description"]
                for field in required_fields:
                    if field not in ai_response or not ai_response[field]:
                        return format_response(
                            status_code=400,
                            message=f"AI processing failed: Missing required field '{field}'",
                        )

                # Use AI-generated metadata
                title = ai_response["title"]
                description = ai_response["description"]
                time_of_completion = ai_response.get("time_of_completion")
                assigned_to_firebase_uid = ai_response.get("assigned_to_firebase_uid")
                priority = ai_response.get("priority", "medium")
                category = ai_response.get("category", "other")
                estimated_duration = ai_response.get("estimated_duration")

                logger.info(
                    f"AI Mode: Generated task metadata - Title: {title}, Priority: {priority}, Category: {category}"
                )

            except Exception as e:
                logger.error(f"AI Mode: Error processing with Gemini: {e}")
                return format_response(
                    status_code=500,
                    message="AI processing failed. Please try again or use manual mode.",
                )
        else:
            # Manual Mode: Use provided data
            title = validated_data.title
            description = validated_data.description
            time_of_completion = validated_data.time_of_completion
            assigned_to_firebase_uid = validated_data.assigned_to_firebase_uid
            priority = getattr(validated_data, "priority", "medium")
            category = getattr(validated_data, "category", "other")
            estimated_duration = getattr(validated_data, "estimated_duration", None)

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
                # Insert task with additional metadata
                cur.execute(
                    """INSERT INTO tasks (title, description, time_of_completion, created_by, assigned_to, priority, category, estimated_duration)
                       VALUES (%s, %s, %s, %s, %s, %s, %s, %s) RETURNING id""",
                    (
                        title,
                        description,
                        time_of_completion,
                        user.id,
                        assigned_to_id,
                        priority,
                        category,
                        estimated_duration,
                    ),
                )
                task_id = cur.fetchone()[0]

        # Prepare response data
        response_data = {"task_id": task_id}
        if ai_mode:
            response_data.update(
                {
                    "ai_generated": True,
                    "priority": priority,
                    "category": category,
                    "estimated_duration": estimated_duration,
                }
            )

        return format_response(
            status_code=201,
            message="Task created successfully." + (" (AI Mode)" if ai_mode else ""),
            data=response_data,
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
                    """SELECT id, title, description, time_of_completion, status, created_by, assigned_to, created_at, updated_at,
                              priority, category, estimated_duration
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
                    "priority": task_data[9],
                    "category": task_data[10],
                    "estimated_duration": task_data[11],
                    "ai_generated": task_data[9] is not None
                    and task_data[10] is not None,
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
