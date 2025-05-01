from typing import Any
from typing import Annotated, Generator
from fastapi import Depends
from sqlalchemy.orm import as_declarative, declared_attr
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session

from core.config import settings


@as_declarative()
class BaseMeta:
    id: Any
    __name__: str

    @declared_attr
    def __tablename__(cls) -> str:
        return cls.__name__.lower()


engine = create_engine(settings.db_uri, pool_pre_ping=True)

SessionLocal = sessionmaker(autocommit=False, autoflush=True, bind=engine)

def get_meta_db() -> Generator:
    try:
        db = SessionLocal()
        yield db
    except:
        db.rollback()
        raise
    else:
        db.commit()
    finally:
        db.close()


SessionDep = Annotated[Session, Depends(get_meta_db)]
