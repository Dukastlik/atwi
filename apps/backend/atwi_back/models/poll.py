from sqlalchemy import Identity, Integer
from sqlalchemy.orm import relationship, Mapped, mapped_column

from core.db import BaseMeta
from .book import TBook


class TPoll(BaseMeta):
    __tablename__ = "polls"

    poll_id: Mapped[int] = mapped_column(Integer, Identity(), primary_key=True)
    initial_votes_count: Mapped[str]
    books: Mapped[list['TBook']] = relationship(
        "TBook",
        uselist=True,
        lazy=False,
        cascade="all, delete",
    )
