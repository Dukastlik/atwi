from fastapi import APIRouter

from services import PollsServiceDep
from schemas import Poll

router = APIRouter()


@router.get("/latest")
def get_latests_poll(
    poll_service: PollsServiceDep,
) -> Poll:
    return poll_service.get_latest_poll()

@router.put("/latest")
def update_latest_poll(
    poll_service: PollsServiceDep,
    update_schema: Poll,
) -> Poll:
    return poll_service.update_poll(update_schema)
