"""
Voca 语刻 - Learning Router
API endpoints for vocabulary learning sessions
"""

import random
from datetime import datetime
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select

from database import get_db
from models import (
    Word, UserProgress, AIStoryCache,
    WordResponse, ProgressUpdate, ProgressResponse,
    StoryRequest, StoryResponse
)
from services.ai_service import generate_story, generate_word_hash

router = APIRouter(prefix="/api", tags=["learning"])


@router.get("/session", response_model=list[WordResponse])
async def get_learning_session(
    user_id: str,
    level: str = "GRE",
    count: int = 10,
    db: Session = Depends(get_db)
):
    """
    获取学习会话 - Get a learning session with words to study
    
    Returns `count` random words where the user's mastery_count < 3
    """
    # Get all words at the specified level
    words_stmt = select(Word).where(Word.level == level)
    all_words = db.exec(words_stmt).all()
    
    if not all_words:
        raise HTTPException(status_code=404, detail=f"No words found for level: {level}")
    
    # Get user's progress
    progress_stmt = select(UserProgress).where(
        UserProgress.user_id == user_id,
        UserProgress.is_mastered == True
    )
    mastered = {p.word_id for p in db.exec(progress_stmt).all()}
    
    # Filter to unmastered words
    available_words = [w for w in all_words if w.id not in mastered]
    
    if not available_words:
        # All words mastered - return random words for review
        available_words = all_words
    
    # Select random words
    selected = random.sample(available_words, min(count, len(available_words)))
    
    # Build response with options
    result = []
    for word in selected:
        # Get 3 random distractor definitions
        other_words = [w for w in all_words if w.id != word.id]
        distractors = random.sample(other_words, min(3, len(other_words)))
        
        options = [word.definition] + [d.definition for d in distractors]
        random.shuffle(options)
        
        result.append(WordResponse(
            id=word.id,
            text=word.text,
            definition=word.definition,
            phonetic=word.phonetic,
            options=options
        ))
    
    return result


@router.post("/progress", response_model=ProgressResponse)
async def update_progress(
    update: ProgressUpdate,
    db: Session = Depends(get_db)
):
    """
    更新进度 - Update learning progress for a word
    
    Increments mastery_count if correct, marks as mastered at 3
    """
    # Find or create progress record
    stmt = select(UserProgress).where(
        UserProgress.user_id == update.user_id,
        UserProgress.word_id == update.word_id
    )
    progress = db.exec(stmt).first()
    
    if not progress:
        progress = UserProgress(
            user_id=update.user_id,
            word_id=update.word_id,
            mastery_count=0
        )
        db.add(progress)
    
    # Update if correct
    if update.correct:
        progress.mastery_count = min(progress.mastery_count + 1, 3)
        if progress.mastery_count >= 3:
            progress.is_mastered = True
    
    progress.last_reviewed = datetime.utcnow()
    db.commit()
    db.refresh(progress)
    
    return ProgressResponse(
        word_id=progress.word_id,
        mastery_count=progress.mastery_count,
        is_mastered=progress.is_mastered
    )


@router.post("/story", response_model=StoryResponse)
async def generate_ai_story(
    request: StoryRequest,
    db: Session = Depends(get_db)
):
    """
    生成AI故事 - Generate an AI-powered story using the given words
    
    Uses OpenAI-compatible API to generate contextual stories
    """
    # Check cache first
    cache_hash = generate_word_hash(request.word_ids)
    cache_stmt = select(AIStoryCache).where(
        AIStoryCache.word_ids_hash == cache_hash,
        AIStoryCache.theme == request.theme
    )
    cached = db.exec(cache_stmt).first()
    
    if cached:
        # Return cached story
        words_stmt = select(Word).where(Word.id.in_(request.word_ids))
        words = db.exec(words_stmt).all()
        return StoryResponse(
            content=cached.content,
            keywords=[w.text for w in words],
            theme=cached.theme or request.theme
        )
    
    # Fetch words
    words_stmt = select(Word).where(Word.id.in_(request.word_ids))
    words = db.exec(words_stmt).all()
    
    if not words:
        raise HTTPException(status_code=404, detail="No words found")
    
    # Generate story
    word_data = [{"text": w.text, "definition": w.definition} for w in words]
    story_content = await generate_story(word_data, request.theme)
    
    # Cache the result
    cache_entry = AIStoryCache(
        word_ids_hash=cache_hash,
        content=story_content,
        theme=request.theme
    )
    db.add(cache_entry)
    db.commit()
    
    return StoryResponse(
        content=story_content,
        keywords=[w.text for w in words],
        theme=request.theme
    )


@router.get("/progress/{user_id}")
async def get_user_progress(
    user_id: str,
    db: Session = Depends(get_db)
):
    """获取用户进度统计 - Get user's overall learning progress"""
    # Total words
    total_stmt = select(Word)
    total_words = len(db.exec(total_stmt).all())
    
    # Mastered words
    mastered_stmt = select(UserProgress).where(
        UserProgress.user_id == user_id,
        UserProgress.is_mastered == True
    )
    mastered_count = len(db.exec(mastered_stmt).all())
    
    # In progress (1-2 mastery)
    progress_stmt = select(UserProgress).where(
        UserProgress.user_id == user_id,
        UserProgress.is_mastered == False,
        UserProgress.mastery_count > 0
    )
    in_progress = len(db.exec(progress_stmt).all())
    
    return {
        "total_words": total_words,
        "mastered": mastered_count,
        "in_progress": in_progress,
        "new": total_words - mastered_count - in_progress
    }
