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
    -     - Emit `LevelSummaryDisplayed` with xpEarned, topicBadge (if earned), masteryColor

**New Widgets:**

26. **`lib/features/world/widgets/mastery_indicator.dart`** (NEW)
    - Display color-coded mastery level with icon
    - Red (🔴 Started), Yellow (🟡 Practicing), Green (🟢 Mastered)
    - Used in island/topic cards

27. **`lib/features/profile/widgets/xp_bar.dart`** (NEW)
    - Animated progress bar showing XP to next level
    - Current level badge display
    - Formula: `level = (totalXp / 1000).floor() + 1`

**Updated Widgets:**

28. **`lib/features/game/widgets/level_summary_widget.dart`** (UPDATE)
    - Add XP gain indicator with animated counter
    - Add topic badge unlock animation (if earned)
    - Display mastery color for the topic
    - "Level Up" animation if user crosses XP milestone

29. **`lib/features/world/screens/island_screen.dart`** (UPDATE)
    - Display mastery indicator per topic
    - Show topic badge icon if earned
    - Progress bar: levels completed / total levels
    - XP bar for the island

**Updated Models:**

30. **`lib/data/models/user.dart`** (UPDATE)
    - Add computed properties:
      ```dart
      int get level => (totalXp / 1000).floor() + 1;
      int get xpForNextLevel => ((level) * 1000) - totalXp;
      double get levelProgress => (totalXp % 1000) / 1000;
      ```

**Testing:**
- Test XP calculation matches backend logic exactly
- Test mastery color transitions (red → yellow → green)
- Test badge unlock conditions
- Test XP bar animations
- Verify badge display in summary screen

---

### Phase 4: Leaderboard Redesign (Weekly, Friendly Display) - Weeks 7-8

**Goal:** Transform leaderboard to weekly stars, friendly displays (1st/2nd/3rd), and support classroom groups.

#### Backend Changes

**New Models:**

31. **`src/models/Classroom.js`** (NEW)
    - Fields: id, code (8-char unique), name, teacherId, grade, isActive, maxStudents
    - Code generation: random alphanumeric (e.g., "ABC123XY")

32. **`src/models/ClassroomMembership.js`** (NEW)
    - Fields: id, userId, classroomId, joinedAt, isActive
    - Unique constraint: (userId, classroomId)

**Updated Redis Logic:**

33. **`src/config/redis.js`** (UPDATE)
    - Maintain separate sorted sets:
      - `leaderboard:weekly:{weekKey}` - Weekly stars (all users)
      - `leaderboard:classroom:{classroomId}:{weekKey}` - Classroom weekly
      - `leaderboard:friends:{userId}:{weekKey}` - Friends weekly

    - `updateWeeklyStars(userId, starsEarned)` updates all relevant leaderboards

    - `resetWeeklyLeaderboard()` runs Monday 00:00:
      - Archive last week's data
      - Initialize new week
      - Reset all users' weeklyStars to 0

**Updated Controllers:**

34. **`src/controllers/leaderboardController.js`** (UPDATE)
    - Modify `getWeeklyLeaderboard` to return friendly format:
      ```javascript
      {
        rank: 1,
        rankDisplay: '🥇 1st',
        username: 'alex',
        avatarUrl: '...',
        weeklyStars: 42,
        starsDisplay: '42 ⭐',
        showExactScore: true // only for top 3
      }
      ```

    - New endpoints:
      - `POST /api/classrooms/join` - Join classroom by code
      - `GET /api/classrooms/:classroomId/leaderboard` - Classroom leaderboard
      - `GET /api/leaderboard/friends` - Friends leaderboard

**New Cron Job:**

35. **`src/jobs/weeklyLeaderboardReset.js`** (NEW)
    - Runs every Monday at 00:00 (cron: `0 0 * * 1`)
    - Calls `resetWeeklyLeaderboard()`
    - Sends notifications to users about new week

#### Frontend Changes

**New Models:**

36. **`lib/data/models/classroom.dart`** (NEW)
    - Fields: id, code, name, teacherId, grade, memberCount, isActive

**New Repositories:**

