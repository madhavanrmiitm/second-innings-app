from app.utils.response_formatter import format_response
from app.modules.auth.auth_service import auth_service
from app.database.db import get_db_connection
from app.logger import logger

async def get_notifications(request):
    logger.info("Executing get_notifications controller logic.")
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
                    """SELECT id, user_id, type, priority, body, is_read, created_at
                       FROM notifications
                       WHERE user_id = %s
                       ORDER BY created_at DESC""",
                    (user.id,)
                )
                notifications_data = cur.fetchall()

                notifications = [
                    {
                        "id": notif[0],
                        "user_id": notif[1],
                        "type": notif[2],
                        "priority": notif[3],
                        "body": notif[4],
                        "is_read": notif[5],
                        "created_at": notif[6],
                    }
                    for notif in notifications_data
                ]

        return format_response(
            status_code=200,
            message="Notifications retrieved successfully.",
            data={"notifications": notifications},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(status_code=401, message="Authentication failed. Invalid token.")
    except Exception as e:
        logger.error(f"Error retrieving notifications: {e}")
        return format_response(status_code=500, message="Internal server error.")

async def mark_as_read(request, notificationId, validated_data):
    logger.info(f"Executing mark_as_read controller logic for notification ID: {notificationId}.")
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
                # Verify ownership and if already read
                cur.execute(
                    "SELECT user_id, is_read FROM notifications WHERE id = %s",
                    (notificationId,)
                )
                notif_data = cur.fetchone()
                if not notif_data:
                    return format_response(status_code=404, message="Notification not found.")
                if notif_data[0] != user.id:
                    return format_response(status_code=403, message="Access denied. You can only mark your own notifications as read.")
                if notif_data[1] is True:
                    return format_response(status_code=400, message="Notification is already marked as read.")

                cur.execute(
                    "UPDATE notifications SET is_read = TRUE WHERE id = %s",
                    (notificationId,)
                )
                if cur.rowcount == 0:
                    return format_response(status_code=404, message="Notification not found or no changes made.")

        return format_response(status_code=200, message="Notification marked as read successfully.")

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(status_code=401, message="Authentication failed. Invalid token.")
    except Exception as e:
        logger.error(f"Error marking notification as read: {e}")
        return format_response(status_code=500, message="Internal server error.")