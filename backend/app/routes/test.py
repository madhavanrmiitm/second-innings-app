from app.controllers import test as test_controller
from app.payloads import Item
from app.utils.request_validator import validate_body
from fastapi import APIRouter, Request
from fastapi.responses import JSONResponse

router = APIRouter()


@router.get("/test", response_class=JSONResponse)
def read_test():
    return test_controller.get_test_data()


@router.post("/items", response_class=JSONResponse)
@validate_body(Item)
async def create_item(request: Request, validated_data: Item):
    return await test_controller.create_item(request, validated_data)
