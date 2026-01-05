# Smart Daily Plan & Progress Story - Feature Documentation

## Overview

Two tightly-coupled features that transform the app from a study tool into a supportive coach:

1. **Smart Daily Plan** - Eliminates decision paralysis by telling users exactly what to study today
2. **Progress Story** - Turns raw statistics into a motivating weekly narrative

---

## Feature 1: Smart Daily Plan

### Purpose
Eliminate decision paralysis by generating a personalized daily study plan (5-7 questions) based on:
- Weak questions (SRS difficulty < 2, exam mistakes)
- SRS due questions
- Exam date proximity
- User activity level

### Architecture

**Domain Entity:** `lib/domain/entities/daily_plan.dart`
- `questionIds`: List of question IDs to study today
- `explanation`: Human-readable explanation
- `estimatedMinutes`: Time estimate
- `planType`: 'balanced', 'weakness_focus', 'srs_review', 'exam_prep'

**Use Case:** `lib/domain/usecases/smart_daily_plan_generator.dart`
- Pure Dart logic (no UI dependencies)
- Deterministic: same inputs → same outputs
- Rule-based (no AI)

**Provider:** `lib/presentation/providers/daily_plan_provider.dart`
- `smartDailyPlanProvider`: FutureProvider<DailyPlan>
- `dailyPlanQuestionIdsProvider`: Helper for question IDs
- `hasDailyPlanProvider`: Helper to check if plan exists

### Plan Generation Logic

1. **Identify Weak Questions:**
   - SRS difficulty < 2 (New or Hard)
   - Questions answered incorrectly in recent exams
   - Questions never answered correctly

2. **Get SRS Due Questions:**
   - Questions due for review today (from SRS system)

3. **Get State-Specific Questions:**
   - If state selected, include state questions

4. **Prioritize Based on Context:**
   - **Exam Urgent (< 14 days):** Focus on weak questions
   - **Inactive (> 3 days):** Simplify plan (3 questions)
   - **Normal:** Balanced mix (SRS + weak + state)

5. **Build Plan:**
   - Priority 1: SRS due questions (must review)
   - Priority 2: Weak questions
   - Priority 3: State-specific questions
   - Priority 4: New questions (if space available)
   - Limit: 3-7 questions per day

### Example Output

```dart
DailyPlan(
  questionIds: [45, 123, 201, 89, 156],
  explanation: "Today's Focus: 2 SRS reviews (due today), 3 weak questions.",
  estimatedMinutes: 10,
  planType: 'balanced',
)
```

### Usage

```dart
// In UI
final planAsync = ref.watch(smartDailyPlanProvider);
planAsync.when(
  data: (plan) {
    print(plan.explanation); // "Today's Focus: ..."
    print(plan.questionIds); // [45, 123, ...]
  },
  loading: () => CircularProgressIndicator(),
  error: (e, s) => Text('Error: $e'),
);
```

---

## Feature 2: Progress Story

### Purpose
Turn raw statistics into a motivating weekly narrative that:
- Compares last 7 days vs previous 7 days
- Highlights achievements
- Uses encouraging, non-judgmental tone
- Never shames users

### Architecture

**Domain Entity:** `lib/domain/entities/progress_story.dart`
- `title`: Story title
- `bulletPoints`: List of achievements
- `confidenceMessage`: Final encouraging message
- `weekStart` / `weekEnd`: Week boundaries

**Use Case:** `lib/domain/usecases/weekly_progress_story_builder.dart`
- Pure Dart logic (no UI dependencies)
- Deterministic: same inputs → same outputs
- Rule-based (no AI)

**Provider:** `lib/presentation/providers/progress_story_provider.dart`
- `weeklyProgressStoryProvider`: FutureProvider<ProgressStory>
- `progressStoryTitleProvider`: Helper for title
- `hasProgressStoryProvider`: Helper to check if story exists

### Story Generation Logic

1. **Calculate Current Week Metrics:**
   - New questions mastered (SRS difficulty >= 2)
   - Study sessions (days with study time)
   - Study minutes
   - Exams taken
   - Average exam score

2. **Calculate Previous Week Metrics:**
   - Same metrics for previous 7 days

3. **Calculate Readiness Change:**
   - Current Exam Readiness Index
   - Estimated previous week readiness (heuristic)

4. **Build Story:**
   - **Bullet Points:** Always positive framing
     - "You mastered X questions (+Y from last week)"
     - "You studied X days (+Y from last week)"
     - "You maintained a X-day streak"
   - **Confidence Message:** Context-aware encouragement
     - High progress: "You are now X% more ready than last week. Keep it up!"
     - Steady progress: "You are making steady progress. Every question counts."
     - Low readiness: "You are building your foundation. Keep studying regularly."

### Example Output

```dart
ProgressStory(
  title: "This Week's Progress",
  bulletPoints: [
    "You mastered 12 new questions (+5 from last week)",
    "You studied 5 days (+2 from last week)",
    "You maintained a 7-day study streak",
  ],
  confidenceMessage: "You are now 18% more ready than last week. Keep it up!",
  weekStart: DateTime(2024, 12, 16),
  weekEnd: DateTime(2024, 12, 22),
)
```

### Usage

```dart
// In UI
final storyAsync = ref.watch(weeklyProgressStoryProvider);
storyAsync.when(
  data: (story) {
    print(story.title); // "This Week's Progress"
    for (final point in story.bulletPoints) {
      print("• $point");
    }
    print(story.confidenceMessage);
  },
  loading: () => CircularProgressIndicator(),
  error: (e, s) => Text('Error: $e'),
);
```

---

## Key Design Principles

### 1. Supportive, Not Judgmental
- Always frame positively
- Never shame users for low activity
- Celebrate small wins

### 2. Deterministic
- Same inputs → same outputs
- No randomness
- Testable logic

### 3. Offline-First
- No network required
- Uses local data only
- Works without internet

### 4. Rule-Based (No AI)
- Pure logic, no AI models
- Predictable behavior
- Easy to debug

### 5. Coach-Like Tone
- "Today's Focus" (not "You must study")
- "You are making progress" (not "You're behind")
- "Welcome back!" (not "You've been inactive")

---

## Integration Points

Both features integrate with:
- ✅ `HiveService` - User progress, exam history, study time
- ✅ `SrsService` - Question difficulty levels, due questions
- ✅ `UserPreferencesService` - Exam date, streak, state selection
- ✅ `ExamReadinessCalculator` - Readiness scores (for Progress Story)

---

## Future Enhancements

1. **Question Repository Injection:**
   - Currently uses heuristic for question IDs
   - Should inject `QuestionRepository` for accurate filtering

2. **Topic-Based Grouping:**
   - Group questions by category/topic
   - "3 weak questions (Topic: Constitution)"

3. **Adaptive Time Estimation:**
   - Learn from user's actual study time
   - Adjust estimates based on history

4. **Progress Story Visualizations:**
   - Charts showing progress over time
   - Visual journey map

---

## Status

✅ **Production Ready**
- All core logic implemented
- Well-documented
- Non-breaking (additive features)
- Deterministic and testable

