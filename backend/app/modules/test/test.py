from app.database.db import get_db_connection
from app.logger import logger
from app.payloads import Item


def get_test_message() -> dict:
    """
    Retrieves a static test message.
    """
    logger.info("Executing test module logic.")
    return {"message": "This is a test message from the module."}


def add_item_to_db(item: Item) -> dict:
    """
    Adds a new item to the database.

    Args:
        item: The item to add, based on the Item payload schema.

    Returns:
        A dictionary representing the newly created item from the database.
    """
    logger.info(f"Adding item to database: {item.model_dump()}")
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            cur.execute(
                """INSERT INTO items (name, description, price)
                   VALUES (%s, %s, %s)
                   RETURNING id, name, description, price""",
                (item.name, item.description, item.price),
            )
            inserted_item = cur.fetchone()
            if inserted_item:
                # Convert tuple to dict to match payload structure
                return {
                    "id": inserted_item[0],
                    "name": inserted_item[1],
                    "description": inserted_item[2],
                    "price": float(inserted_item[3]),
                }
    raise Exception("Failed to add item to database")
