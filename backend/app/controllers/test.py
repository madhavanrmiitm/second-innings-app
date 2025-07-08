from app.logger import logger
from app.modules.test import test as test_module
from app.payloads import Item
from app.utils.response_formatter import format_response


def get_test_data():
    """
    Controller logic to retrieve a test message.
    It calls the business logic module and formats the response.
    """
    logger.info("Executing test controller logic.")
    data = test_module.get_test_message()
    return format_response(
        status_code=200, message="Test data retrieved successfully.", data=data
    )


async def create_item(request, validated_data: Item):
    """
    Controller logic to create a new item.
    It calls the business logic module to add the item to the database.
    """
    logger.info("Executing create item controller logic.")
    try:
        new_item = test_module.add_item_to_db(validated_data)
        return format_response(
            status_code=201, message="Item created successfully.", data=new_item
        )
    except Exception as e:
        logger.error(f"Error creating item: {e}")
        return format_response(status_code=500, message="Failed to create item.")
