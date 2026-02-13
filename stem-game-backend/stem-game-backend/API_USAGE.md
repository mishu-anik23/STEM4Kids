# Physics Island API Usage Guide

## Overview

The Physics Island now has 5 topics with sequential unlocking for students. Teachers and parents have unrestricted access to all content.

## ✅ Current Status

- **Island:** Physics Island (World 1)
- **Topics:** 5 topics (old 2 removed)
- **Levels:** 50 levels (10 per topic)
- **Progressive Unlocking:** ✅ Implemented for students
- **Unrestricted Access:** ✅ Teachers/Parents bypass locks

## 📡 API Endpoints

### 1. Get Island Topics
**Endpoint:** `GET /api/islands/:islandId/topics`

**Description:** Get all topics for an island with unlock status

**Response:**
```json
{
  "success": true,
  "data": {
    "island": {
      "id": "uuid",
      "code": "island_w1_physics",
      "name": "Physics Island",
      "description": "Explore the wonders of light, shadows, and forces!",
      "topicCategory": "physics"
    },
    "topics": [
      {
        "id": "uuid",
        "code": "topic_p1_light_sources",
        "name": "Light Sources",
        "description": "Identify and use natural vs artificial light sources.",
        "orderIndex": 1,
        "levelCount": 10,
        "difficultyLevel": "beginner",
        "isUnlocked": true,  // Always true for first topic
        "userProgress": {
          "levelsCompleted": 5,
          "averageStars": 2.5,
          ...
        }
      },
      {
        "id": "uuid",
        "code": "topic_p2_day_night",
        "name": "Day and Night",
        "orderIndex": 2,
        "levelCount": 10,
        "isUnlocked": false,  // Unlocked after completing topic 1
        "userProgress": null
      }
      // ... more topics
    ]
  }
}
```

**Unlock Logic:**
- **Students:**
  - Topic 1: Always unlocked
  - Topic 2+: Unlocked when previous topic has all 10 levels completed
- **Teachers/Parents:** All topics unlocked

---

### 2. Get Topic Levels
**Endpoint:** `GET /api/topics/:topicId/levels`

**Description:** Get all levels for a topic with unlock status

**Response:**
```json
{
  "success": true,
  "data": {
    "topic": {
      "id": "uuid",
      "code": "topic_p1_light_sources",
      "name": "Light Sources",
      "description": "Identify and use natural vs artificial light sources.",
      "learningObjectives": [
        "Identify different types of light sources",
        "Distinguish between objects that make light vs reflect light",
        ...
      ],
      "island": {
        "id": "uuid",
        "worldId": 1,
        "name": "Physics Island"
      }
    },
    "levels": [
      {
        "id": "uuid",
        "levelNumber": 1,
        "code": "topic_p1_light_sources_level_1",
        "name": "Tap the lights",
        "description": "Tap all objects that give light in a scene.",
        "challengeType": "tap_objects",
        "difficultyLevel": "easy",
        "estimatedDurationMinutes": 2,
        "maxStars": 3,
        "xpReward": 10,
        "coinsReward": 5,
        "isUnlocked": true,  // Always true for first level
        "userProgress": {
          "completed": true,
          "stars": 3,
          "score": 95,
          "attempts": 1,
          "timeSpentSeconds": 120,
          "completedAt": "2026-02-13T10:30:00Z"
        }
      },
      {
        "id": "uuid",
        "levelNumber": 2,
        "name": "Sort it",
        "challengeType": "sort_items",
        "isUnlocked": true,  // Unlocked after level 1 completion
        "userProgress": null
      }
      // ... 10 levels total
    ]
  }
}
```

**Unlock Logic:**
- **Students:**
  - Level 1: Always unlocked
  - Level 2+: Unlocked when previous level is completed
- **Teachers/Parents:** All levels unlocked

**Error Response (Locked Topic):**
```json
{
  "success": false,
  "message": "Previous topic must be completed first",
  "requiredTopic": {
    "id": "uuid",
    "name": "Light Sources"
  }
}
```

---

### 3. Get Level Details
**Endpoint:** `GET /api/levels/:levelId`

**Description:** Get full level details for playing (includes challenge config, story, lesson, hints)

**Response:**
```json
{
  "success": true,
  "data": {
    "level": {
      "id": "uuid",
      "topicId": "uuid",
      "levelNumber": 1,
      "code": "topic_p1_light_sources_level_1",
      "name": "Tap the lights",
      "description": "Tap all objects that give light in a scene.",
      "challengeType": "tap_objects",
      "difficultyLevel": "easy",
      "estimatedDurationMinutes": 2,
      "storyText": "Welcome to Light Land! Can you find all the things that make light?",
      "lessonContent": "Some things make their own light, like the Sun, lamps, and torches. Let's find them!",
      "challengeConfig": {
        "targetObjects": ["sun", "lamp", "torch", "candle", "lightbulb"],
        "distractorObjects": ["chair", "book", "table", "ball"],
        "minCorrect": 3
      },
      "hints": [
        "Look for things that glow or shine",
        "The Sun is a natural light source",
        "Lamps and torches need electricity or batteries"
      ],
      "successMessage": "Great job! You found all the light sources!",
      "maxStars": 3,
      "xpReward": 10,
      "coinsReward": 5,
      "topic": {
        "id": "uuid",
        "code": "topic_p1_light_sources",
        "name": "Light Sources"
      },
      "island": {
        "id": "uuid",
        "worldId": 1,
        "name": "Physics Island"
      }
    },
    "userProgress": {
      "completed": false,
      "stars": 0,
      "score": 0,
      "attempts": 0,
      "timeSpentSeconds": 0,
      "completedAt": null,
      "hintsUsed": 0
    }
  }
}
```

