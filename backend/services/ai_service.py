"""
Voca 语刻 - AI Story Generation Service
OpenAI-compatible API wrapper for generating contextual stories
"""

import os
import hashlib
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

# Initialize OpenAI client (compatible with other providers)
client = OpenAI(
    api_key=os.getenv("OPENAI_API_KEY", "your-api-key-here"),
    base_url=os.getenv("OPENAI_BASE_URL", "https://api.openai.com/v1")
)


def generate_word_hash(word_ids: list[int]) -> str:
    """Generate a hash for caching stories"""
    sorted_ids = sorted(word_ids)
    id_string = ",".join(map(str, sorted_ids))
    return hashlib.sha256(id_string.encode()).hexdigest()[:16]


async def generate_story(words: list[dict], theme: str = "量化投资") -> str:
    """
    Generate an engaging story using the given words
    
    Args:
        words: List of word dicts with 'text' and 'definition' keys
        theme: Theme for the story (e.g., "量化投资", "科技创业")
    
    Returns:
        Generated story with keywords marked in **bold**
    """
    word_list = "\n".join([
        f"- {w['text']}: {w['definition']}" 
        for w in words
    ])
    
    prompt = f"""你是一位创意写作大师。请根据以下英语单词，创作一段约 150-200 字的英语短文。

主题：{theme}

必须使用的单词：
{word_list}

要求：
1. 故事必须自然地融入所有单词
2. 将每个目标单词用 **粗体** 标记
3. 内容需要有趣且有教育意义
4. 语言难度适中，适合英语学习者
5. 故事需要有完整的开头、发展和结尾

请直接输出故事，不要任何前缀或解释。"""

    try:
        response = client.chat.completions.create(
            model=os.getenv("OPENAI_MODEL", "gpt-4o-mini"),
            messages=[
                {"role": "system", "content": "You are a creative writing assistant specializing in educational content for vocabulary learning."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.8,
            max_tokens=500
        )
        return response.choices[0].message.content
    except Exception as e:
        # Return a fallback story if API fails
        keywords = [w['text'] for w in words]
        return f"**{keywords[0]}** represents a key concept in {theme}. " \
               f"Understanding terms like **{keywords[1]}** and **{keywords[2]}** " \
               f"is essential for mastering this field. " \
               f"[AI story generation failed: {str(e)}. Please set OPENAI_API_KEY.]"
