from fastapi import Depends, FastAPI
from starlette.middleware.cors import CORSMiddleware

from api.router import router
from core.auth import user_validator


app = FastAPI(dependencies=[Depends(user_validator)])


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router)
