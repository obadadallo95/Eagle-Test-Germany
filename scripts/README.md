# Translation Script

This script translates questions from German to English, Turkish, Ukrainian, and Russian.

## Installation

```bash
pip install -r requirements.txt
```

Or install directly:
```bash
pip install deep-translator
```

## Usage

From the project root directory:

```bash
python scripts/translate_questions.py
```

## What it does

1. Creates a backup of `assets/data/questions.json` as `assets/data/questions_backup.json`
2. Loads all questions from the JSON file
3. Translates missing fields:
   - Question text: `question['de']` → `question['en']`, `question['tr']`, `question['uk']`, `question['ru']`
   - Answer text: `answer['text']['de']` → `answer['text']['en']`, etc.
4. Skips fields that already have translations
5. Saves the file with proper formatting (indent=2, ensure_ascii=False)

## Notes

- The script uses Google Translator via `deep_translator`
- It preserves existing translations (won't overwrite)
- Progress is printed to console
- The output JSON is human-readable (not minified)

