# State Questions Management Scripts

This directory contains Python scripts to help manage state-specific questions for all 16 German states.

## 📋 Available Scripts

### 1. `create_all_state_templates.py`
Creates template JSON files for all 16 German states with one sample question (capital city).

**Usage:**
```bash
python scripts/create_all_state_templates.py
```

**What it does:**
- Creates JSON files for all 16 states in `assets/data/states/`
- Each file contains 1 template question about the state's capital
- Skips files that already exist

### 2. `generate_state_questions.py`
Main script for managing state questions with translation support.

**Commands:**

#### Create a template file for a specific state:
```bash
python scripts/generate_state_questions.py create <STATE_CODE>
```
Example:
```bash
python scripts/generate_state_questions.py create HE
```

#### Translate all questions in a state file:
```bash
python scripts/generate_state_questions.py translate <STATE_CODE>
```
Example:
```bash
python scripts/generate_state_questions.py translate SN
```

#### Translate all state files at once:
```bash
python scripts/generate_state_questions.py translate-all
```

#### Add a new question interactively:
```bash
python scripts/generate_state_questions.py add <STATE_CODE>
```
Example:
```bash
python scripts/generate_state_questions.py add HE
```

This will prompt you to:
1. Enter the question in German
2. Enter 4 answers in German
3. Specify the correct answer (A, B, C, or D)

The script will automatically translate the question and answers to all 5 languages (ar, en, tr, uk, ru).

## 📝 State Codes Reference

| Code | State Name | Filename |
|------|------------|----------|
| BW | Baden-Württemberg | `baden-wuerttemberg.json` |
| BY | Bayern | `bayern.json` |
| BE | Berlin | `berlin.json` |
| BB | Brandenburg | `brandenburg.json` |
| HB | Bremen | `bremen.json` |
| HH | Hamburg | `hamburg.json` |
| HE | Hessen | `hessen.json` |
| MV | Mecklenburg-Vorpommern | `mecklenburg-vorpommern.json` |
| NI | Niedersachsen | `niedersachsen.json` |
| NW | Nordrhein-Westfalen | `nordrhein-westfalen.json` |
| RP | Rheinland-Pfalz | `rheinland-pfalz.json` |
| SL | Saarland | `saarland.json` |
| SN | Sachsen | `sachsen.json` |
| ST | Sachsen-Anhalt | `sachsen-anhalt.json` |
| SH | Schleswig-Holstein | `schleswig-holstein.json` |
| TH | Thüringen | `thueringen.json` |

## 🔧 Requirements

Install Python dependencies:
```bash
pip install deep-translator
```

## 📚 Workflow Example

### Step 1: Create all template files (if not done)
```bash
python scripts/create_all_state_templates.py
```

### Step 2: Translate all template questions
```bash
python scripts/generate_state_questions.py translate-all
```

### Step 3: Add more questions for each state
For each state, you need 10 questions total. Add them one by one:

```bash
# Add question for Hessen
python scripts/generate_state_questions.py add HE

# Add question for Bayern
python scripts/generate_state_questions.py add BY

# ... and so on
```

### Step 4: Verify translations
After adding questions, translate them:
```bash
python scripts/generate_state_questions.py translate-all
```

## 📊 Current Status

- ✅ All 16 state files created
- ✅ Template questions translated
- ⚠️ Each state needs 9 more questions (currently 1 per state, need 10 total)

## 🎯 Target: 10 Questions Per State

The official German citizenship test includes:
- 300 general questions
- 10 state-specific questions per state

Each state file should contain 10 questions covering:
- State capital
- Major cities
- Geography (rivers, mountains, borders)
- History
- Culture
- Politics
- Economy

## 💡 Tips

1. **Question IDs**: The script auto-generates IDs, but you can specify custom IDs when adding questions programmatically.

2. **Translation Quality**: Always review auto-translations, especially for:
   - Proper nouns (city names, rivers)
   - Technical terms
   - Cultural references

3. **Backup**: Before running translation scripts, consider backing up your files:
   ```bash
   cp -r assets/data/states assets/data/states_backup
   ```

4. **Manual Editing**: You can manually edit JSON files, then run `translate` to fill missing translations.

## 🔍 File Structure

Each state JSON file follows this structure:

```json
[
  {
    "id": 20001,
    "category_id": "state",
    "state_code": "HE",
    "question": {
      "de": "German question text",
      "ar": "Arabic translation",
      "en": "English translation",
      "tr": "Turkish translation",
      "uk": "Ukrainian translation",
      "ru": "Russian translation"
    },
    "answers": [
      {
        "id": "A",
        "text": {
          "de": "German answer",
          "ar": "Arabic answer",
          "en": "English answer",
          "tr": "Turkish answer",
          "uk": "Ukrainian answer",
          "ru": "Russian answer"
        }
      },
      // ... B, C, D
    ],
    "correct_answer": "A"
  }
]
```

## ⚠️ Important Notes

- All questions must have `state_code` matching the file's state
- Each question must have 4 answers (A, B, C, D)
- `correct_answer` must be one of: "A", "B", "C", or "D"
- All 6 languages (de, ar, en, tr, uk, ru) should be present
- Question IDs should be unique across all states

## 🐛 Troubleshooting

### Translation errors
If translation fails for a specific language:
1. Check your internet connection
2. The script will skip failed translations and continue
3. You can manually add translations to the JSON file

### File not found
Ensure you're running scripts from the project root directory:
```bash
cd C:\Users\obada\Desktop\politik_test
python scripts/generate_state_questions.py translate-all
```

### Invalid JSON
If a file becomes corrupted:
1. Restore from backup
2. Use a JSON validator to check syntax
3. Ensure proper encoding (UTF-8)

---

**Last Updated**: 24. Dezember 2025

