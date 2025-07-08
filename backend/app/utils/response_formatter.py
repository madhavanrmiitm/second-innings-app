from typing import Any, Optional

from fastapi.responses import JSONResponse


def format_response(
    status_code: int,
    message: str,
    data: Optional[Any] = None,
) -> JSONResponse:
    """
    Standardizes JSON responses.
    """
    response_content = {
        "message": message,
        "data": data,
    }
    return JSONResponse(status_code=status_code, content=response_content)
