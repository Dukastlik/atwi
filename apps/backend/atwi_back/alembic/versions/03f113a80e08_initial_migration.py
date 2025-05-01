"""Initial migration

Revision ID: 03f113a80e08
Revises: 
Create Date: 2025-05-01 18:39:41.760079

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '03f113a80e08'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        'polls',
        sa.Column('poll_id', sa.Integer(), sa.Identity(always=False), nullable=False),
        sa.Column('initial_votes_count', sa.String(), nullable=False),
        sa.PrimaryKeyConstraint('poll_id')
    )
    op.create_table(
        'users',
        sa.Column('user_id', sa.Integer(), nullable=False),
        sa.PrimaryKeyConstraint('user_id')
    )
    op.create_table(
        'books',
        sa.Column('poll_id', sa.Integer(), nullable=False),
        sa.Column('book_id', sa.Integer(), sa.Identity(always=False), nullable=False),
        sa.Column('book_name', sa.String(), nullable=False),
        sa.Column('book_author', sa.String(), nullable=False),
        sa.Column('book_accountable', sa.String(), nullable=True),
        sa.Column('book_cover_link', sa.String(), nullable=True),
        sa.Column('votes', sa.Integer(), nullable=False),
        sa.ForeignKeyConstraint(['poll_id'], ['polls.poll_id'], ),
        sa.PrimaryKeyConstraint('poll_id', 'book_id')
    )
    op.create_table(
        'user_polls',
        sa.Column('user_id', sa.Integer(), nullable=False),
        sa.Column('poll_id', sa.Integer(), nullable=False),
        sa.ForeignKeyConstraint(['poll_id'], ['polls.poll_id'], ),
        sa.ForeignKeyConstraint(['user_id'], ['users.user_id'], ),
        sa.PrimaryKeyConstraint('user_id', 'poll_id')
    )
    # POPULATE TABLES WITH DATA
    op.execute(
        sa.text(
            '''
        INSERT INTO polls
        (poll_id, initial_votes_count)
        VALUES(2, 10);
            '''
        )
    )
    op.execute(
        sa.text(
            '''
        INSERT INTO books
        (poll_id, book_id, book_name, book_author, book_accountable, book_cover_link, votes)
        VALUES(2, 6, 'Fallen leaves', 'Rozanov', 'Timur', 
        'https://upload.wikimedia.org/wikipedia/commons/b/b3/Vasily_Rosanov_by_Ivan_Parkhomenko_1909.jpg', 8);
        INSERT INTO books
        (poll_id, book_id, book_name, book_author, book_accountable, book_cover_link, votes)
        VALUES(2, 3, 'Voskresenie', 'Tolstoy ', 'Dima', 
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c6/L.N.Tolstoy_Prokudin-Gorsky.jpg/500px-L.N.Tolstoy_Prokudin-Gorsky.jpg', 6);
        INSERT INTO books
        (poll_id, book_id, book_name, book_author, book_accountable, book_cover_link, votes)
        VALUES(2, 4, 'Kritika #3', 'I. Kant', 'Mitya', 
        'https://upload.wikimedia.org/wikipedia/commons/thumb/4/43/Immanuel_Kant_%28painted_portrait%29.jpg/250px-Immanuel_Kant_%28painted_portrait%29.jpg', 5);
            '''
        )
    )


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_table('user_polls')
    op.drop_table('books')
    op.drop_table('users')
    op.drop_table('polls')
