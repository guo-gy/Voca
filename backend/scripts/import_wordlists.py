"""
Script to download and import wordlists from mahavivo/english-wordlists
"""
import os
import sys
import re
import requests
from sqlmodel import Session, select, create_engine, SQLModel

# Add backend directory to path to import models
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from models import Word
from database import engine

WORDLIST_URLS = {
    # Standard format: word [phonetic] definition
    "CET4": "https://raw.githubusercontent.com/mahavivo/english-wordlists/master/CET4_edited.txt",
    "CET6": "https://raw.githubusercontent.com/mahavivo/english-wordlists/master/CET6_edited.txt",
    "TOEFL": "https://raw.githubusercontent.com/mahavivo/english-wordlists/master/TOEFL.txt",
    "GRE": "https://raw.githubusercontent.com/mahavivo/english-wordlists/master/GRE_8000_Words.txt",
    
    # Simple format: word\tn. definition
    "Gaokao": "https://github.com/KyleBing/english-vocabulary/raw/refs/heads/master/2%20%E9%AB%98%E4%B8%AD-%E4%B9%B1%E5%BA%8F.txt",
    "Kaoyan": "https://github.com/KyleBing/english-vocabulary/raw/refs/heads/master/5%20%E8%80%83%E7%A0%94-%E4%B9%B1%E5%BA%8F.txt"
}

def parse_line(line, source_type="mahavivo"):
    """
    Parse a line based on source type.
    
    Args:
        line: The text line to parse
        source_type: "mahavivo" (word [phonetic] def) or "kylebing" (word\tdef)
        
    Returns (word, phonetic, definition)
    """
    line = line.strip()
    if not line or len(line) < 2:
        return None
        
    # Skip headers/single letters
    if len(line) == 1 and line.isalpha():
        return None
        
    if source_type == "kylebing":
        # KyleBing format: word<tab>definition
        parts = line.split('\t')
        if len(parts) >= 2:
            word = parts[0].strip()
            # KyleBing defs often have multiple parts split by spaces or just raw text
            definition = parts[1].strip()
            return word, None, definition
        return None
        
    else: # mahavivo
        # Regex for standard format
        # Matches: word [phonetic] definition
        # or: word definition (no phonetic)
        match = re.match(r'^([a-zA-Z\-\'.]+)\s+(?:\[(.*?)\]\s+)?(.*)$', line)
        
        if match:
            word = match.group(1)
            phonetic = match.group(2)
            definition = match.group(3)
            return word, phonetic, definition
    
    return None

def import_wordlist(level, url, session):
    print(f"Downloading {level} from {url}...")
    try:
        response = requests.get(url)
        response.raise_for_status()
        content = response.text
    except Exception as e:
        print(f"Failed to download {level}: {e}")
        return

    print(f"Parsing {level}...")
    
    source_type = "kylebing" if level in ["Gaokao", "Kaoyan"] else "mahavivo"
    
    count = 0
    added = 0
    updated = 0
    
    lines = content.split('\n')
    for line in lines:
        parsed = parse_line(line, source_type)
        if not parsed:
            continue
            
        word_text, phonetic, definition = parsed
        # Clean word
        word_lower = word_text.lower().strip()
        
        # Check if exists
        stmt = select(Word).where(Word.text == word_lower)
        existing = session.exec(stmt).first()
        
        if existing:
            # Update level if not present
            levels = existing.level.split(',') if existing.level else []
            if level not in levels:
                levels.append(level)
                existing.level = ",".join(levels)
                
            # Update phonetic if missing
            if not existing.phonetic and phonetic:
                existing.phonetic = phonetic
                
            # Merge definition if new one is different enough and useful
            if definition and existing.definition != definition:
                # Avoid duplicates if checking simple containment
                if definition not in existing.definition:
                    # If existing definition is very short or different, append
                    existing.definition = f"{existing.definition} | {definition}"
            
            session.add(existing)
            updated += 1
        else:
            # Create new
            new_word = Word(
                text=word_lower,
                definition=definition or "No definition",
                phonetic=phonetic,
                level=level
            )
            session.add(new_word)
            added += 1
            
        count += 1
        if count % 1000 == 0:
            print(f"Processed {count} words...")
            session.commit()
            
    session.commit()
    print(f"Finished {level}: Added {added}, Updated {updated}, Total processed {count}")

def main():
    with Session(engine) as session:
        for level, url in WORDLIST_URLS.items():
            import_wordlist(level, url, session)

if __name__ == "__main__":
    main()
