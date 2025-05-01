from sqlalchemy import select, desc
from fastapi import Depends
from typing import Annotated

from core.db import SessionDep
from models.user import TUser, TUserPolls


class UsersRepository:

    def __init__(self, session: SessionDep) -> None:
        self.session = session
        self.model = TUser

    def get_user(self, user_id: int) -> TUser | None:
        return self.session.get(self.model, user_id)

    def add_user(self, user_id: int) -> TUser:
        user_orm = self.model(user_id=user_id)
        self.session.add(user_orm)
        self.session.flush()

    def get_user_poll_asociation(
        self, user_id: int, poll_id: str
    )-> TUserPolls | None:
        return self.session.get(TUserPolls, (user_id, poll_id))

    def set_user_poll_asociation(
        self, user_id: int, poll_id: str
    ) -> TUserPolls | None:
        if self.get_user(user_id) is None:
            self.add_user(user_id)
        association = TUserPolls(user_id=user_id, poll_id=poll_id)
        self.session.add(association)
        self.session.flush()


UsersRepoDep = Annotated[UsersRepository, Depends()]
