"""
Voca 语刻 - Seed Data
20 high-frequency GRE/考研 vocabulary words for demo
"""

from database import get_session, create_db_and_tables
from models import Word


SEED_WORDS = [
    # Finance / Quant Theme
    {"text": "arbitrage", "definition": "利用不同市场的价格差异获利", "phonetic": "/ˈɑːrbɪtrɑːʒ/", "level": "GRE"},
    {"text": "volatile", "definition": "易变的；不稳定的", "phonetic": "/ˈvɒlətaɪl/", "level": "GRE"},
    {"text": "leverage", "definition": "杠杆；影响力", "phonetic": "/ˈliːvərɪdʒ/", "level": "GRE"},
    {"text": "derivative", "definition": "衍生品；派生的", "phonetic": "/dɪˈrɪvətɪv/", "level": "GRE"},
    {"text": "portfolio", "definition": "投资组合；作品集", "phonetic": "/pɔːrtˈfəʊliəʊ/", "level": "考研"},
    
    # Academic / Research Theme
    {"text": "latent", "definition": "潜在的；隐藏的", "phonetic": "/ˈleɪtənt/", "level": "GRE"},
    {"text": "empirical", "definition": "经验主义的；实证的", "phonetic": "/ɪmˈpɪrɪkəl/", "level": "GRE"},
    {"text": "paradigm", "definition": "范式；典范", "phonetic": "/ˈpærədaɪm/", "level": "GRE"},
    {"text": "hypothesis", "definition": "假设；假说", "phonetic": "/haɪˈpɒθəsɪs/", "level": "考研"},
    {"text": "synthesis", "definition": "综合；合成", "phonetic": "/ˈsɪnθəsɪs/", "level": "GRE"},
    
    # General Advanced
    {"text": "ubiquitous", "definition": "无处不在的", "phonetic": "/juːˈbɪkwɪtəs/", "level": "GRE"},
    {"text": "ephemeral", "definition": "短暂的；转瞬即逝的", "phonetic": "/ɪˈfemərəl/", "level": "GRE"},
    {"text": "pragmatic", "definition": "务实的；实用主义的", "phonetic": "/præɡˈmætɪk/", "level": "考研"},
    {"text": "ambiguous", "definition": "模糊的；有歧义的", "phonetic": "/æmˈbɪɡjuəs/", "level": "考研"},
    {"text": "coherent", "definition": "连贯的；一致的", "phonetic": "/kəʊˈhɪərənt/", "level": "考研"},
    
    # Tech / AI Theme
    {"text": "algorithm", "definition": "算法", "phonetic": "/ˈælɡərɪðəm/", "level": "考研"},
    {"text": "iteration", "definition": "迭代；重复", "phonetic": "/ˌɪtəˈreɪʃən/", "level": "GRE"},
    {"text": "optimize", "definition": "优化", "phonetic": "/ˈɒptɪmaɪz/", "level": "考研"},
    {"text": "aggregate", "definition": "聚合；总计", "phonetic": "/ˈæɡrɪɡət/", "level": "GRE"},
    {"text": "robust", "definition": "稳健的；强壮的", "phonetic": "/rəʊˈbʌst/", "level": "考研"},
]


def seed_database():
    """Populate database with initial vocabulary"""
    create_db_and_tables()
    
    with get_session() as session:
        for word_data in SEED_WORDS:
            # Check if word already exists
            from sqlmodel import select
            existing = session.exec(
                select(Word).where(Word.text == word_data["text"])
            ).first()
            
            if not existing:
                word = Word(**word_data)
                session.add(word)
                print(f"✓ Added: {word_data['text']}")
            else:
                print(f"○ Skipped (exists): {word_data['text']}")
        
        session.commit()
        print(f"\n🎉 Seeded {len(SEED_WORDS)} words successfully!")


if __name__ == "__main__":
    seed_database()
