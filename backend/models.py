"""
Voca 语刻 - Database Models
SQLModel schemas for Word, UserProgress, and AIStoryCache
"""

from datetime import datetime
from typing import Optional
from sqlmodel import SQLModel, Field


class Word(SQLModel, table=True):
    """词库表 - Vocabulary word entry"""
    id: Optional[int] = Field(default=None, primary_key=True)
    text: str = Field(index=True, unique=True)  # The word itself
    definition: str  # Primary definition
    level: str = Field(default="GRE", index=True)  # GRE, 考研, TOEFL, etc.
    phonetic: Optional[str] = None  # IPA pronunciation
    options: Optional[str] = None  # JSON string of distractor options


class UserProgress(SQLModel, table=True):
    """进度表 - User's learning progress for each word"""
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: str = Field(index=True)  # User identifier
    word_id: int = Field(foreign_key="word.id", index=True)
    mastery_count: int = Field(default=0)  # 0, 1, 2, or 3
    last_reviewed: Optional[datetime] = None
    is_mastered: bool = Field(default=False)  # True when mastery_count >= 3


class AIStoryCache(SQLModel, table=True):
    """故事缓存表 - Cached AI-generated stories"""
    id: Optional[int] = Field(default=None, primary_key=True)
    word_ids_hash: str = Field(index=True, unique=True)  # Hash of word IDs
    content: str  # The generated story
    theme: Optional[str] = None  # Theme used (e.g., "量化投资")
    created_at: datetime = Field(default_factory=datetime.utcnow)


# --- Pydantic Schemas for API ---

class WordResponse(SQLModel):
    """API response for a word"""
    id: int
    text: str
    definition: str
    phonetic: Optional[str] = None
    options: list[str] = []  # Parsed from JSON


class ProgressUpdate(SQLModel):
    """Request body for updating progress"""
    user_id: str
    word_id: int
    correct: bool


class ProgressResponse(SQLModel):
    """API response after progress update"""
    word_id: int
    mastery_count: int
    is_mastered: bool


class StoryRequest(SQLModel):
    """Request body for AI story generation"""
    word_ids: list[int]
    theme: Optional[str] = "量化投资"  # Default theme


class StoryResponse(SQLModel):
    """API response with generated story"""
    content: str
    keywords: list[str]
    theme: str
