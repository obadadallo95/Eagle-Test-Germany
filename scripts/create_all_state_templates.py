#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Create template files for all 16 German states.
These are empty templates that can be filled with actual questions.
"""

import json
import os

STATES_DIR = 'assets/data/states/'

STATE_TEMPLATES = {
    'BW': {
        'name': 'Baden-Württemberg',
        'capital': 'Stuttgart',
        'sample_question': 'Welche Stadt ist die Hauptstadt von Baden-Württemberg?'
    },
    'BY': {
        'name': 'Bayern',
        'capital': 'München',
        'sample_question': 'Welche Stadt ist die Hauptstadt von Bayern?'
    },
    'BE': {
        'name': 'Berlin',
        'capital': 'Berlin',
        'sample_question': 'Welche Stadt ist die Hauptstadt von Berlin?'
    },
    'BB': {
        'name': 'Brandenburg',
        'capital': 'Potsdam',
        'sample_question': 'Welche Stadt ist die Hauptstadt von Brandenburg?'
    },
    'HB': {
        'name': 'Bremen',
        'capital': 'Bremen',
        'sample_question': 'Welche Stadt ist die Hauptstadt von Bremen?'
    },
    'HH': {
        'name': 'Hamburg',
        'capital': 'Hamburg',
        'sample_question': 'Welche Stadt ist die Hauptstadt von Hamburg?'
    },
    'HE': {
        'name': 'Hessen',
        'capital': 'Wiesbaden',
        'sample_question': 'Welche Stadt ist die Hauptstadt von Hessen?'
    },
    'MV': {
        'name': 'Mecklenburg-Vorpommern',
        'capital': 'Schwerin',
        'sample_question': 'Welche Stadt ist die Hauptstadt von Mecklenburg-Vorpommern?'
    },
    'NI': {
        'name': 'Niedersachsen',
        'capital': 'Hannover',
        'sample_question': 'Welche Stadt ist die Hauptstadt von Niedersachsen?'
    },
    'NW': {
        'name': 'Nordrhein-Westfalen',
        'capital': 'Düsseldorf',
        'sample_question': 'Welche Stadt ist die Hauptstadt von Nordrhein-Westfalen?'
    },
    'RP': {
        'name': 'Rheinland-Pfalz',
        'capital': 'Mainz',
        'sample_question': 'Welche Stadt ist die Hauptstadt von Rheinland-Pfalz?'
    },
    'SL': {
        'name': 'Saarland',
        'capital': 'Saarbrücken',
        'sample_question': 'Welche Stadt ist die Hauptstadt von Saarland?'
    },
    'SN': {
        'name': 'Sachsen',
        'capital': 'Dresden',
        'sample_question': 'Welche Stadt ist die Hauptstadt von Sachsen?'
    },
    'ST': {
        'name': 'Sachsen-Anhalt',
        'capital': 'Magdeburg',
        'sample_question': 'Welche Stadt ist die Hauptstadt von Sachsen-Anhalt?'
    },
    'SH': {
        'name': 'Schleswig-Holstein',
        'capital': 'Kiel',
        'sample_question': 'Welche Stadt ist die Hauptstadt von Schleswig-Holstein?'
    },
    'TH': {
        'name': 'Thüringen',
        'capital': 'Erfurt',
        'sample_question': 'Welche Stadt ist die Hauptstadt von Thüringen?'
    },
}

FILENAME_MAP = {
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

def create_capital_question(state_code: str, template: dict) -> dict:
    """Create a capital city question for a state."""
    capital = template['capital']
    state_name = template['name']
    
    # Generate wrong answers (other state capitals)
    other_capitals = [
        'München', 'Berlin', 'Potsdam', 'Bremen', 'Hamburg',
        'Wiesbaden', 'Schwerin', 'Hannover', 'Düsseldorf', 'Mainz',
        'Saarbrücken', 'Dresden', 'Magdeburg', 'Kiel', 'Erfurt', 'Stuttgart'
    ]
    # Remove the correct capital
    wrong_answers = [c for c in other_capitals if c != capital][:3]
    
    question_id = 20000 + int(state_code, 36) % 1000
    
    return {
        "id": question_id,
        "category_id": "state",
        "state_code": state_code,
        "question": {
            "de": f"Welche Stadt ist die Hauptstadt von {state_name}?",
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
                    "de": capital,
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
                    "de": wrong_answers[0],
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
                    "de": wrong_answers[1],
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
                    "de": wrong_answers[2],
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

def main():
    print("=" * 70)
    print("Creating State Template Files")
    print("=" * 70)
    
    os.makedirs(STATES_DIR, exist_ok=True)
    
    created = 0
    skipped = 0
    
    for state_code, template in STATE_TEMPLATES.items():
        filename = FILENAME_MAP[state_code]
        file_path = os.path.join(STATES_DIR, filename)
        
        if os.path.exists(file_path):
            print(f"[SKIP] {state_code}: File already exists ({filename})")
            skipped += 1
            continue
        
        # Create a template with one capital question
        questions = [create_capital_question(state_code, template)]
        
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(questions, f, ensure_ascii=False, indent=2)
        
        print(f"[OK] {state_code}: Created {filename} with 1 template question")
        created += 1
    
    print("\n" + "=" * 70)
    print(f"[SUMMARY]")
    print(f"  - Created: {created} files")
    print(f"  - Skipped: {skipped} files (already exist)")
    print(f"  - Total states: {len(STATE_TEMPLATES)}")
    print("\n[INFO] Next steps:")
    print("  1. Run: python scripts/generate_state_questions.py translate-all")
    print("     This will translate all template questions to 5 languages")
    print("  2. Add more questions manually or using the 'add' command")
    print("  3. Each state should have 10 questions total")

if __name__ == "__main__":
    main()

