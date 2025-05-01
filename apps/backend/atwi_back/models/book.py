from sqlalchemy import Identity, Integer, ForeignKey, event
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.ext.hybrid import hybrid_property

from core.db import BaseMeta


class TBook(BaseMeta):
    __tablename__ = "books"

    poll_id: Mapped[str] = mapped_column(ForeignKey("polls.poll_id"), primary_key=True)
    book_id: Mapped[int] = mapped_column(Integer, Identity(), primary_key=True)
    book_name: Mapped[str]
    book_author: Mapped[str]
    book_accountable: Mapped[str | None] = mapped_column(default=None)
    book_cover_link: Mapped[str | None] = mapped_column(default=None)
    votes: Mapped[int] = mapped_column("votes", default=0)
