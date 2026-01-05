#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
State Questions Generator & Translator
Helps create and translate state-specific questions for all 16 German states.
"""

import json
import os
from deep_translator import GoogleTranslator
from typing import Dict, List, Any

# Configuration
STATES_DIR = 'assets/data/states/'
SOURCE_LANGUAGE = 'de'
TARGET_LANGUAGES = ['ar', 'en', 'tr', 'uk', 'ru']

# State codes and their filenames
STATE_MAP = {
    'BW': 'baden-wuerttemberg.json',
    'BY': 'bayern.json',
    'BE': 'berlin.json',
    'BB': 'brandenburg.json',
    'HB': 'bremen.json',
    'HH': 'hamburg.json',
    'HE': 'hessen.json',
    'MV': 'mecklenburg-vorpommern.json',
    'NI': 'niedersachsen.json',
    'NW': 'nordrhein-westfalen.json',
    'RP': 'rheinland-pfalz.json',
    'SL': 'saarland.json',
    'SN': 'sachsen.json',
    'ST': 'sachsen-anhalt.json',
    'SH': 'schleswig-holstein.json',
    'TH': 'thueringen.json',
}

def translate_text(text: str, target_lang: str, source_lang: str = SOURCE_LANGUAGE) -> str:
    """Translate text from source to target language."""
    if not text or not text.strip():
        return ""
    
    try:
        translator = GoogleTranslator(source=source_lang, target=target_lang)
        translated = translator.translate(text)
        return translated if translated else ""
    except Exception as e:
        print(f"    [WARNING] Translation error ({source_lang} -> {target_lang}): {e}")
        return ""

def translate_question(question: Dict[str, Any]) -> Dict[str, Any]:
    """Translate a question object to all target languages."""
    # Translate question text
    if 'question' in question and isinstance(question['question'], dict):
        source_text = question['question'].get(SOURCE_LANGUAGE, "")
        if source_text:
            for lang in TARGET_LANGUAGES:
                if lang not in question['question'] or not question['question'][lang]:
                    translated = translate_text(source_text, lang)
                    if translated:
                        question['question'][lang] = translated
    
    # Translate answers
    if 'answers' in question and isinstance(question['answers'], list):
        for answer in question['answers']:
            if 'text' in answer and isinstance(answer['text'], dict):
                source_text = answer['text'].get(SOURCE_LANGUAGE, "")
                if source_text:
                    for lang in TARGET_LANGUAGES:
                        if lang not in answer['text'] or not answer['text'][lang]:
                            translated = translate_text(source_text, lang)
                            if translated:
                                answer['text'][lang] = translated
    
    return question

def load_state_file(state_code: str) -> List[Dict[str, Any]]:
    """Load questions from a state file."""
    filename = STATE_MAP.get(state_code.upper())
    if not filename:
        return []
    
    file_path = os.path.join(STATES_DIR, filename)
    if not os.path.exists(file_path):
        return []
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"[ERROR] Failed to load {file_path}: {e}")
        return []

def save_state_file(state_code: str, questions: List[Dict[str, Any]]) -> None:
    """Save questions to a state file."""
    filename = STATE_MAP.get(state_code.upper())
    if not filename:
        print(f"[ERROR] Invalid state code: {state_code}")
        return
    
    file_path = os.path.join(STATES_DIR, filename)
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(questions, f, ensure_ascii=False, indent=2)
    
    print(f"[OK] Saved {len(questions)} questions to {file_path}")

def add_question_to_state(state_code: str, question_de: str, answers_de: List[str], correct_answer: str, question_id: int = None) -> None:
    """Add a new question to a state file with automatic translation."""
    questions = load_state_file(state_code)
    
    # Generate ID if not provided
    if question_id is None:
        question_id = 20000 + (len(questions) + 1) * 100 + int(state_code, 36) % 100
    
    # Create question structure
    new_question = {
        "id": question_id,
        "category_id": "state",
        "state_code": state_code.upper(),
        "question": {
            "de": question_de
        },
        "answers": [],
        "correct_answer": correct_answer.upper()
    }
    
    # Add answers
    answer_ids = ['A', 'B', 'C', 'D']
    for i, answer_text in enumerate(answers_de[:4]):
        new_question["answers"].append({
            "id": answer_ids[i],
            "text": {
                "de": answer_text
            }
        })
    
    # Translate the question
    print(f"[INFO] Translating question for {state_code}...")
    new_question = translate_question(new_question)
    
    # Add to list
    questions.append(new_question)
    
    # Save
    save_state_file(state_code, questions)
    print(f"[SUCCESS] Question added and translated for {state_code}")

def translate_existing_state_file(state_code: str) -> None:
    """Translate all questions in a state file that are missing translations."""
    questions = load_state_file(state_code)
    
    if not questions:
        print(f"[WARNING] No questions found for {state_code}")
        return
    
    print(f"[INFO] Translating {len(questions)} questions for {state_code}...")
    
    for i, question in enumerate(questions, 1):
        print(f"  [{i}/{len(questions)}] Translating question ID: {question.get('id', 'unknown')}...")
        question = translate_question(question)
    
    save_state_file(state_code, questions)
    print(f"[SUCCESS] Translation completed for {state_code}")

def create_template_file(state_code: str) -> None:
    """Create a template file for a state with example structure."""
    filename = STATE_MAP.get(state_code.upper())
    if not filename:
        print(f"[ERROR] Invalid state code: {state_code}")
        return
    
    file_path = os.path.join(STATES_DIR, filename)
    
    if os.path.exists(file_path):
        print(f"[WARNING] File already exists: {file_path}")
        response = input("Overwrite? (y/n): ")
        if response.lower() != 'y':
            return
    
    template = [
        {
            "id": 20001,
            "category_id": "state",
            "state_code": state_code.upper(),
            "question": {
                "de": "Example question in German",
                "ar": "",
                "en": "",
                "tr": "",
                "uk": "",
                "ru": ""
            },
            "answers": [
                {
                    "id": "A",
                    "text": {
                        "de": "Answer A in German",
                        "ar": "",
                        "en": "",
                        "tr": "",
                        "uk": "",
                        "ru": ""
                    }
                },
                {
                    "id": "B",
                    "text": {
                        "de": "Answer B in German",
                        "ar": "",
                        "en": "",
                        "tr": "",
                        "uk": "",
                        "ru": ""
                    }
                },
                {
                    "id": "C",
                    "text": {
                        "de": "Answer C in German",
                        "ar": "",
                        "en": "",
                        "tr": "",
                        "uk": "",
                        "ru": ""
                    }
                },
                {
                    "id": "D",
                    "text": {
                        "de": "Answer D in German",
                        "ar": "",
                        "en": "",
                        "tr": "",
                        "uk": "",
                        "ru": ""
                    }
                }
            ],
            "correct_answer": "A"
        }
    ]
    
    save_state_file(state_code, template)
    print(f"[SUCCESS] Template file created for {state_code}")

def main():
    import sys
    
    print("=" * 70)
    print("State Questions Generator & Translator")
    print("=" * 70)
    
    if len(sys.argv) < 2:
        print("\nUsage:")
        print("  python scripts/generate_state_questions.py create <STATE_CODE>")
        print("    - Create a template file for a state")
        print("\n  python scripts/generate_state_questions.py translate <STATE_CODE>")
        print("    - Translate all questions in a state file")
        print("\n  python scripts/generate_state_questions.py translate-all")
        print("    - Translate all state files")
        print("\n  python scripts/generate_state_questions.py add <STATE_CODE>")
        print("    - Interactive mode to add a question")
        print("\nExample:")
        print("  python scripts/generate_state_questions.py create HE")
        print("  python scripts/generate_state_questions.py translate SN")
        return
    
    command = sys.argv[1].lower()
    
    if command == 'create':
        if len(sys.argv) < 3:
            print("[ERROR] Please provide state code (e.g., HE, BY, BE)")
            return
        state_code = sys.argv[2].upper()
        create_template_file(state_code)
    
    elif command == 'translate':
        if len(sys.argv) < 3:
            print("[ERROR] Please provide state code (e.g., HE, BY, BE)")
            return
        state_code = sys.argv[2].upper()
        translate_existing_state_file(state_code)
    
    elif command == 'translate-all':
        print("[INFO] Translating all state files...")
        for state_code in STATE_MAP.keys():
            print(f"\n--- Processing {state_code} ---")
            translate_existing_state_file(state_code)
        print("\n[SUCCESS] All state files translated!")
    
    elif command == 'add':
        if len(sys.argv) < 3:
            print("[ERROR] Please provide state code (e.g., HE, BY, BE)")
            return
        state_code = sys.argv[2].upper()
        
        print(f"\n[INFO] Adding question for {state_code}")
        print("Enter question in German:")
        question_de = input("Question: ").strip()
        
        print("\nEnter 4 answers in German:")
        answers_de = []
        for i in range(4):
            answer = input(f"Answer {chr(65+i)}: ").strip()
            answers_de.append(answer)
        
        print("\nEnter correct answer (A, B, C, or D):")
        correct = input("Correct: ").strip().upper()
        
        add_question_to_state(state_code, question_de, answers_de, correct)
    
    else:
        print(f"[ERROR] Unknown command: {command}")

if __name__ == "__main__":
    main()

