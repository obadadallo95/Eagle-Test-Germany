#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
German Citizenship Test - Question Translator Script
Translates questions from German (de) to English, Turkish, Ukrainian, and Russian.
Uses deep_translator library with Google Translator.
"""

import json
import os
import shutil
from pathlib import Path
from deep_translator import GoogleTranslator
from typing import Dict, List, Any

# Configuration
SOURCE_LANGUAGE = 'de'
TARGET_LANGUAGES = ['en', 'tr', 'uk', 'ru']
QUESTIONS_FILE = 'assets/data/questions.json'
BACKUP_FILE = 'assets/data/questions_backup.json'

def create_backup(source_path: str, backup_path: str) -> None:
    """Create a backup of the original file before modification."""
    if os.path.exists(source_path):
        shutil.copy2(source_path, backup_path)
        print(f"[OK] Backup created: {backup_path}")
    else:
        print(f"[WARNING] Source file not found: {source_path}")

def load_questions(file_path: str) -> List[Dict[str, Any]]:
    """Load questions from JSON file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        print(f"[OK] Loaded {len(data)} questions from {file_path}")
        return data
    except FileNotFoundError:
        print(f"[ERROR] File not found: {file_path}")
        raise
    except json.JSONDecodeError as e:
        print(f"[ERROR] Invalid JSON in {file_path}: {e}")
        raise

def translate_text(text: str, target_lang: str, source_lang: str = SOURCE_LANGUAGE) -> str:
    """
    Translate text from source language to target language.
    Returns empty string if translation fails.
    """
    if not text or not text.strip():
        return ""
    
    try:
        translator = GoogleTranslator(source=source_lang, target=target_lang)
        translated = translator.translate(text)
        return translated if translated else ""
    except Exception as e:
        print(f"    [WARNING] Translation error ({source_lang} -> {target_lang}): {e}")
        return ""

def translate_question_field(question: Dict[str, Any], field_name: str, total: int, current: int) -> None:
    """
    Translate a question field (question text or answer text) to all target languages.
    """
    if field_name not in question:
        return
    
    field_data = question[field_name]
    
    # Handle question text (Map structure)
    if isinstance(field_data, dict):
        source_text = field_data.get(SOURCE_LANGUAGE, "")
        if not source_text:
            return
        
        for target_lang in TARGET_LANGUAGES:
            # Skip if translation already exists and is not empty
            if target_lang in field_data and field_data[target_lang] and field_data[target_lang].strip():
                continue
            
            print(f"  Translating {field_name} to {target_lang}...")
            translated = translate_text(source_text, target_lang)
            if translated:
                field_data[target_lang] = translated
            else:
                print(f"    [WARNING] Failed to translate {field_name} to {target_lang}")

def translate_answer(answer: Dict[str, Any], question_num: int) -> None:
    """Translate an answer's text field to all target languages."""
    if 'text' not in answer:
        return
    
    text_data = answer['text']
    if not isinstance(text_data, dict):
        return
    
    source_text = text_data.get(SOURCE_LANGUAGE, "")
    if not source_text:
        return
    
    for target_lang in TARGET_LANGUAGES:
        # Skip if translation already exists and is not empty
        if target_lang in text_data and text_data[target_lang] and text_data[target_lang].strip():
            continue
        
        translated = translate_text(source_text, target_lang)
        if translated:
            text_data[target_lang] = translated

def process_questions(questions: List[Dict[str, Any]]) -> None:
    """Process all questions and translate missing fields."""
    total = len(questions)
    print(f"\n[INFO] Starting translation process for {total} questions...\n")
    
    for index, question in enumerate(questions, 1):
        question_id = question.get('id', index)
        print(f"[{index}/{total}] Processing Question ID: {question_id}...")
        
        # Translate question text
        translate_question_field(question, 'question', total, index)
        
        # Translate answers
        if 'answers' in question and isinstance(question['answers'], list):
            for answer_index, answer in enumerate(question['answers'], 1):
                translate_answer(answer, question_id)
        
        # Progress indicator
        if index % 10 == 0:
            print(f"   [PROGRESS] {index}/{total} questions processed\n")

def save_questions(questions: List[Dict[str, Any]], file_path: str) -> None:
    """
    Save questions to JSON file with proper formatting.
    CRITICAL: Uses indent=2 and ensure_ascii=False to maintain readability and Unicode characters.
    """
    # Ensure directory exists
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(questions, f, ensure_ascii=False, indent=2)
        print(f"\n[OK] Successfully saved {len(questions)} questions to {file_path}")
        print(f"   File is properly formatted (indent=2, ensure_ascii=False)")
    except Exception as e:
        print(f"[ERROR] Error saving file: {e}")
        raise

def main():
    """Main execution function."""
    print("=" * 70)
    print("German Citizenship Test - Question Translator")
    print("=" * 70)
    
    # Check if file exists
    if not os.path.exists(QUESTIONS_FILE):
        print(f"[ERROR] Questions file not found: {QUESTIONS_FILE}")
        print(f"   Please ensure the file exists in the project root.")
        return
    
    # Create backup
    print("\n[INFO] Creating backup...")
    create_backup(QUESTIONS_FILE, BACKUP_FILE)
    
    # Load questions
    print(f"\n[INFO] Loading questions from {QUESTIONS_FILE}...")
    questions = load_questions(QUESTIONS_FILE)
    
    # Process translations
    print(f"\n[INFO] Starting translation process...")
    print(f"   This may take a while (300 questions x 4 languages = ~1200 translations)")
    print(f"   Please be patient and ensure you have internet connection.\n")
    process_questions(questions)
    
    # Save translated questions
    print(f"\n[INFO] Saving translated questions...")
    save_questions(questions, QUESTIONS_FILE)
    
    print("\n" + "=" * 70)
    print("[SUCCESS] Translation process completed successfully!")
    print("=" * 70)
    print(f"\n[SUMMARY]")
    print(f"   - Total questions processed: {len(questions)}")
    print(f"   - Target languages: {', '.join(TARGET_LANGUAGES)}")
    print(f"   - Backup saved to: {BACKUP_FILE}")
    print(f"   - Updated file: {QUESTIONS_FILE}")

if __name__ == "__main__":
    main()