37. **`lib/data/repositories/classroom_repository.dart`** (NEW)
    - `Future<Classroom> joinClassroom(String classroomCode)`
    - `Future<List<LeaderboardEntry>> getClassroomLeaderboard(String classroomId)`

**Updated BLoC:**

38. **`lib/features/leaderboard/bloc/leaderboard_bloc.dart`** (UPDATE)
    - New events: `LoadClassroomLeaderboard`, `LoadFriendsLeaderboard`
    - Support type parameter: 'global', 'weekly', 'classroom', 'friends'

**Updated Screens:**

39. **`lib/features/leaderboard/screens/leaderboard_screen.dart`** (UPDATE)
    - Add tab bar: Global | Weekly | Classroom | Friends
    - Add podium display for top 3 (special visual):
      - Different heights (1st tallest, 2nd second, 3rd third)
      - Medals: 🥇 🥈 🥉
      - Larger avatars for top 3
    - List view for 4th onwards
    - User position card at bottom (if not in top 10)
    - Week countdown timer: "Resets in 3 days"

**New Screens:**

40. **`lib/features/leaderboard/screens/join_classroom_screen.dart`** (NEW)
    - Input field for 8-character classroom code
    - Join button
    - Display current classroom if already joined
    - Option to leave classroom

**Testing:**
- Test weekly reset logic (simulate cron job)
- Test classroom isolation (users only see their classroom)
- Test rank display formatting (1st, 2nd, 3rd, 4th+)
- Test podium layout for top 3
- Test classroom code validation

---

### Phase 5: Content Creation (Curriculum Mapping) - Weeks 9-16

**Goal:** Create curriculum-aligned educational content with story scenarios and visual mechanics for all topics.

#### Content Structure by Age Group

**World 1 (Ages 6-7) - 4 Islands:**
1. **Physics Island** (2 topics, 16 levels):
   - Shadows & Light (8 levels) - Story: "Shadow Detective"
   - Push & Pull Forces (8 levels) - Story: "Playground Heroes"

2. **Chemistry/Materials Island** (2 topics, 16 levels):
   - Solids vs Liquids (8 levels) - Story: "State Explorers"
   - Materials Around Us (8 levels) - Story: "Building Brigade"

3. **Math Island** (2 topics, 16 levels):
   - Number Bonds to 10 (8 levels) - Story: "Treasure Pairs"
   - Simple Addition (8 levels) - Story: "Beach Counting"

4. **Nature Island** (2 topics, 16 levels):
   - Plants & Growth (8 levels) - Story: "Garden Guardians"
   - Seasons (8 levels) - Story: "Weather Wizards"

**World 2 (Ages 7-8) - 4 Islands:**
1. **Physics Island**: Magnets, Sound & Vibrations
2. **Chemistry Island**: Mixing Materials, Changes in Materials
3. **Math Island**: Place Value, Multiplication
4. **Nature Island**: Animal Habitats, Food Chains

**World 3 (Ages 8-9) - 4 Islands:**
1. **Physics Island**: Light Reflection, Sound Pitch
2. **Chemistry Island**: States of Matter, Simple Changes
3. **Math Island**: Multiplication Facts, Simple Fractions
4. **Nature Island**: Rock Types, Ecosystems

**World 4 (Ages 9-10) - 4 Islands:**
1. **Physics Island**: Gravity & Friction, Simple Circuits
2. **Chemistry Island**: Mixtures & Solutions, Reversible Changes
3. **Math Island**: Multi-step Problems, Decimals
4. **Nature Island**: Life Cycles, Earth & Space

#### Story Scenario Example: "Cloud Chef" (States of Matter, Ages 7-8)

**Story Premise:**
Cloud Chef runs a magical kitchen where ingredients change states. Help prepare dishes by understanding how temperature affects matter.

**Visual Mechanics:**
- Drag heat stones near ice to melt it
- Interactive thermometer controls temperature
- Bubbling animation for boiling
- Frost effect for freezing
- Drag water droplets to show evaporation

