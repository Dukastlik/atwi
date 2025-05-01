from pydantic import BaseModel, ConfigDict

from .book import Book


class Poll(BaseModel):
    poll_id: int
    initial_votes_count: int = 0
    books: list[Book]

    model_config = ConfigDict(from_attributes=True)

    def book_by_id(self, book_id: int) -> Book | None:
        for book in self.books:
            if book.book_id == book_id:
                return book
