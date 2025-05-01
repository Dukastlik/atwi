from sqlalchemy import ForeignKey
from sqlalchemy.orm import relationship, Mapped, mapped_column

from core.db import BaseMeta
from .poll import TPoll



class TUser(BaseMeta):
    __tablename__ = "users"
    user_id: Mapped[int] = mapped_column(primary_key=True)
    user_polls: Mapped[list['TUserPolls']] = relationship("TUserPolls")
    polls: Mapped[list['TPoll']] = relationship(
        "TPoll", secondary='user_polls', viewonly=True
    )


class TUserPolls(BaseMeta):
    __tablename__ = "user_polls"
    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.user_id"), primary_key=True
    )
    poll_id: Mapped[str] = mapped_column(
        ForeignKey("polls.poll_id"), primary_key=True
    )
