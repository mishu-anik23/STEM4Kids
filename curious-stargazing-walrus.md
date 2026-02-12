# Implementation Plan: "School of Adventures" Educational Framework

## Context

Transform the STEM4Kids app from a basic quiz game into an immersive educational platform for elementary school children (ages 6-10). The current app has a flat structure of 4 worlds with 20 levels each, simple scoring (10 pts/question, stars 0-3), and basic progression tracking.

**The Problem:**
- No pedagogical structure (content is just question sets, not learning experiences)
- No story or narrative to engage young learners
- Flat progression (no topic grouping or mastery tracking)
- Leaderboard discourages late joiners (lifetime total score)
- No visual learning aids or micro-lessons
- Content not aligned to age-appropriate curriculum

**The Solution:**
Create a "school of adventures" where each subject is a world, each topic is a chapter, and each chapter has short, replayable levels with clear goals and rewards. Structure content by age (6-7, 7-8, 8-9, 9-10) with 4 subject "islands" per world, implementing story-driven learning with proper educational scaffolding.

**Success Criteria:**
- 4 worlds mapped to age groups with 4 islands (Physics, Chemistry, Math, Nature) each
- Level template: story hook (15-20s) → micro-lesson (30-45s) → practice (60-90s) → challenge (30-60s) → summary (15-20s)
- XP system with effort-based rewards
- Mastery tracking with color indicators (red/yellow/green)
- Weekly leaderboard with friendly displays
- Topic badges and achievements
- Rich educational content mapped to curriculum standards

---

## Implementation Approach: Phased Incremental Development

### Phase 1: Foundation (Data Models & Island Structure) - Weeks 1-2

**Goal:** Establish hierarchical structure (Worlds → Islands → Topics → Levels) without disrupting existing functionality.

#### Backend Changes

**New Models:**

1. **`src/models/Island.js`** (NEW)
   - Represents subject areas within worlds (Physics, Chemistry, Math, Nature)
   - Fields: id, code, worldId, name, description, topicCategory, orderIndex, iconUrl, unlockRequirements, isActive
   - 4 islands per world = 16 total islands

2. **`src/models/Topic.js`** (NEW)
   - Specific learning topics within islands (e.g., "Shadows & Light" in Physics Island)
   - Fields: id, islandId, code, name, description, learningObjectives, orderIndex, iconUrl, difficultyLevel
   - ~8 topics per island = 128 total topics

3. **`src/models/UserIslandProgress.js`** (NEW)
   - Tracks per-user mastery for each island/topic
   - Fields: userId, islandId, topicId, totalXp, levelsCompleted, totalLevels, masteryColor (red/yellow/green), topicBadgeEarned, badgeEarnedAt
   - Mastery color logic:
     - Red (Started): < 30% levels completed OR avg stars < 1.5
     - Yellow (Practicing): 30-80% levels completed AND avg stars >= 1.5
     - Green (Mastered): 80%+ levels completed AND avg stars >= 2.5

**Update Existing Models:**

4. **`src/models/LevelProgress.js`** (UPDATE)
   - Add: islandId, topicId, xpEarned, masteryLevel, firstTryBonus, noHintsBonus
   - Composite unique key remains (userId, worldId, levelId)

5. **`src/models/User.js`** (UPDATE)
   - Add: totalXp, weeklyStars, currentIslandId
   - weeklyStars resets every Monday for leaderboard

**New Controllers:**

6. **`src/controllers/islandController.js`** (NEW)
   - `getWorldIslands(worldId)` - Get 4 islands for a world
   - `getIslandTopics(islandId)` - Get topics for an island
   - `getTopicLevels(topicId)` - Get level IDs for a topic
   - `checkIslandUnlock(userId, islandId)` - Verify unlock requirements met

**New Routes:**
```
GET /api/islands/:worldId
GET /api/islands/:islandId/topics
GET /api/topics/:topicId/levels
GET /api/progress/islands/:userId
```

#### Frontend Changes

**New Models:**

7. **`lib/features/world/models/island.dart`** (NEW)
   - Mirror backend Island model
   - Fields: id, worldId, code, name, description, topicCategory, orderIndex, iconUrl, unlockRequirements, isUnlocked

8. **`lib/features/world/models/topic.dart`** (NEW)
   - Mirror backend Topic model
   - Fields: id, islandId, code, name, description, learningObjectives, orderIndex, iconUrl, difficultyLevel

9. **`lib/data/models/island_progress.dart`** (NEW)
   - Mirror UserIslandProgress model
   - Computed properties for UI display

**New Repositories:**

10. **`lib/data/repositories/island_repository.dart`** (NEW)
    - `Future<List<Island>> getWorldIslands(int worldId)`
    - `Future<List<Topic>> getIslandTopics(String islandId)`
    - `Future<List<int>> getTopicLevelIds(String topicId)`

**Updated Screens:**

11. **`lib/features/world/screens/world_screen.dart`** (UPDATE)
    - Replace flat 20-level grid with 4 island cards
    - Display lock/unlock state, mastery color per island
    - Navigation: tap island → navigate to IslandScreen

