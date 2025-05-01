from fastapi import APIRouter

from .polls import router as polls_router
from .user import router as user_router

router = APIRouter()
router.include_router(polls_router, prefix="/polls")
router.include_router(user_router, prefix='/users')
