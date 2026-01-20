"""
Script to download and import skywind3000/ECDICT data.
ECDICT provides rich definitions, phonetics, and tags.
"""
import os
import sys
import csv
import requests
import io
import zipfile
from sqlmodel import Session, select
from sqlalchemy import or_

# Add backend directory to path to import models
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from models import Word
from database import engine

# Using the mini version for faster download, but it still has 77k+ words
# Full version is too large for GitHub direct download reliably without git lfs
ECDICT_URL = "https://raw.githubusercontent.com/skywind3000/ECDICT/master/ecdict.mini.csv"

# Map ECDICT tags to our levels
TAG_MAP = {
    "zk": "Zhongkao",
    "gk": "Gaokao",
    "cet4": "CET4",
    "cet6": "CET6",
    "toefl": "TOEFL",
    "gre": "GRE",
    "ky": "Kaoyan"
}

def download_ecdict():
    print(f"Downloading ECDICT (Mini) from {ECDICT_URL}...")
    try:
        response = requests.get(ECDICT_URL)
        response.raise_for_status()
        return response.text
    except Exception as e:
        print(f"Failed to download ECDICT: {e}")
        return None

def parse_and_import(csv_content):
    print("Parsing ECDICT CSV...")
    
    # Use csv module to handle quoting and commas correctly
    f = io.StringIO(csv_content)
    reader = csv.DictReader(f)
    
    count = 0
    added = 0
    updated = 0
    
    with Session(engine) as session:
        for row in reader:
            word_text = row.get('word')
            if not word_text:
                continue
                
            # Filter non-English words if necessary (basic check)
            if not word_text[0].isalpha():
                continue

            word_lower = word_text.lower().strip()
            
            # Map tags to levels
            raw_tags = row.get('tag', '')
            levels = []
            for tag in raw_tags.split(' '):
                if tag in TAG_MAP:
                    levels.append(TAG_MAP[tag])
            
            # Keep if it has exam tags OR is Oxford/Collins OR has basic tags
            collins = row.get('collins', '0')
            oxford = row.get('oxford', '0')
            is_common = (collins and collins != '0') or (oxford and oxford != '0')
            
            # Skip if no relevant levels and not a common word (collins/oxford)
            # Debug why we are skipping
            if count < 10: 
                 print(f"Row: {word_lower}, Tags: {raw_tags}, Levels: {levels}, IsCommon: {is_common}")

            if not levels and not is_common:
                 continue
            
            level_str = ",".join(levels) if levels else "General"
            
            # Debug first few hits
            if added == 0 and updated == 0:
                print(f"Found first match: {word_lower} (Levels: {level_str})")
            
            # Formatting definition
            # ECDICT format: "n. definition\nv. definition" (newlines)
            definition_raw = row.get('translation', '').replace('\\n', '\n')
            if not definition_raw:
                definition_raw = row.get('definition', '').replace('\\n', '\n')
            
            # Construct definitions JSON
            definitions_json = []
            for line in definition_raw.split('\n'):
                parts = line.split('. ', 1)
                if len(parts) == 2:
                    pos = parts[0] + '.'
                    meaning = parts[1]
                else:
                    pos = 'unk.'
                    meaning = line
                
                definitions_json.append({
                    "pos": pos,
                    "meaning": meaning,
                    "tags": level_str
                })

            # Check if exists
            stmt = select(Word).where(Word.text == word_lower)
            existing = session.exec(stmt).first()
            
            # Safe casting
            try:
                collins_val = int(collins) if collins and collins.isdigit() else 0
                oxford_val = int(oxford) if oxford and oxford.isdigit() else 0
            except ValueError:
                collins_val = 0
                oxford_val = 0

            if existing:
                # Update with richer data
                existing.phonetic = row.get('phonetic')
                existing.phonetic_uk = row.get('bre') if row.get('bre') else row.get('phonetic')
                existing.phonetic_us = row.get('ape') if row.get('ape') else row.get('phonetic')
                existing.collins = collins_val
                existing.oxford = oxford_val
                existing.tag = raw_tags
                existing.exchange = row.get('exchange')
                existing.definition_json = definitions_json
                
                # Merge levels
                existing_levels = existing.level.split(',') if existing.level else []
                new_levels = set(existing_levels + levels)
                existing.level = ",".join(new_levels)
                
                session.add(existing)
                updated += 1
            else:
                new_word = Word(
                    text=word_lower,
                    definition=definition_raw,  # Fallback string
                    definition_json=definitions_json,
                    phonetic=row.get('phonetic'),
                    phonetic_uk=row.get('bre') if row.get('bre') else row.get('phonetic'),
                    phonetic_us=row.get('ape') if row.get('ape') else row.get('phonetic'),
                    level=level_str,
                    collins=collins_val,
                    oxford=oxford_val,
                    tag=raw_tags,
                    exchange=row.get('exchange')
                )
                session.add(new_word)
                added += 1
            
            count += 1
            if count % 1000 == 0:
                print(f"Processed {count} words...")
                session.commit()
                
        session.commit()
    
    print(f"Finished ECDICT Import: Added {added}, Updated {updated}, Total Scan {count}")

if __name__ == "__main__":
    csv_content = download_ecdict()
    if csv_content:
        parse_and_import(csv_content)
