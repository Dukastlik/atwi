from fastapi import Depends, status
from fastapi.exceptions import HTTPException
from typing import Annotated

from schemas import Poll
from core.auth import UserIdDep
from repositories import PollsRepoDep, BooksRepoDep, UsersRepoDep



class PollsService():

    def __init__(
        self,
        polls_repository: PollsRepoDep,
        books_repository: BooksRepoDep,
        users_repository: UsersRepoDep,
        user: UserIdDep
    ) -> None:
        self.polls_repository = polls_repository
        self.books_repository = books_repository
        self.users_repository = users_repository
        self.user = user

    def get_latest_poll(self) -> Poll:
        poll = self.polls_repository.get_latest_poll()
        poll_schema =  Poll.model_validate(poll)
        if not self.already_voted(poll_schema.poll_id):
            for book in poll_schema.books:
                book.votes = 0
        else:
            poll_schema.initial_votes_count = 0
        return poll_schema

    def update_poll(self, update_schema: Poll) -> Poll:
        if self.already_voted(update_schema.poll_id):
            raise HTTPException(
                status_code=status.HTTP_412_PRECONDITION_FAILED,
                detail="You've already voted here"
            )
        poll = self.polls_repository.get_poll(update_schema.poll_id)
        if not poll:
            raise HTTPException(
                status_code=status.HTTP_412_PRECONDITION_FAILED,
                detail="Poll does not exists"
            )
        for book in poll.books:
            if update_schema.book_by_id(book.book_id) is None:
                raise HTTPException(
                status_code=status.HTTP_412_PRECONDITION_FAILED,
                detail="Not all books presented"
            )
        self.books_repository.update_books_votes(
            books_orms=poll.books, 
            update_schema=update_schema
        )
        self.users_repository.set_user_poll_asociation(self.user, update_schema.poll_id)
        return self.get_latest_poll()

    def user_info_for_latest_poll(self) -> dict:
        latest_poll = self.get_latest_poll()
        return {
            "already_voted": self.already_voted(latest_poll.poll_id),
            "initial_count_count": latest_poll.initial_votes_count
        }

    def already_voted(self, poll_id: str) -> bool:
        return self.users_repository.get_user_poll_asociation(self.user, poll_id) is not None



PollsServiceDep = Annotated[PollsService, Depends()]