from sqlalchemy import select, desc
from fastapi import Depends
from typing import Annotated

from core.db import SessionDep
from models import TPoll, TBook
from schemas import Poll


class PollsRepository:

    def __init__(self, session: SessionDep) -> None:
        self.session = session
        self.model = TPoll

    def get_poll(self, poll_id: int) -> TPoll | None:
        query = select(self.model).where(self.model.poll_id == poll_id)
        return self.session.scalars(query).first()

    def get_latest_poll(self) -> TPoll | None:
        query = select(self.model).order_by(desc(self.model.poll_id)).limit(1)
        return self.session.scalars(query).first()
        

PollsRepoDep = Annotated[PollsRepository, Depends()]