**Level Progression (8 levels):**
1. Ice to Water (melting basics)
2. Water to Steam (evaporation)
3. Steam to Water (condensation)
4. Freezing Point (temperature thresholds)
5. Boiling Point (temperature thresholds)
6. State Cycle (complete water cycle)
7. Reversible Changes (melting and freezing)
8. **Boss Level:** Multi-step Recipe (apply all concepts to cook magical soup)

**Example Level 1 Breakdown:**

Story Hook (18s):
- "Cloud Chef needs your help! The ice cream is too hard to scoop. Can you melt it just enough?"
- Character: Cloud Chef (friendly chef with cloud-shaped hat)
- Comic panel: Chef looking worried at frozen ice cream

Micro-Lesson (35s):
- Animation: Ice cube in sun, slowly melting into water
- Key Points:
  - "Heat makes ice melt into water"
  - "Ice (solid) becomes water (liquid) when warm"
  - "This change is called melting"
- Interactive Demo: User controls heat slider, watches ice melt in real-time

Guided Practice (3 questions, ~90s):
1. "Why is the ice cream melting?"
   - Options: "It's getting warm" ✓, "It's too cold", "Magic", "It's raining"
2. "Drag the heat stone close to the ice. What happens?"
   - Drag-and-drop interaction, ice melts when heat is near
3. "Which will melt ice fastest?"
   - Images: Hot sun ✓, Lamp, Fridge, Freezer

Challenge Task (1 question, ~45s):
"Help Cloud Chef prepare iced tea! Put the steps in order:"
- Drag to sequence: Fill cup with ice → Add heat → Ice melts → Add tea bag

Summary (20s):
- Recap: "You learned that heat makes ice melt into water!"
- Key Learnings:
  - Ice is solid, water is liquid
  - Adding heat changes ice to water (melting)
  - This is how ice cream melts on hot days!
- Badge: "Melting Master" (fork and ice cube icon)
- Collectible: "Cloud Chef's Heat Stone"

#### Asset Creation Plan

**Per Topic (8 levels):**
- 1 character sprite (512×512 PNG)
- 1 background scene (1920×1080 PNG)
- 2-3 comic panels for story hooks
- 1-2 Lottie animations for micro-lessons
- 1 topic badge icon (256×256 PNG)
- 5-10 question images (various sizes)
- Interactive element sprites (draggable items)

**Total Asset Estimate:**
- Characters: 32 (4 worlds × 4 islands × 2 topics)
- Backgrounds: 32
- Comic panels: 256 (32 topics × 8 levels)
- Lottie animations: 64 (32 topics × 2)
- Topic badges: 32
- Question images: ~500

**Asset Creation Strategy:**
1. **Week 9-10:** Create 1 complete topic (Shadow Detective, 8 levels) as template
2. **Week 11-12:** Replicate for 3 more topics in World 1 (16 islands total)
3. **Week 13-14:** Create World 2 content (8 topics)
4. **Week 15-16:** Create Worlds 3-4 content (16 topics)
5. Use AI tools for initial generation (Midjourney, DALL-E)
6. Lottie animations via LottieFiles or After Effects
7. Store on CDN for fast delivery

**Asset Organization:**
```
assets/
  images/
    stories/
      shadow_detective/
        panel_01.png, panel_02.png, ...
      cloud_chef/
        panel_01.png, ...
    badges/
      shadow_expert.png
      fraction_hero.png
    characters/
      detective_sam.png
      cloud_chef.png
  animations/
    shadow_formation.json
    water_cycle.json
  audio/
    narration/
      shadow_detective_intro.mp3
```

#### Content Quality Assurance

**Educational Review:**
- Teacher review for curriculum alignment
- Age-appropriateness testing with 6-10 year olds
- Difficulty progression validation (each topic should ramp smoothly)
- Story coherence testing

**Technical Testing:**
- Asset loading performance (< 2s per level)
- Animation smoothness (60 FPS target)
- Interactive mechanics responsiveness
- Cross-device compatibility (tablets, phones)

---

## Critical Files Summary

Based on this plan, here are the 10 most critical files that will undergo the most significant changes:

