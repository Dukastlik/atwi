from fastapi import APIRouter

from services import PollsServiceDep


router = APIRouter()


@router.get("/latest")
def get_user_info(
    poll_service: PollsServiceDep,
) -> dict:
    return poll_service.user_info_for_latest_poll()
