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


async def generate_story_with_translation(words: list[dict], theme: str = "量化投资") -> dict:
    """
    Generate an engaging story using the given words, along with full translation
    
    Args:
        words: List of word dicts with 'text' and 'definition' keys
        theme: Theme for the story (e.g., "量化投资", "科技创业")
    
    Returns:
        Dict with 'content' (English story) and 'translation' (Chinese translation)
    """
    # Build word list with definitions
    word_texts = [w['text'] for w in words]
    word_list = "\n".join([
        f"{i+1}. **{w['text']}** - {w['definition']}" 
        for i, w in enumerate(words)
    ])
    
    word_count = len(words)
    words_joined = ", ".join([f"**{w}**" for w in word_texts])
    
    prompt = f"""你是一位专业的英语教育内容创作者。你的任务是：
1. 创作一段英语短文，必须包含我给你的所有 {word_count} 个英语单词
2. 提供该短文的中文翻译

## 必须包含的 {word_count} 个单词（全部都要用到！）：
{word_list}

## 主题：{theme}

## 严格要求：
1. 【最重要】故事必须包含以上列出的全部 {word_count} 个单词，一个都不能少！
2. 每个目标单词必须用 **粗体** 标记，格式为 **单词**
3. 单词必须在语境中自然使用，不要生硬堆砌
4. 故事长度约 150-200 字（英文）
5. 故事要有趣，有完整的情节

## 输出格式（严格遵守，用 --- 分隔）：
[ENGLISH]
（这里输出英文故事，目标单词用**粗体**标记）

---

[CHINESE]
（这里输出对应的中文翻译，目标单词用**粗体**标记并括号注明英文原词）"""

    print(f"[AI Service] Generating story with {word_count} words: {word_texts}")
    
    try:
        response = client.chat.completions.create(
            model=os.getenv("OPENAI_MODEL", "deepseek-chat"),
            messages=[
                {
                    "role": "system", 
                    "content": f"You are a vocabulary learning content creator. You MUST use ALL {word_count} words provided. Output in the exact format requested with [ENGLISH] and [CHINESE] sections separated by ---."
                },
                {"role": "user", "content": prompt}
            ],
            temperature=0.7,
            max_tokens=1200
        )
        content = response.choices[0].message.content
        print(f"[AI Service] Response received, length: {len(content)}")
        
        # Parse the response to extract English and Chinese parts
        english_story = content
        chinese_translation = ""
        
        if "---" in content:
            parts = content.split("---")
            if len(parts) >= 2:
                english_part = parts[0]
                chinese_part = parts[1]
                
                # Clean up markers
                english_story = english_part.replace("[ENGLISH]", "").strip()
                chinese_translation = chinese_part.replace("[CHINESE]", "").strip()
        
        print(f"[AI Service] English story length: {len(english_story)}")
        print(f"[AI Service] Chinese translation length: {len(chinese_translation)}")
        
        return {
            "content": english_story,
            "translation": chinese_translation
        }
        
    except Exception as e:
        print(f"[AI Service] Error: {e}")
        # Fallback
        fallback_parts = []
        for w in words:
            fallback_parts.append(f"**{w['text']}** ({w['definition']})")
        
        fallback_en = f"This story uses {word_count} vocabulary words: " + ", ".join([f"**{w['text']}**" for w in words]) + "."
        fallback_cn = f"本故事使用了 {word_count} 个词汇：" + "、".join([f"**{w['text']}**（{w['definition']}）" for w in words])
        fallback_cn += f"\n\n[AI story generation failed: {str(e)}]"
        
        return {
            "content": fallback_en,
            "translation": fallback_cn
        }


# Keep old function for compatibility
async def generate_story(words: list[dict], theme: str = "量化投资") -> str:
    """Backward compatible function"""
    result = await generate_story_with_translation(words, theme)
    return result["content"]