### Backend (Node.js/Express)
1. **`src/models/Island.js`** (NEW) - Core hierarchical structure
2. **`src/models/LevelProgress.js`** (UPDATE) - Add XP, mastery tracking
3. **`src/controllers/progressController.js`** (UPDATE) - XP/mastery/badge logic
4. **`src/config/redis.js`** (UPDATE) - Weekly leaderboard logic

### Frontend (Flutter)
5. **`lib/features/game/models/level_data.dart`** (UPDATE) - Story/lesson/summary structure
6. **`lib/features/game/bloc/game_bloc.dart`** (UPDATE) - Level flow orchestration
7. **`lib/features/game/screens/game_screen.dart`** (UPDATE) - Render new widgets
8. **`lib/features/world/screens/world_screen.dart`** (UPDATE) - Island navigation
9. **`lib/data/repositories/island_repository.dart`** (NEW) - Island/topic data access
10. **`lib/features/leaderboard/screens/leaderboard_screen.dart`** (UPDATE) - Podium display

---

## Data Migration Strategy

### Database Migration (Week 1)
```sql
-- 1. Add new tables
CREATE TABLE islands (...);
CREATE TABLE topics (...);
CREATE TABLE user_island_progress (...);
CREATE TABLE classrooms (...);
CREATE TABLE classroom_memberships (...);

-- 2. Add columns to existing tables (nullable initially)
ALTER TABLE level_progress ADD COLUMN island_id UUID;
ALTER TABLE level_progress ADD COLUMN topic_id UUID;
ALTER TABLE level_progress ADD COLUMN xp_earned INT DEFAULT 0;
ALTER TABLE users ADD COLUMN total_xp INT DEFAULT 0;
ALTER TABLE users ADD COLUMN weekly_stars INT DEFAULT 0;
```

### Data Backfill (Week 2)
```javascript
// Map existing 20 levels per world to new island/topic structure
const levelMapping = {
  // World 1
  'w1_l1-8': { island: 'island_w1_physics', topic: 'topic_shadows' },
  'w1_l9-16': { island: 'island_w1_math', topic: 'topic_addition' },
  // ... etc
};

// Update existing LevelProgress records
for (const progress of existingProgress) {
  const mapping = levelMapping[`w${progress.worldId}_l${progress.levelId}`];
  await progress.update({
    islandId: mapping.island,
    topicId: mapping.topic
  });
}

// Create UserIslandProgress records from existing data
// based on aggregated LevelProgress
```

### Gradual Rollout
- **Week 1:** Backend migration in staging environment
- **Week 2:** Frontend feature flag enabled for internal testing (5 users)
- **Week 3:** Beta users (10% of user base)
- **Week 4:** Full rollout (100% of users)

### Rollback Plan
- Keep old API endpoints active for 2 weeks
- Feature flag to revert to old UI (`USE_ISLAND_STRUCTURE = false`)
- Database backup before migration
- Separate deployment branches (main, island-structure)

---

## Testing Strategy

### Unit Tests
**Backend:**
- Island/Topic model validations
- XP calculation edge cases (zero score, max bonuses, etc.)
- Mastery color calculation (boundary conditions)
- Badge award logic (all levels completed, avg stars, etc.)
- Weekly reset logic (timezone handling)

**Frontend:**
- Widget tests for all new widgets (StoryHook, MicroLesson, Summary, etc.)
- BLoC state transitions (hook → lesson → practice → challenge → summary)
- XP calculation matches backend
- Mastery color logic

### Integration Tests
**Backend:**
- Full level completion flow (submit → calculate XP → update mastery → check badge)
- Classroom leaderboard updates correctly
- Weekly reset across timezones

**Frontend:**
- Navigation flow: World → Island → Topic → Level → Summary
- Level flow: StoryHook → MicroLesson → Guided Practice → Challenge → Summary
- Leaderboard type switching (global, weekly, classroom, friends)

### End-to-End Tests
**Critical User Paths:**
1. New user joins → completes first level → earns XP → sees mastery indicator
2. User completes all levels in topic → earns badge → sees badge in summary
3. User joins classroom → completes level → appears on classroom leaderboard
4. Weekly reset happens → user sees new weekly leaderboard, weeklyStars reset to 0

