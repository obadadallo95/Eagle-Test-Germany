#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Split questions.json into separate files:
1. questions_general.json (questions with state_code == null)
2. Individual state files in assets/data/states/
"""

import json
import os
from pathlib import Path

# Configuration
SOURCE_FILE = 'assets/data/questions.json'
GENERAL_OUTPUT = 'assets/data/questions_general.json'
STATES_DIR = 'assets/data/states/'

# State code to filename mapping
STATE_FILE_MAP = {
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

def load_questions(file_path: str) -> list:
    """Load questions from JSON file."""
    with open(file_path, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_questions(questions: list, file_path: str) -> None:
    """Save questions to JSON file with proper formatting."""
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(questions, f, ensure_ascii=False, indent=2)

def main():
    print("=" * 70)
    print("Question Splitter: General + State-Specific Files")
    print("=" * 70)
    
    # Load all questions
    print(f"\n[INFO] Loading questions from {SOURCE_FILE}...")
    all_questions = load_questions(SOURCE_FILE)
    print(f"[OK] Loaded {len(all_questions)} questions")
    
    # Separate general and state-specific
    general_questions = []
    state_questions = {}
    
    for question in all_questions:
        state_code = question.get('state_code')
        if state_code is None or state_code == '':
            general_questions.append(question)
        else:
            if state_code not in state_questions:
                state_questions[state_code] = []
            state_questions[state_code].append(question)
    
    # Save general questions
    print(f"\n[INFO] Saving {len(general_questions)} general questions...")
    save_questions(general_questions, GENERAL_OUTPUT)
    print(f"[OK] Saved to {GENERAL_OUTPUT}")
    
    # Save state-specific questions
    print(f"\n[INFO] Saving state-specific questions...")
    os.makedirs(STATES_DIR, exist_ok=True)
    
    for state_code, questions in state_questions.items():
        filename = STATE_FILE_MAP.get(state_code.upper(), f'{state_code.lower()}.json')
        file_path = os.path.join(STATES_DIR, filename)
        save_questions(questions, file_path)
        print(f"  [OK] {state_code}: {len(questions)} questions -> {filename}")
    
    # Summary
    print("\n" + "=" * 70)
    print("[SUCCESS] Question splitting completed!")
    print("=" * 70)
    print(f"\n[SUMMARY]")
    print(f"  - General questions: {len(general_questions)}")
    print(f"  - States with questions: {len(state_questions)}")
    for state_code, questions in state_questions.items():
        print(f"    - {state_code}: {len(questions)} questions")
    print(f"\n  - General file: {GENERAL_OUTPUT}")
    print(f"  - State files directory: {STATES_DIR}")

if __name__ == "__main__":
    main()