**Error Response (Locked Level):**
```json
{
  "success": false,
  "message": "Previous level must be completed first",
  "requiredLevel": {
    "id": "uuid",
    "name": "Tap the lights",
    "levelNumber": 1
  }
}
```

---

## 🎮 User Flow

### For Students

1. **Select Island** → Get topics
   - First topic unlocked automatically
   - Other topics show locked status

2. **Click Topic** → Get levels
   - If locked, show error message
   - If unlocked, see first level ready to play

3. **Click Level** → Get level details
   - If locked, show "complete previous level first"
   - If unlocked, show full level data to play

4. **Complete Level** → Update progress
   - Next level unlocks automatically
   - When all 10 levels done, next topic unlocks

5. **Repeat** for all 5 topics

### For Teachers/Parents

1. **Select Island** → Get topics
   - All 5 topics unlocked

2. **Click Any Topic** → Get levels
   - All 10 levels unlocked

3. **Click Any Level** → Get level details
   - Can access any level immediately

---

## 🔐 Access Control Summary

| User Type | Island Access | Topic Access | Level Access |
|-----------|---------------|--------------|--------------|
| **Student** | Unlocks by world progression | Sequential (complete previous) | Sequential (complete previous) |
| **Teacher** | All unlocked | All unlocked | All unlocked |
| **Parent** | All unlocked | All unlocked | All unlocked |

---

## 🎯 Challenge Types Available

1. **tap_objects** - Tap specific objects in a scene
2. **sort_items** - Categorize items into groups
3. **path_finding** - Navigate using specific tiles
4. **puzzle** - Solve spatial or logic puzzles
5. **memory_game** - Match pairs (memory card game)
6. **matching** - Match items to categories
7. **sequencing** - Put items in correct order
8. **multiple_choice** - Answer questions with options
9. **drag_drop** - Drag items to target locations
10. **interactive_scene** - Complex interactions in a scene

---

## 📊 Topic Structure

### Physics Island Topics (in order)

1. **Light Sources** (10 levels)
   - Code: `topic_p1_light_sources`
   - Focus: Natural vs artificial light

2. **Day and Night** (10 levels)
   - Code: `topic_p2_day_night`
   - Focus: Day/night patterns & activities

3. **Shadows** (10 levels)
   - Code: `topic_p3_shadows`
   - Focus: Shadow formation & properties

4. **Hot and Cold** (10 levels)
   - Code: `topic_p4_hot_cold`
   - Focus: Temperature & safety

5. **Push and Pull** (10 levels)
   - Code: `topic_p5_push_pull`
   - Focus: Basic forces

---

## 💡 Frontend Implementation Tips

### Display Topics
```javascript
// Fetch topics
const response = await fetch(`/api/islands/${islandId}/topics`);
const { topics } = response.data;

// Render each topic
topics.forEach(topic => {
  if (topic.isUnlocked) {
    // Show as clickable/active
    renderActiveTopicButton(topic);
  } else {
    // Show as locked/disabled
    renderLockedTopicButton(topic);
  }
});
```

### Display Levels
```javascript
// Fetch levels for selected topic
const response = await fetch(`/api/topics/${topicId}/levels`);
const { levels } = response.data;

// Render each level
levels.forEach(level => {
  if (level.isUnlocked) {
    // Show play button
    renderPlayableLevel(level);
  } else {
    // Show locked indicator
    renderLockedLevel(level);
  }

  // Show progress if exists
  if (level.userProgress?.completed) {
    showStars(level.userProgress.stars);
  }
});
```

### Play Level
```javascript
// Fetch full level details
const response = await fetch(`/api/levels/${levelId}`);
const { level, userProgress } = response.data;

// Render based on challenge type
switch (level.challengeType) {
  case 'tap_objects':
    renderTapObjectsChallenge(level.challengeConfig);
    break;
  case 'sort_items':
    renderSortItemsChallenge(level.challengeConfig);
    break;
  // ... other challenge types
}

// Show story, lesson, hints as needed
showStory(level.storyText);
showLesson(level.lessonContent);
```

---

## 🔄 Progress Tracking

When a user completes a level, update their progress via the progress API:
```
POST /api/progress/level
{
  "levelId": "uuid",
  "topicId": "uuid",
  "completed": true,
  "stars": 3,
  "score": 95,
  "timeSpent": 120,
  "hintsUsed": 0
}
```

This will:
- Mark the level as completed
- Unlock the next level
- Update topic progress
- When topic complete (10/10), unlock next topic

---

## 🧪 Testing the API

Use these example IDs (replace with actual UUIDs from your database):

```bash
# Get Physics Island topics
curl http://localhost:5000/api/islands/{physics-island-id}/topics

# Get Light Sources levels
curl http://localhost:5000/api/topics/{light-sources-topic-id}/levels

# Get first level details
curl http://localhost:5000/api/levels/{level-1-id}
```

---

**Last Updated:** February 13, 2026
**Status:** ✅ Production Ready
