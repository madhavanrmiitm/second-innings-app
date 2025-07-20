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
                # Call the original function with request, path parameters, and validated_data
                # Add validated_data to kwargs to pass it as a keyword argument
                kwargs["validated_data"] = validated_data
                return await func(request, *args, **kwargs)
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
