from app.database.db import get_db_connection
from app.logger import logger
from app.modules.auth.auth_service import auth_service
from app.payloads import UserRole
from app.utils.response_formatter import format_response


async def get_family_members(request):
    logger.info("Executing get_family_members controller logic.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or user.role != UserRole.SENIOR_CITIZEN:
            return format_response(
                status_code=403,
                message="Access denied. Only senior citizens can view family members.",
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """SELECT u.id, u.full_name, u.gmail_id, r.family_member_relation
                       FROM relations r
                       JOIN users u ON r.family_member_id = u.id
                       WHERE r.senior_citizen_id = %s""",
                    (user.id,),
                )
                family_members_data = cur.fetchall()

                family_members = [
                    {
                        "id": fm[0],
                        "full_name": fm[1],
                        "gmail_id": fm[2],
                        "relation": fm[3],
                    }
                    for fm in family_members_data
                ]

        return format_response(
            status_code=200,
            message="Family members retrieved successfully.",
            data={"family_members": family_members},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving family members: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def add_family_member(request, validated_data):
    logger.info("Executing add_family_member controller logic.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        senior_citizen_user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or senior_citizen_user.role != UserRole.SENIOR_CITIZEN:
            return format_response(
                status_code=403,
                message="Access denied. Only senior citizens can add family members.",
            )

        family_member_firebase_uid = validated_data.family_member_firebase_uid
        senior_citizen_relation = validated_data.senior_citizen_relation
        family_member_relation = validated_data.family_member_relation

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Get family member's user ID
                cur.execute(
                    "SELECT id FROM users WHERE firebase_uid = %s",
                    (family_member_firebase_uid,),
                )
                family_member_data = cur.fetchone()
                if not family_member_data:
                    return format_response(
                        status_code=404, message="Family member not found."
                    )
                family_member_id = family_member_data[0]

                # Check if relation already exists
                cur.execute(
                    "SELECT id FROM relations WHERE senior_citizen_id = %s AND family_member_id = %s",
                    (senior_citizen_user.id, family_member_id),
                )
                if cur.fetchone():
                    return format_response(
                        status_code=409, message="Relation already exists."
                    )

                # Add relation
                cur.execute(
                    """INSERT INTO relations (senior_citizen_id, family_member_id, senior_citizen_relation, family_member_relation)
                       VALUES (%s, %s, %s, %s) RETURNING id""",
                    (
                        senior_citizen_user.id,
                        family_member_id,
                        senior_citizen_relation,
                        family_member_relation,
                    ),
                )
                relation_id = cur.fetchone()[0]

        return format_response(
            status_code=201,
            message="Family member added successfully.",
            data={"relation_id": relation_id},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error adding family member: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def remove_family_member(request, memberId, validated_data):
    logger.info("Executing remove_family_member controller logic.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        senior_citizen_user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or senior_citizen_user.role != UserRole.SENIOR_CITIZEN:
            return format_response(
                status_code=403,
                message="Access denied. Only senior citizens can remove family members.",
            )

        family_member_firebase_uid = validated_data.family_member_firebase_uid

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Get family member's user ID
                cur.execute(
                    "SELECT id FROM users WHERE firebase_uid = %s",
                    (family_member_firebase_uid,),
                )
                family_member_data = cur.fetchone()
                if not family_member_data:
                    return format_response(
                        status_code=404, message="Family member not found."
                    )
                family_member_id = family_member_data[0]

                # Remove relation
                cur.execute(
                    "DELETE FROM relations WHERE senior_citizen_id = %s AND family_member_id = %s",
                    (senior_citizen_user.id, family_member_id),
                )
                if cur.rowcount == 0:
                    return format_response(
                        status_code=404, message="Relation not found."
                    )

        return format_response(
            status_code=200, message="Family member removed successfully."
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error removing family member: {e}")
        return format_response(status_code=500, message="Internal server error.")
