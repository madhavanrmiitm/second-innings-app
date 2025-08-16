from app.database.db import get_db_connection
from app.logger import logger
from app.modules.auth.auth_service import auth_service
from app.utils.response_formatter import format_response
from datetime import datetime


def _generate_admin_notifications(cur):
    """Generate dynamic notifications for admin users"""
    notifications = []
    
    # Check for pending caregiver approvals
    cur.execute(
        """SELECT COUNT(*) FROM users 
           WHERE role = 'caregiver' AND status = 'pending_approval'"""
    )
    pending_caregivers = cur.fetchone()[0]
    
    if pending_caregivers > 0:
        notifications.append({
            "id": f"admin_caregiver_pending_{pending_caregivers}",
            "user_id": None,
            "type": "care_request",
            "priority": "high",
            "body": f"{pending_caregivers} caregiver registration(s) pending approval",
            "is_read": False,  # Always unread - disappears when task is completed
            "created_at": datetime.now().isoformat(),
            "source": "dynamic"
        })
    
    # Check for pending interest group admin approvals
    cur.execute(
        """SELECT COUNT(*) FROM users 
           WHERE role = 'interest_group_admin' AND status = 'pending_approval'"""
    )
    pending_iga = cur.fetchone()[0]
    
    if pending_iga > 0:
        notifications.append({
            "id": f"admin_iga_pending_{pending_iga}",
            "user_id": None,
            "type": "interest_group",
            "priority": "high",
            "body": f"{pending_iga} Interest Group Admin registration(s) pending approval",
            "is_read": False,  # Always unread - disappears when task is completed
            "created_at": datetime.now().isoformat(),
            "source": "dynamic"
        })
    
    return notifications


def _generate_support_notifications(cur, user_id):
    """Generate dynamic notifications for support users - Currently disabled"""
    # Ticket notifications removed as requested
    return []


async def get_notifications(request):
    logger.info("Executing get_notifications controller logic.")
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
                # Get static notifications from database
                cur.execute(
                    """SELECT id, user_id, type, priority, body, is_read, created_at
                       FROM notifications
                       WHERE user_id = %s
                       ORDER BY created_at DESC""",
                    (user.id,),
                )
                static_notifications_data = cur.fetchall()

                static_notifications = [
                    {
                        "id": notif[0],
                        "user_id": notif[1],
                        "type": notif[2],
                        "priority": notif[3],
                        "body": notif[4],
                        "is_read": notif[5],
                        "created_at": notif[6].isoformat() if notif[6] else None,
                        "source": "database"
                    }
                    for notif in static_notifications_data
                ]

                # Generate dynamic notifications based on user role
                dynamic_notifications = []
                
                if user.role == 'admin':
                    dynamic_notifications.extend(_generate_admin_notifications(cur))
                elif user.role == 'support_user':
                    dynamic_notifications.extend(_generate_support_notifications(cur, user.id))
                
                # Combine all notifications and sort by priority and timestamp
                all_notifications = static_notifications + dynamic_notifications
                all_notifications.sort(key=lambda x: (
                    0 if x.get('priority') == 'high' else 1 if x.get('priority') == 'medium' else 2,
                    x.get('created_at', '9999-12-31') if x.get('created_at') else '9999-12-31'
                ), reverse=True)

        return format_response(
            status_code=200,
            message="Notifications retrieved successfully.",
            data={"notifications": all_notifications},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving notifications: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def mark_as_read(request, notificationId, validated_data):
    logger.info(
        f"Executing mark_as_read controller logic for notification ID: {notificationId}."
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
                # Check if this is a dynamic notification (has prefix like admin_, support_, etc.)
                if '_' in str(notificationId) and not str(notificationId).startswith('static_'):
                    # This is a dynamic notification, we can't mark it as read in DB
                    # Just return success for frontend state management
                    return format_response(
                        status_code=200, 
                        message="Dynamic notification marked as read successfully."
                    )
                
                # Handle static/database notifications
                actual_id = str(notificationId).replace('static_', '') if str(notificationId).startswith('static_') else notificationId
                
                # Verify ownership and if already read
                cur.execute(
                    "SELECT user_id, is_read FROM notifications WHERE id = %s",
                    (actual_id,),
                )
                notif_data = cur.fetchone()
                if not notif_data:
                    return format_response(
                        status_code=404, message="Notification not found."
                    )
                if notif_data[0] != user.id:
                    return format_response(
                        status_code=403,
                        message="Access denied. You can only mark your own notifications as read.",
                    )
                if notif_data[1] is True:
                    return format_response(
                        status_code=400,
                        message="Notification is already marked as read.",
                    )

                cur.execute(
                    "UPDATE notifications SET is_read = TRUE WHERE id = %s",
                    (actual_id,),
                )
                if cur.rowcount == 0:
                    return format_response(
                        status_code=404,
                        message="Notification not found or no changes made.",
                    )

        return format_response(
            status_code=200, message="Notification marked as read successfully."
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error marking notification as read: {e}")
        return format_response(status_code=500, message="Internal server error.")
