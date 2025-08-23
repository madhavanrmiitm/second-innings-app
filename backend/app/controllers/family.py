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
                    """SELECT u.id, u.full_name, u.gmail_id, u.firebase_uid, r.family_member_relation
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
                        "firebase_uid": fm[3],
                        "relation": fm[4],
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
                    "SELECT id FROM users WHERE gmail_id = %s",
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


async def get_linked_senior_citizens(request):
    logger.info("Executing get_linked_senior_citizens controller logic.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        family_member_user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or family_member_user.role != UserRole.FAMILY_MEMBER:
            return format_response(
                status_code=403,
                message="Access denied. Only family members can view linked senior citizens.",
            )

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    """SELECT u.id, u.full_name, u.gmail_id, r.family_member_relation, u.status
                       FROM relations r
                       JOIN users u ON r.senior_citizen_id = u.id
                       WHERE r.family_member_id = %s""",
                    (family_member_user.id,),
                )
                senior_citizens_data = cur.fetchall()

                linked_senior_citizens = [
                    {
                        "id": sc[0],
                        "full_name": sc[1],
                        "gmail_id": sc[2],
                        "relation": sc[3],
                        "status": sc[4],
                    }
                    for sc in senior_citizens_data
                ]

        return format_response(
            status_code=200,
            message="Linked senior citizens retrieved successfully.",
            data={"linked_senior_citizens": linked_senior_citizens},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error retrieving linked senior citizens: {e}")
        return format_response(status_code=500, message="Internal server error.")


async def link_senior_citizen(request, validated_data):
    logger.info("Executing link_senior_citizen controller logic.")
    try:
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return format_response(
                status_code=401, message="Authorization header missing or invalid."
            )
        id_token = auth_header.split(" ")[1]

        family_member_user, is_registered = auth_service.authenticate_user(id_token)
        if not is_registered or family_member_user.role != UserRole.FAMILY_MEMBER:
            return format_response(
                status_code=403,
                message="Access denied. Only family members can link senior citizens.",
            )

        senior_citizen_email = validated_data.senior_citizen_email
        relation = validated_data.relation

        with get_db_connection() as conn:
            with conn.cursor() as cur:
                # Get senior citizen's user ID by email
                cur.execute(
                    "SELECT id FROM users WHERE gmail_id = %s AND role = %s",
                    (senior_citizen_email, UserRole.SENIOR_CITIZEN),
                )
                senior_citizen_data = cur.fetchone()
                if not senior_citizen_data:
                    return format_response(
                        status_code=404, message="Senior citizen not found."
                    )
                senior_citizen_id = senior_citizen_data[0]

                # Check if relation already exists
                cur.execute(
                    "SELECT id FROM relations WHERE family_member_id = %s AND senior_citizen_id = %s",
                    (family_member_user.id, senior_citizen_id),
                )
                if cur.fetchone():
                    return format_response(
                        status_code=409, message="Relation already exists."
                    )

                # Add relation
                cur.execute(
                    """INSERT INTO relations (family_member_id, senior_citizen_id, family_member_relation, senior_citizen_relation)
                       VALUES (%s, %s, %s, %s) RETURNING id""",
                    (
                        family_member_user.id,
                        senior_citizen_id,
                        relation,
                        "family_member",  # Default relation from senior citizen's perspective
                    ),
                )
                relation_id = cur.fetchone()[0]

        return format_response(
            status_code=201,
            message="Senior citizen linked successfully.",
            data={"link_id": relation_id},
        )

    except ValueError as e:
        logger.error(f"Authentication failed: {e}")
        return format_response(
            status_code=401, message="Authentication failed. Invalid token."
        )
    except Exception as e:
        logger.error(f"Error linking senior citizen: {e}")
        return format_response(status_code=500, message="Internal server error.")
