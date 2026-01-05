# State Files Setup Guide

## Overview

The app now uses a distributed file structure:
- **General questions**: `assets/data/questions_general.json` (300 questions)
- **State-specific questions**: `assets/data/states/{state_name}.json` (10 questions per state)

## Quick Start

### Option 1: Automatic Split (Recommended)

Run the split script to automatically create all files:

```bash
python scripts/split_questions_by_state.py
```

This will:
1. Read `assets/data/questions.json`
2. Create `assets/data/questions_general.json` with all general questions
3. Create individual state files in `assets/data/states/` for each state

### Option 2: Manual Setup

1. **Create general questions file:**
   - Copy `assets/data/questions.json` to `assets/data/questions_general.json`
   - Remove all questions with `state_code` field

2. **Create state files:**
   - For each state, create a file named according to the mapping in `assets/data/states/README.md`
   - Extract questions where `state_code` matches the state code
   - Each file should contain ~10 questions

## File Naming

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

## Fallback Behavior

If a state file is missing:
- The app will continue to work
- Exam mode will use 33 general questions instead of 30 general + 3 state-specific
- No error will be shown to the user (graceful degradation)

## Verification

After creating files, verify the structure:

```bash
# Check general file exists
ls assets/data/questions_general.json

# Check states directory
ls assets/data/states/
```

You should see 16 JSON files (one for each state).

