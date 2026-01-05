# State-Specific Questions Directory

This directory contains JSON files for state-specific questions for each of the 16 German states (Bundesländer).

## File Naming Convention

Each state file must be named using lowercase with hyphens, matching the following pattern:

| State Code | State Name | Filename |
|------------|------------|----------|
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

## JSON Structure

Each state file should follow the same structure as `questions_general.json`:

```json
[
  {
    "id": 1,
    "category_id": "state_specific",
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
      }
    ],
    "correct_answer": "A",
    "state_code": "SN"
  }
]
```

## Important Notes

- Each state file should contain **10 questions** (as per the official test structure)
- The `state_code` field should match the state code (e.g., "SN" for Sachsen)
- If a state file is missing, the app will gracefully fallback to using general questions only
- All 6 languages (de, ar, en, tr, uk, ru) should be included in each question and answer

## Creating State Files

You can extract state-specific questions from the main `questions.json` file by filtering questions where `state_code` matches the desired state code.

Example command (using Python):
```python
import json

# Load main questions file
with open('assets/data/questions.json', 'r', encoding='utf-8') as f:
    all_questions = json.load(f)

# Filter for Sachsen (SN)
sachsen_questions = [q for q in all_questions if q.get('state_code') == 'SN']

# Save to state file
with open('assets/data/states/sachsen.json', 'w', encoding='utf-8') as f:
    json.dump(sachsen_questions, f, ensure_ascii=False, indent=2)
```

## Automatic File Creation

The easiest way to create all state files is using the provided Python script:

```bash
python scripts/split_questions_by_state.py
```

This script will:
1. Read `assets/data/questions.json`
2. Separate general questions (state_code == null) → `questions_general.json`
3. Create individual state files in `assets/data/states/` for each state found
4. Automatically use the correct filenames based on state codes

## How the App Loads State Files

### Dynamic Loading Process

1. **User Selection**: User selects a state during onboarding (e.g., "Hessen" → code: "HE")
2. **State Code Saved**: State code is saved to `SharedPreferences` via `UserPreferencesService`
3. **File Mapping**: App maps state code to filename:
   - `HE` → `hessen.json`
   - `SN` → `sachsen.json`
   - `BY` → `bayern.json`
   - etc.
4. **File Loading**: App attempts to load `assets/data/states/{filename}.json`
5. **Fallback**: If file doesn't exist, app gracefully continues with general questions only

### Code Implementation

The mapping is handled in `lib/data/datasources/local_datasource.dart`:

```dart
String _getStateFileName(String stateCode) {
  final stateFileMap = {
    'BW': 'baden-wuerttemberg.json',
    'BY': 'bayern.json',
    // ... etc
  };
  return stateFileMap[stateCode.toUpperCase()] ?? '${stateCode.toLowerCase()}.json';
}
```

## Exam Generation Logic

When generating an exam:

1. **Load General Questions**: 300 questions from `questions_general.json`
2. **Select 30 Random**: Pick 30 random questions from general pool
3. **Load State Questions**: Load state-specific file (e.g., `hessen.json`)
4. **Select 3 Random**: Pick 3 random questions from state pool
5. **Merge & Shuffle**: Combine 30 + 3 = 33 questions, shuffle them
6. **Fallback**: If state file missing → use 33 general questions

## Current Status

### Files Created
- ✅ `questions_general.json` - 300 general questions
- ✅ `sachsen.json` - 2 questions for Sachsen (SN)

### Files Needed
To complete the setup, you need to create files for the remaining 15 states:
- `baden-wuerttemberg.json` (BW)
- `bayern.json` (BY)
- `berlin.json` (BE)
- `brandenburg.json` (BB)
- `bremen.json` (HB)
- `hamburg.json` (HH)
- `hessen.json` (HE)
- `mecklenburg-vorpommern.json` (MV)
- `niedersachsen.json` (NI)
- `nordrhein-westfalen.json` (NW)
- `rheinland-pfalz.json` (RP)
- `saarland.json` (SL)
- `sachsen-anhalt.json` (ST)
- `schleswig-holstein.json` (SH)
- `thueringen.json` (TH)

## Validation

### Check File Structure
Each state file should:
- ✅ Be valid JSON
- ✅ Contain an array of question objects
- ✅ Each question must have `state_code` field matching the state
- ✅ Include all 6 language translations (de, ar, en, tr, uk, ru)
- ✅ Have 4 answers per question (A, B, C, D)
- ✅ Include `correct_answer` field

### Testing
To verify a state file works:
1. Select the state in app onboarding
2. Start a full exam
3. Verify you get 33 questions (30 general + 3 state-specific)
4. Check that state-specific questions appear in the exam

## Troubleshooting

### Issue: State questions not appearing in exam
**Solution**: 
- Check file exists in `assets/data/states/`
- Verify filename matches the mapping table
- Check `pubspec.yaml` includes `assets/data/states/`
- Run `flutter pub get` to refresh assets

### Issue: App crashes when loading state file
**Solution**:
- Verify JSON is valid (use JSON validator)
- Check all required fields are present
- Ensure `state_code` matches the filename state

### Issue: Wrong questions for selected state
**Solution**:
- Verify `state_code` in JSON matches the state code
- Check filename matches the state code mapping
- Clear app data and re-run onboarding

## Best Practices

1. **Consistency**: Keep same structure across all state files
2. **Completeness**: Include all 6 languages in every question
3. **Validation**: Test each state file after creation
4. **Backup**: Keep original `questions.json` as backup
5. **Version Control**: Commit state files separately for easier updates

## File Size Guidelines

- **General file**: ~17,000 lines (300 questions × 6 languages)
- **State file**: ~600 lines (10 questions × 6 languages)
- **Total**: ~18,200 lines for complete dataset

## Migration Notes

If you're migrating from the old single-file structure:

1. Run `split_questions_by_state.py` to automatically create files
2. Verify `questions_general.json` contains exactly 300 questions
3. Check each state file contains questions with matching `state_code`
4. Test exam generation for each state
5. Update app version to reflect new architecture

---

**Last Updated**: 24. Dezember 2025  
**Maintainer**: See `README.md` in project root

