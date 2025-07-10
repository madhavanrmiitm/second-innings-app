from functools import wraps
from typing import Type

from app.logger import logger
from app.utils.response_formatter import format_response
from fastapi import Request
from pydantic import BaseModel, ValidationError


def validate_body(model: Type[BaseModel]):
    def decorator(func):
        @wraps(func)
        async def wrapper(request: Request, *args, **kwargs):
            try:
                body_data = await request.json()
                validated_data = model(**body_data)
                # Pass validated data to the decorated function
                logger.info(f"Validated data: {validated_data}")
                # Call the original function with request and validated_data, ignoring other args
                return await func(request, validated_data)
            except ValidationError as e:
                return format_response(
                    status_code=422, message="Validation Error", data=e.errors()
                )
            except Exception as e:
                logger.error(f"Error validating body: {e}")
                return format_response(
                    status_code=400, message="Invalid JSON body", data=str(e)
                )

        return wrapper

    return decorator