**New Screens:**

12. **`lib/features/world/screens/island_screen.dart`** (NEW)
    - Display topics within selected island
    - Topic cards show: name, description, learning objectives, level count, mastery indicator
    - Progress bar: levels completed / total levels
    - XP bar for the island
    - Navigation: tap topic → navigate to topic level map

**Data Structure:**

13. **`assets/data/islands.json`** (NEW)
    - Seed data for 16 islands across 4 worlds
    - Example: World 1 (Age 6-7) has Physics, Chemistry, Math, Nature islands

14. **`assets/data/topics.json`** (NEW)
    - Seed data for ~128 topics
    - Maps topics to islands with learning objectives

**Migration Strategy:**
- Database migration adds new tables (nullable foreign keys initially)
- Backfill script maps existing levels to topics using predefined mapping
- Feature flag `USE_ISLAND_STRUCTURE` toggles new UI
- Gradual rollout: 10% beta → 50% → 100% over 2 weeks

**Testing:**
- Unit tests for Island/Topic models and controllers
- Integration tests for island navigation flow
- Test unlock logic thoroughly (edge cases: incomplete prerequisites)
- Verify existing progress data preserved after migration

---

### Phase 2: Level Template (Story Hook, Micro-Lesson, Summary) - Weeks 3-4

**Goal:** Transform levels from question sets to story-driven learning experiences with structured flow.

#### Backend Changes

**Update Existing:**

15. **`src/models/LevelProgress.js`** (UPDATE)
    - Add tracking fields: storyHookViewed, microLessonCompleted, practiceCompleted, challengeCompleted, summaryViewed
    - Add templateStagesCompleted (JSONB) for granular tracking

16. **`src/controllers/progressController.js`** (UPDATE)
    - New endpoint: `updateLevelStageProgress(userId, levelId, stage, completed)`
    - Track which stages user completes (for analytics)

#### Frontend Changes

**Updated Models:**

17. **`lib/features/game/models/level_data.dart`** (UPDATE - CRITICAL FILE)
    - Add new fields to LevelData:
      - `StoryHook? storyHook`
      - `MicroLesson? microLesson`
      - `List<Question> guidedPractice` (3-5 questions)
      - `List<Question> challengeTasks` (1-2 questions)
      - `LevelSummary? summary`
      - `String? storyScenario` (e.g., "shadow_detective", "cloud_chef")
      - `Map<String, dynamic>? visualMechanics`

    - New classes:
      ```dart
      class StoryHook {
        final String type; // 'comic_panel', 'narration', 'animation'
        final String content;
        final String? imageUrl;
        final String? audioUrl;
        final int durationSeconds; // 15-20s
        final String? characterName;
      }

      class MicroLesson {
        final String type; // 'animation', 'interactive_demo'
        final String title;
        final String content;
        final List<String> keyPoints; // 2-3 bullet points
        final String? animationUrl;
        final int durationSeconds; // 30-45s
        final Map<String, dynamic>? interactiveConfig;
      }

      class LevelSummary {
        final String title;
        final String recap;
        final List<String> keyLearnings;
        final String? badgeUrl;
        final String? collectibleName;
        final String encouragementMessage;
      }
      ```

**Updated BLoC:**

18. **`lib/features/game/bloc/game_bloc.dart`** (UPDATE - CRITICAL FILE)
    - New states: `StoryHookDisplayed`, `MicroLessonActive`, `LevelSummaryDisplayed`
    - New events: `CompleteStoryHookEvent`, `CompleteMicroLessonEvent`, `ViewSummaryEvent`
    - Modified flow in `_onLoadLevel`:
      1. Load level data
      2. If storyHook exists → emit `StoryHookDisplayed`
      3. If microLesson exists → emit `MicroLessonActive`
      4. Proceed to guided practice questions
      5. Then challenge tasks
      6. Finally emit `LevelSummaryDisplayed` (not direct to LevelCompleted)

**New Widgets:**

19. **`lib/features/game/widgets/story_hook_widget.dart`** (NEW)
    - Display comic panel or narration with character avatar
    - Auto-advance timer (15-20s) or manual skip button
    - Background themed to story scenario
    - Speech bubble layout for character dialogue

20. **`lib/features/game/widgets/micro_lesson_widget.dart`** (NEW)
    - Lottie animation player (for .json animations)
    - Key points display (2-3 bullets, large text)
    - "Got it!" confirmation button
    - Interactive demo renderer (for drag-to-learn mechanics)

21. **`lib/features/game/widgets/level_summary_widget.dart`** (NEW)
    - Animated results display (stars, score, XP)
    - Badge/collectible reveal animation (if earned)
    - Key learnings recap (2-3 sentences)
    - Encouragement message
    - Continue button → next level or back to topic map

**Updated Screens:**

22. **`lib/features/game/screens/game_screen.dart`** (UPDATE)
    - Handle new states in BlocConsumer
    - Render StoryHookWidget, MicroLessonWidget, SummaryWidget based on state
    - Maintain existing question rendering for guided practice and challenges

