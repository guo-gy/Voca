from sqlmodel import SQLModel, create_engine
import sys
import os

# Add path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from models import Word, UserProgress, AIStoryCache

sqlite_file_name = "voca.db"
sqlite_url = f"sqlite:///{sqlite_file_name}"

engine = create_engine(sqlite_url)

def init_db():
    print("Creating tables...")
    SQLModel.metadata.create_all(engine)
    print("Tables created.")

if __name__ == "__main__":
    init_db()
