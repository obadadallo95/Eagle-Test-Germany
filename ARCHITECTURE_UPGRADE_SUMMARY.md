# 🏗️ Architecture Upgrade: Distributed Data Files

## ✅ Completed Implementation

### 1. File Structure Created
- ✅ `assets/data/states/` directory created
- ✅ `assets/data/questions_general.json` (300 general questions)
- ✅ `assets/data/states/sachsen.json` (2 state-specific questions for Sachsen)
- ✅ Split script created: `scripts/split_questions_by_state.py`

### 2. Code Updates

#### Data Layer
- ✅ **`LocalDataSource`** - Updated to support:
  - `getGeneralQuestions()` - Loads general questions
  - `getStateQuestions(stateCode)` - Loads state-specific questions dynamically
  - Automatic state code to filename mapping
  - Graceful fallback if state file is missing

- ✅ **`QuestionRepository`** - Extended with:
  - `getGeneralQuestions()` - Returns general questions
  - `getStateQuestions(stateCode)` - Returns state questions
  - `getAllQuestions(stateCode)` - Combines general + state questions

#### Provider Layer
- ✅ **`question_provider.dart`** - New providers:
  - `generalQuestionsProvider` - General questions only
  - `stateQuestionsProvider(stateCode)` - State-specific questions (family provider)
  - `questionsProvider` - All questions based on user's selected state

- ✅ **`exam_provider.dart`** - Updated to:
  - Load general questions separately (30 questions)
  - Load state questions separately (3 questions)
  - Merge and shuffle for exam

- ✅ **`quick_practice_provider.dart`** - Updated to use general questions only

- ✅ **`review_provider.dart`** - Works with new structure

- ✅ **`drive_mode_screen.dart`** - Updated to use general questions

### 3. Configuration
- ✅ `pubspec.yaml` - Added `assets/data/states/` to assets list

## 📁 File Naming Convention

The app automatically maps state codes to filenames:

| State Code | Filename |
|------------|----------|
| BW | `baden-wuerttemberg.json` |
| BY | `bayern.json` |
| BE | `berlin.json` |
| BB | `brandenburg.json` |
| HB | `bremen.json` |
| HH | `hamburg.json` |
| HE | `hessen.json` |
| MV | `mecklenburg-vorpommern.json` |
| NI | `niedersachsen.json` |
| NW | `nordrhein-westfalen.json` |
| RP | `rheinland-pfalz.json` |
| SL | `saarland.json` |
| SN | `sachsen.json` |
| ST | `sachsen-anhalt.json` |
| SH | `schleswig-holstein.json` |
| TH | `thueringen.json` |

## 🔄 How It Works

### Initial Load
1. App starts → Loads `questions_general.json` (300 questions)
2. User selects state in onboarding → State code saved to SharedPreferences

### Exam Generation
1. User starts exam → `examQuestionsProvider` activates
2. Loads 30 random questions from general file
3. Loads 3 random questions from state file (e.g., `sachsen.json`)
4. Merges and shuffles → 33-question exam

### Fallback Behavior
- If state file is missing → Uses 33 general questions
- No error shown to user (graceful degradation)
- App continues to function normally

## 📝 Next Steps for User

### To Add More State Questions:

1. **Extract questions from main file:**
   ```bash
   python scripts/split_questions_by_state.py
   ```

2. **Or manually create state files:**
   - Create JSON file in `assets/data/states/`
   - Name it according to the mapping above
   - Include 10 questions per state (as per official test structure)
   - Each question must have `state_code` field matching the state

3. **Verify files are included:**
   - Check `pubspec.yaml` includes `assets/data/states/`
   - Run `flutter pub get` to refresh assets

## 🎯 Benefits

1. **Performance**: Smaller files load faster
2. **Maintainability**: Easy to update individual states
3. **Scalability**: Can add more state questions without affecting general questions
4. **Memory**: Only loads needed questions
5. **Flexibility**: Easy to add/remove state files

## ⚠️ Backward Compatibility

The system maintains backward compatibility:
- If `questions_general.json` doesn't exist, falls back to `questions.json`
- Filters general questions from old file automatically
- Legacy `getQuestions()` method still works

---

**Status**: ✅ Implementation Complete
**Files Created**: 4 new files + 1 directory
**Files Modified**: 6 files
**Backward Compatible**: Yes

