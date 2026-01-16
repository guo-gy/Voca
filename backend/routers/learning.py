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
    level: str = "ALL",
    count: int = 10,
    db: Session = Depends(get_db)
):
    """
    获取学习会话 - Get a learning session with words to study
    
    Returns `count` random words where the user's mastery_count < 3
    """
    # Get all words (ignore level filter for now to ensure 10 words)
    if level == "ALL":
        words_stmt = select(Word)
    else:
        words_stmt = select(Word).where(Word.level == level)
    all_words = db.exec(words_stmt).all()
    
    print(f"[Session API] Total words in DB: {len(all_words)}")
    
    if not all_words:
        raise HTTPException(status_code=404, detail=f"No words found")
    
    # For testing: ignore mastery status, always return fresh words
    # Select random words
    selected = random.sample(all_words, min(count, len(all_words)))
    
    print(f"[Session API] Selected {len(selected)} words: {[w.text for w in selected]}")
    
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
    
    Uses OpenAI-compatible API to generate contextual stories with translation
    """
    print(f"[Story API] Received word_ids: {request.word_ids}")
    print(f"[Story API] Theme: {request.theme}")
    
    # Fetch words from database
    words_stmt = select(Word).where(Word.id.in_(request.word_ids))
    words = db.exec(words_stmt).all()
    
    print(f"[Story API] Found {len(words)} words in DB: {[w.text for w in words]}")
    
    if not words:
        raise HTTPException(status_code=404, detail="No words found for the given IDs")
    
    # Build word data with definitions
    word_data = [{"text": w.text, "definition": w.definition} for w in words]
    
    # Build word definitions dict for frontend
    word_definitions = {w.text: w.definition for w in words}
    
    print(f"[Story API] Sending to AI: {len(word_data)} words")
    
    # Import the new function
    from services.ai_service import generate_story_with_translation
    
    # Generate story + translation
    result = await generate_story_with_translation(word_data, request.theme)
    
    print(f"[Story API] Generated story length: {len(result['content'])}")
    print(f"[Story API] Translation length: {len(result['translation'])}")
    
    return StoryResponse(
        content=result["content"],
        translation=result["translation"],
        keywords=[w.text for w in words],
        word_definitions=word_definitions,
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


@router.get("/translate/{word}")
async def translate_word(
    word: str,
    db: Session = Depends(get_db)
):
    """
    翻译单词 - Translate a single word
    
    First checks database, if not found uses AI to translate and adds to DB
    """
    # Normalize the word
    word_lower = word.lower().strip()
    print(f"[Translate API] Looking up: {word_lower}")
    
    # Check if word exists in database
    stmt = select(Word).where(Word.text == word_lower)
    existing = db.exec(stmt).first()
    
    if existing:
        print(f"[Translate API] Found in DB: {existing.definition}")
        return {
            "word": existing.text,
            "definition": existing.definition,
            "source": "database"
        }
    
    # Not in DB - use AI to translate
    print(f"[Translate API] Not in DB, calling AI...")
    
    try:
        from openai import OpenAI
        import os
        
        client = OpenAI(
            api_key=os.getenv("OPENAI_API_KEY"),
            base_url=os.getenv("OPENAI_BASE_URL", "https://api.openai.com/v1")
        )
        
        response = client.chat.completions.create(
            model=os.getenv("OPENAI_MODEL", "deepseek-chat"),
            messages=[
                {"role": "system", "content": "你是一个简洁的英语词典。只输出中文释义，不要任何其他内容。"},
                {"role": "user", "content": f"请用简短的中文解释这个英语单词的意思：{word_lower}"}
            ],
            temperature=0.3,
            max_tokens=100
        )
        
        definition = response.choices[0].message.content.strip()
        print(f"[Translate API] AI translated: {definition}")
        
        # Add to database
        new_word = Word(
            text=word_lower,
            definition=definition,
            level="AI"  # Mark as AI-generated
        )
        db.add(new_word)
        db.commit()
        db.refresh(new_word)
        
        print(f"[Translate API] Added to DB with id: {new_word.id}")
        
        return {
            "word": word_lower,
            "definition": definition,
            "source": "ai"
        }
        
    except Exception as e:
        print(f"[Translate API] Error: {e}")
        return {
            "word": word_lower,
            "definition": f"翻译失败: {str(e)}",
            "source": "error"
        }
