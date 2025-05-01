from sqlalchemy import select, delete, update
from fastapi import Depends
from typing import Annotated

from core.db import SessionDep
from models import TBook
from schemas import Poll


class BooksRepository:

    def __init__(self, session: SessionDep) -> None:
        self.session = session
        self.model = TBook

    def clear_poll_books(self, poll_id: int) -> None:
        query = delete(self.model).where(self.model.poll_id == poll_id)
        self.session.execute(query)
        self.session.commit()

    def create_books(self, books: list[dict]) -> None:
        for book in books:
            self.session.add(self.model(**book))

    def update_books_votes(
        self,
        books_orms: list[TBook],
        update_schema: Poll
    ) -> None:
        
        for book in books_orms:
            book_schema = update_schema.book_by_id(book.book_id)
            book.votes += book_schema.votes


BooksRepoDep = Annotated[BooksRepository, Depends()]
