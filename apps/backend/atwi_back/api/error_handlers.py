from fastapi import status
from fastapi.encoders import jsonable_encoder

from starlette.requests import Request
from starlette.responses import JSONResponse


async def any_exc_handler(_: Request, exc: Exception) -> JSONResponse:
    return JSONResponse(
        status_code=status.HTTP_412_PRECONDITION_FAILED,
        content=jsonable_encoder({"detail": str(exc)}),
    )