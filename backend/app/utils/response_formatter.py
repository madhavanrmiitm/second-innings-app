import json
from datetime import date, datetime
from typing import Any, Optional

from fastapi.responses import JSONResponse


class CustomJSONEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, (date, datetime)):
            return obj.isoformat()
        return super().default(obj)


def format_response(
    status_code: int,
    message: str,
    data: Optional[Any] = None,
) -> JSONResponse:
    """
    Standardizes JSON responses with proper date/datetime serialization.
    """
    response_content = {
        "message": message,
        "data": data,
    }

    # Use custom encoder to handle date/datetime objects
    json_content = json.dumps(
        response_content, cls=CustomJSONEncoder, ensure_ascii=False
    )

    return JSONResponse(
        status_code=status_code,
        content=json.loads(json_content),
        media_type="application/json",
    )