### Performance Tests
- Level loading time < 2s (including assets)
- Asset loading progressive (no blocking)
- Leaderboard query performance (Redis < 100ms)
- Database query optimization (indexes on foreign keys)

---

## Success Metrics

### Phase 1 (Foundation)
- ✅ All users migrated to island structure with zero data loss
- ✅ < 5% increase in level loading time
- ✅ 90%+ users can navigate new structure without help

### Phase 2 (Level Template)
- ✅ Average level completion time: 2-4 minutes
- ✅ 80%+ users view story hooks (not skipping)
- ✅ 70%+ users complete micro-lessons
- ✅ Engagement increase: 20%+ time in app

### Phase 3 (XP & Mastery)
- ✅ 80%+ users earn at least 1 topic badge
- ✅ Average XP per session: 500+
- ✅ Mastery distribution: 40% green, 35% yellow, 25% red (healthy)

### Phase 4 (Leaderboard)
- ✅ 60%+ users check leaderboard weekly
- ✅ 40%+ users join a classroom
- ✅ Weekly active users increase: 25%+
- ✅ User retention (WoW): 10%+ improvement

### Phase 5 (Content)
- ✅ All 32 topics have 8+ levels
- ✅ Educational quality score (teacher review): 4.5/5+
- ✅ Age-appropriateness score: 4.5/5+
- ✅ User-reported "learned something new": 85%+

---

## Risk Mitigation

### Technical Risks
**Risk:** Migration breaks existing user progress
- **Mitigation:** Comprehensive backfill scripts, staging testing, gradual rollout (10% → 50% → 100%)

**Risk:** Asset loading degrades performance
- **Mitigation:** CDN delivery, progressive loading, image compression, caching strategy

**Risk:** Weekly reset logic fails
- **Mitigation:** Redundant cron jobs, manual reset capability, extensive timezone testing

### Content Risks
**Risk:** Content creation timeline slips (32 topics is ambitious)
- **Mitigation:** Start with MVP (1 topic), template-driven approach, outsource asset creation to freelancers

**Risk:** Educational quality concerns
- **Mitigation:** Teacher review board, pilot testing with kids aged 6-10, iterative refinement

### User Experience Risks
**Risk:** New structure confuses existing users
- **Mitigation:** Onboarding tutorial for island structure, progressive disclosure, in-app help

**Risk:** Leaderboard changes demotivate users (removing global total score)
- **Mitigation:** A/B testing, user feedback loops, keep global leaderboard as "Hall of Fame" option

---

## Timeline Summary

**Weeks 1-2:** Phase 1 (Foundation) - Island/Topic structure
**Weeks 3-4:** Phase 2 (Level Template) - Story hooks, micro-lessons, summaries
**Weeks 5-6:** Phase 3 (Progression) - XP, mastery, badges
**Weeks 7-8:** Phase 4 (Leaderboard) - Weekly leaderboard, classroom groups
**Weeks 9-16:** Phase 5 (Content) - Create content for all 32 topics

**MVP Demo (Week 4):** 1 complete topic (Shadow Detective, 8 levels) with full story → lesson → practice → challenge → summary flow

**Full World 1 Launch (Week 8):** 8 topics (64 levels) with XP, mastery tracking, badges, weekly leaderboard

**Full Platform Launch (Week 16):** All 4 worlds, 32 topics, 256 levels, complete curriculum mapping

---

## Recommended First Steps (Week 1)

1. **Day 1-2:** Create backend models (Island, Topic, UserIslandProgress) and run database migrations in dev environment
2. **Day 3-4:** Create frontend models (Island, Topic, IslandProgress) and repositories
3. **Day 5:** Create seed data files (`islands.json`, `topics.json`) for World 1
4. **Day 6-7:** Update WorldScreen to display 4 island cards instead of 20 level cards
5. **Day 8:** Create IslandScreen to display topics within an island
6. **Day 9-10:** Test migration script with production-like data, verify no data loss

By end of Week 1, you should be able to navigate: World → Island → Topic → (existing level structure)

This provides immediate visual proof-of-concept for the new hierarchical structure while maintaining existing level functionality.
