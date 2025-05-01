from pydantic import BaseModel, ConfigDict



class Book(BaseModel):
    poll_id: int
    book_id: int
    book_name: str
    book_author: str
    book_accountable: str | None = None
    book_cover_link: str | None = None
    votes: int

    model_config = ConfigDict(from_attributes=True)