**Level JSON Structure:**

23. **Level JSON files** (UPDATE - example: `assets/data/levels/world_1/island_physics/topic_shadows/level_01.json`)
    ```json
    {
      "levelId": 1,
      "worldId": 1,
      "islandId": "island_w1_physics",
      "topicId": "topic_shadows",
      "title": "Shadow Detective",
      "description": "Help find the lost puppy using shadows!",
      "storyScenario": "shadow_detective",
      "difficulty": "easy",

      "storyHook": {
        "type": "comic_panel",
        "content": "Oh no! Luna the puppy is hiding. Use shadows to find her!",
        "imageUrl": "assets/images/stories/shadow_detective/panel_01.png",
        "audioUrl": "assets/audio/narration/shadow_detective_intro.mp3",
        "durationSeconds": 18,
        "characterName": "Detective Sam"
      },

      "microLesson": {
        "type": "animation",
        "title": "How Shadows Form",
        "content": "Shadows happen when objects block light.",
        "keyPoints": [
          "Light travels in straight lines",
          "Objects block light to create shadows",
          "Shadow size changes with distance"
        ],
        "animationUrl": "assets/animations/shadow_formation.json",
        "durationSeconds": 35
      },

      "guidedPractice": [ /* 3-5 questions */ ],
      "challengeTasks": [ /* 1-2 questions */ ],

      "summary": {
        "title": "Shadow Detective Complete!",
        "recap": "You learned that shadows form when objects block light!",
        "keyLearnings": [
          "Shadows are created by blocking light",
          "Shadow direction shows light source location"
        ],
        "badgeUrl": "assets/images/badges/shadow_detective.png",
        "collectibleName": "Detective Sam's Magnifying Glass",
        "encouragementMessage": "Amazing detective work!"
      }
    }
    ```

**Asset Requirements:**
- Comic panel illustrations: ~256 (32 topics × 8 levels)
- Character sprites: ~32 (2 per island)
- Lottie animations: ~64 (2 per topic)
- Badge icons: ~32 (1 per topic)
- Background scenes: ~32 (1 per island)

**Asset Creation Strategy:**
- Start with 1 complete topic (8 levels) as template
- Use AI tools for initial generation (Midjourney, DALL-E)
- Store in `assets/images/stories/`, `assets/animations/`, `assets/images/badges/`

**Testing:**
- Widget tests for StoryHook, MicroLesson, Summary widgets
- Test level flow transitions: hook → lesson → practice → challenge → summary
- Test skip/auto-advance timers work correctly
- Verify animation loading and playback
- Test stage tracking API calls

---

### Phase 3: Enhanced Progression (XP, Mastery, Badges) - Weeks 5-6

**Goal:** Implement XP system, mastery tracking with color indicators, and topic badge awards.

#### Backend Changes

**Updated Controllers:**

24. **`src/controllers/progressController.js`** (UPDATE - CRITICAL FILE)
    - Enhance `submitLevelCompletion` to calculate XP:
      ```javascript
      function calculateXP(score, hintsUsed, attempts, timeSpent, totalQuestions) {
        let baseXP = 100;
        if (score === 100) baseXP += 50;      // Perfect score
        if (attempts === 1) baseXP += 50;     // First try
        if (hintsUsed === 0) baseXP += 25;    // No hints

        const expectedTime = totalQuestions * 30;
        if (timeSpent < expectedTime) baseXP += 25; // Speed bonus

        // Difficulty multiplier: easy 1.0x, medium 1.2x, hard 1.5x
        return baseXP;
      }
      ```

    - Update mastery level calculation:
      ```javascript
      function updateMasteryLevel(userIslandProgress) {
        const { levelsCompleted, totalLevels, avgStars } = userIslandProgress;

        if (levelsCompleted >= totalLevels * 0.8 && avgStars >= 2.5) {
          return 'green'; // Mastered
        } else if (levelsCompleted >= totalLevels * 0.3 && avgStars >= 1.5) {
          return 'yellow'; // Practicing
        } else {
          return 'red'; // Started
        }
      }
      ```

    - Award topic badges when:
      - All levels in topic completed
      - Average stars >= 2.5
      - Mastery color is green
      - Create achievement record with category 'topic_mastery'

**New Endpoints:**
```
GET /api/progress/mastery/:userId - Get mastery overview per topic/island
```

#### Frontend Changes

**Updated BLoC:**

25. **`lib/features/game/bloc/game_bloc.dart`** (UPDATE)
    - In `_onCompleteLevel`, calculate XP:
      ```dart
      int _calculateXP({
        required int score,
        required int hintsUsed,
        required bool firstTry,
        required bool noHints,
        required int timeSpent,
        required int totalQuestions,
      }) {
        int baseXP = 100;
        if (score == 100) baseXP += 50;
        if (firstTry) baseXP += 50;
        if (noHints) baseXP += 25;

        final expectedTime = totalQuestions * 30;
        if (timeSpent < expectedTime) baseXP += 25;

        return baseXP;
      }
      ```

    - Submit XP to backend with level completion
