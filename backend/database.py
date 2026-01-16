"""
Voca 语刻 - Database Configuration
SQLModel async engine setup with SQLite (easily switchable to PostgreSQL)
"""

import os
from sqlmodel import SQLModel, create_engine, Session
from contextlib import contextmanager

# Database URL - SQLite for development, PostgreSQL for production
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./voca.db")

# Create engine
connect_args = {"check_same_thread": False} if "sqlite" in DATABASE_URL else {}
engine = create_engine(DATABASE_URL, echo=False, connect_args=connect_args)


def create_db_and_tables():
    """Create all tables defined in models"""
    SQLModel.metadata.create_all(engine)


@contextmanager
def get_session():
    """Dependency for getting database session"""
    session = Session(engine)
    try:
        yield session
        session.commit()
    except Exception:
        session.rollback()
        raise
    finally:
        session.close()


def get_db():
    """FastAPI dependency for database session"""
    with get_session() as session:
        yield session
