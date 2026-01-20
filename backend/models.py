"""
Voca 语刻 - Database Models
SQLModel schemas for Word, UserProgress, and AIStoryCache
"""

from datetime import datetime
from typing import Optional
from sqlmodel import SQLModel, Field


from sqlalchemy import Column, JSON

class Word(SQLModel, table=True):
    """词库表 - Vocabulary word entry"""
    id: Optional[int] = Field(default=None, primary_key=True)
    text: str = Field(index=True, unique=True)  # The word itself
    definition: str  # Primary definition (simple string for backward compat)
    
    # --- New Rich Fields ---
    phonetic_us: Optional[str] = None  # US IPA
    phonetic_uk: Optional[str] = None  # UK IPA
    phonetic: Optional[str] = None  # Fallback IPA
    
    # Store complex structures as JSON
    # definitions: [{pos: 'n.', meaning: '...', tags: '...'}, ...]
    definition_json: Optional[list] = Field(default=None, sa_column=Column(JSON))
    
    # exam_meta: [{exam: 'CET4', year: 2023, sentence: '...', translation: '...'}]
    exam_meta: Optional[list] = Field(default=None, sa_column=Column(JSON))
    
    # Tags/Source: e.g. "CET4,GRE,Kaoyan"
    level: str = Field(default="GRE", index=True)
    collins: int = Field(default=0)  # Collins stars 0-5
    oxford: int = Field(default=0)   # Oxford 3000 (1=yes)
    tag: Optional[str] = None        # Raw tags from ECDICT
    exchange: Optional[str] = None   # Word forms: p:pl, d:done, etc.
    
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
    phonetic_us: Optional[str] = None
    phonetic_uk: Optional[str] = None
    definition_json: Optional[list] = None
    exam_meta: Optional[list] = None
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
    content: str  # English story
    translation: str = ""  # Chinese translation
    keywords: list[str]  # Studied words
    word_definitions: dict[str, str] = {}  # word -> Chinese definition
    theme: str

