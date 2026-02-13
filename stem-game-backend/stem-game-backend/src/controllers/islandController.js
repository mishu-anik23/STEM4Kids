const { Island, Topic, Level, UserIslandProgress, LevelProgress, User } = require('../models');

/**
 * Get all islands for a specific world
 * GET /api/islands/:worldId
 */
exports.getWorldIslands = async (req, res) => {
  try {
    const { worldId } = req.params;
    const userId = req.userId; // From auth middleware

    // Validate worldId
    const worldIdNum = parseInt(worldId);
    if (isNaN(worldIdNum) || worldIdNum < 1 || worldIdNum > 4) {
      return res.status(400).json({
        success: false,
        message: 'Invalid world ID. Must be between 1 and 4.'
      });
    }

    // Get all islands for the world
    const islands = await Island.findAll({
      where: {
        worldId: worldIdNum,
        isActive: true
      },
      include: [
        {
          model: Topic,
          as: 'topics',
          attributes: ['id', 'code', 'name', 'description', 'orderIndex', 'iconUrl', 'difficultyLevel', 'levelCount']
        }
      ],
      order: [['orderIndex', 'ASC']]
    });

    // Get user's progress for these islands
    const islandIds = islands.map(island => island.id);
    const userProgress = userId ? await UserIslandProgress.findAll({
      where: {
        userId,
        islandId: islandIds
      }
    }) : [];

    // Create progress map
    const progressMap = {};
    userProgress.forEach(progress => {
      progressMap[progress.islandId] = progress;
    });

    // Check unlock status for each island
    const islandsWithUnlockStatus = islands.map(island => {
      const progress = progressMap[island.id];

      // Teachers and Parents have unrestricted access to all islands
      let isUnlocked;
      if (req.user && req.user.hasUnrestrictedAccess()) {
        isUnlocked = true;
      } else {
        isUnlocked = checkIslandUnlocked(island, islands, progressMap);
      }

      return {
        ...island.toJSON(),
        isUnlocked,
        userProgress: progress || null
      };
    });

    res.json({
      success: true,
      data: islandsWithUnlockStatus
    });
  } catch (error) {
    console.error('Error fetching world islands:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch islands',
      error: error.message
    });
  }
};

/**
 * Get all topics for a specific island
 * GET /api/islands/:islandId/topics
 */
exports.getIslandTopics = async (req, res) => {
  try {
    const { islandId } = req.params;
    const userId = req.userId; // From auth middleware

    // Get user to check their type
    const user = userId ? await User.findByPk(userId) : null;

    // Get island with topics
    const island = await Island.findByPk(islandId, {
      include: [
        {
          model: Topic,
          as: 'topics',
          order: [['orderIndex', 'ASC']]
        }
      ]
    });

    if (!island) {
      return res.status(404).json({
        success: false,
        message: 'Island not found'
      });
    }

    // Get user's progress for this island's topics
    const topicIds = island.topics.map(topic => topic.id);
    const userProgress = userId ? await UserIslandProgress.findAll({
      where: {
        userId,
        topicId: topicIds
      }
    }) : [];

    // Create progress map
    const progressMap = {};
    userProgress.forEach(progress => {
      progressMap[progress.topicId] = progress;
    });

    // Check if user has unrestricted access (teacher/parent)
    const hasUnrestrictedAccess = user && user.hasUnrestrictedAccess();

    // Add progress and unlock status to each topic
    const topicsWithProgress = island.topics.map((topic, index) => {
      const progress = progressMap[topic.id];

      // Determine if topic is unlocked
      let isUnlocked = false;

      if (hasUnrestrictedAccess) {
        // Teachers and parents have access to all topics
        isUnlocked = true;
      } else if (index === 0) {
        // First topic is always unlocked for students
        isUnlocked = true;
      } else {
        // Check if previous topic is completed
        const previousTopic = island.topics[index - 1];
        const previousProgress = progressMap[previousTopic.id];

        // Topic is unlocked if previous topic has all levels completed
        if (previousProgress && previousProgress.levelsCompleted >= previousTopic.levelCount) {
          isUnlocked = true;
        }
      }

      return {
        ...topic.toJSON(),
        isUnlocked,
        userProgress: progress || null
      };
    });

    res.json({
      success: true,
      data: {
        island: {
          id: island.id,
          code: island.code,
          worldId: island.worldId,
          name: island.name,
          description: island.description,
          topicCategory: island.topicCategory
        },
        topics: topicsWithProgress
      }
    });
  } catch (error) {
    console.error('Error fetching island topics:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch topics',
      error: error.message
    });
  }
};

/**
 * Get all levels for a specific topic with progress
 * GET /api/topics/:topicId/levels
 */
exports.getTopicLevels = async (req, res) => {
  try {
    const { topicId } = req.params;
    const userId = req.userId;

    // Get user to check their type
    const user = userId ? await User.findByPk(userId) : null;

    // Get topic with island
    const topic = await Topic.findByPk(topicId, {
      include: [
        {
          model: Island,
          as: 'island',
          attributes: ['id', 'worldId', 'name', 'code']
        },
        {
          model: Level,
          as: 'levels',
          order: [['levelNumber', 'ASC']],
          attributes: [
            'id', 'levelNumber', 'code', 'name', 'description',
            'challengeType', 'difficultyLevel', 'estimatedDurationMinutes',
            'maxStars', 'xpReward', 'coinsReward'
          ]
        }
      ]
    });

    if (!topic) {
      return res.status(404).json({
        success: false,
        message: 'Topic not found'
      });
    }

    // Check if topic is unlocked for this user
    const hasUnrestrictedAccess = user && user.hasUnrestrictedAccess();

    if (!hasUnrestrictedAccess && userId) {
      // For students, check if topic is unlocked
      const allTopics = await Topic.findAll({
        where: { islandId: topic.island.id },
        order: [['orderIndex', 'ASC']]
      });

      const topicIndex = allTopics.findIndex(t => t.id === topic.id);

      if (topicIndex > 0) {
        // Check if previous topic is completed
        const previousTopic = allTopics[topicIndex - 1];
        const previousProgress = await UserIslandProgress.findOne({
          where: {
            userId,
            topicId: previousTopic.id
          }
        });

        if (!previousProgress || previousProgress.levelsCompleted < previousTopic.levelCount) {
          return res.status(403).json({
            success: false,
            message: 'Previous topic must be completed first',
            requiredTopic: {
              id: previousTopic.id,
              name: previousTopic.name
            }
          });
        }
      }
    }

    // Get level progress for this user
    const levelProgressMap = {};
    if (userId) {
      const levelProgress = await LevelProgress.findAll({
        where: {
          userId,
          topicId
        }
      });

      levelProgress.forEach(progress => {
        levelProgressMap[progress.levelId] = progress;
      });
    }

    // Map levels with progress and unlock status
    const levelsWithProgress = topic.levels.map((level, index) => {
      const progress = levelProgressMap[level.levelNumber];

      // Determine if level is unlocked
      let isUnlocked = false;

      if (hasUnrestrictedAccess) {
        // Teachers and parents have access to all levels
        isUnlocked = true;
      } else if (index === 0) {
        // First level is always unlocked
        isUnlocked = true;
      } else {
        // Check if previous level is completed
        const previousLevel = topic.levels[index - 1];
        const previousProgress = levelProgressMap[previousLevel.levelNumber];

        if (previousProgress && previousProgress.completed) {
          isUnlocked = true;
        }
      }

      return {
        ...level.toJSON(),
        isUnlocked,
        userProgress: progress ? {
          completed: progress.completed,
          stars: progress.stars,
          score: progress.score,
          attempts: progress.attempts,
          timeSpentSeconds: progress.timeSpentSeconds,
          completedAt: progress.completedAt
        } : null
      };
    });

    res.json({
      success: true,
      data: {
        topic: {
          id: topic.id,
          code: topic.code,
          name: topic.name,
          description: topic.description,
          learningObjectives: topic.learningObjectives,
          island: topic.island
        },
        levels: levelsWithProgress
      }
    });
  } catch (error) {
    console.error('Error fetching topic levels:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch levels',
      error: error.message
    });
  }
};

/**
 * Get detailed level information for playing
 * GET /api/levels/:levelId
 */
exports.getLevelDetails = async (req, res) => {
  try {
    const { levelId } = req.params;
    const userId = req.userId;

    // Get user to check their type
    const user = userId ? await User.findByPk(userId) : null;

    // Get level with topic and island
    const level = await Level.findByPk(levelId, {
      include: [
        {
          model: Topic,
          as: 'topic',
          include: [
            {
              model: Island,
              as: 'island',
              attributes: ['id', 'worldId', 'name', 'code']
            }
          ]
        }
      ]
    });

    if (!level) {
      return res.status(404).json({
        success: false,
        message: 'Level not found'
      });
    }

    // Check if level is unlocked for this user
    const hasUnrestrictedAccess = user && user.hasUnrestrictedAccess();

    if (!hasUnrestrictedAccess && userId) {
      // For students, check if level is unlocked
      if (level.levelNumber > 1) {
        // Get previous level
        const previousLevel = await Level.findOne({
          where: {
            topicId: level.topicId,
            levelNumber: level.levelNumber - 1
          }
        });

        if (previousLevel) {
          // Check if previous level is completed
          const previousProgress = await LevelProgress.findOne({
            where: {
              userId,
              topicId: level.topicId,
              levelId: previousLevel.levelNumber
            }
          });

          if (!previousProgress || !previousProgress.completed) {
            return res.status(403).json({
              success: false,
              message: 'Previous level must be completed first',
              requiredLevel: {
                id: previousLevel.id,
                name: previousLevel.name,
                levelNumber: previousLevel.levelNumber
              }
            });
          }
        }
      }
    }

    // Get user's progress for this level
    let userProgress = null;
    if (userId) {
      userProgress = await LevelProgress.findOne({
        where: {
          userId,
          topicId: level.topicId,
          levelId: level.levelNumber
        }
      });
    }

    // Transform level data to match Flutter LevelData format
    // TODO: Update Flutter to use new challenge-based structure
    const transformedLevel = {
      levelId: level.levelNumber,  // Using levelNumber as int for compatibility
      worldId: level.topic.island.worldId,
      title: level.name,
      description: level.description || '',
      difficulty: level.difficultyLevel || 'beginner',
      theme: level.topic.name || 'general',
      mathType: level.challengeType || 'general',
      targetGrade: [1, 2],  // Default grades for now
      totalQuestions: 1,  // Placeholder
      passingScore: 70,  // Placeholder
      questions: [
        {
          id: '1',
          type: 'multipleChoice',
          questionText: level.storyText || 'Complete the challenge',
          correctAnswer: 'A',
          options: ['Option A', 'Option B', 'Option C'],
          explanation: level.lessonContent || '',
          hints: (level.hints || []).map((hint, index) => ({
            level: index + 1,
            text: hint,
            coinsRequired: 10 * (index + 1)
          }))
        }
      ]
    };

    res.json({
      success: true,
      data: transformedLevel,
      userProgress: userProgress ? {
        completed: userProgress.completed,
        stars: userProgress.stars,
        score: userProgress.score,
        attempts: userProgress.attempts,
        timeSpentSeconds: userProgress.timeSpentSeconds,
        completedAt: userProgress.completedAt,
        hintsUsed: userProgress.hintsUsed
      } : null
    });
  } catch (error) {
    console.error('Error fetching level details:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch level details',
      error: error.message
    });
  }
};

/**
 * Get user's progress across all islands
 * GET /api/progress/islands/:userId
 */
exports.getUserIslandProgress = async (req, res) => {
  try {
    const { userId } = req.params;

    // Verify user is requesting their own data or is admin
    if (req.userId !== userId && !req.isAdmin) {
      return res.status(403).json({
        success: false,
        message: 'Unauthorized to view this user\'s progress'
      });
    }

    // Get all user's island progress
    const progress = await UserIslandProgress.findAll({
      where: { userId },
      include: [
        {
          model: Island,
          as: 'island',
          attributes: ['id', 'code', 'name', 'worldId', 'topicCategory']
        },
        {
          model: Topic,
          as: 'topic',
          attributes: ['id', 'code', 'name']
        }
      ],
      order: [
        [{ model: Island, as: 'island' }, 'worldId', 'ASC'],
        [{ model: Island, as: 'island' }, 'orderIndex', 'ASC']
      ]
    });

    res.json({
      success: true,
      data: progress
    });
  } catch (error) {
    console.error('Error fetching user island progress:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch progress',
      error: error.message
    });
  }
};

/**
 * Helper function to check if island is unlocked
 */
function checkIslandUnlocked(island, allIslands, progressMap) {
  // If no unlock requirements, island is unlocked
  if (!island.unlockRequirements) {
    return true;
  }

  const { previousIsland, minStars } = island.unlockRequirements;

  // Check if previous island requirement is met
  if (previousIsland) {
    const prevIsland = allIslands.find(i => i.code === previousIsland);
    if (prevIsland) {
      const prevProgress = progressMap[prevIsland.id];
      if (!prevProgress) {
        return false; // Previous island not started
      }

      // Check if minimum stars requirement is met
      if (minStars && prevProgress.levelsCompleted > 0) {
        const avgStars = prevProgress.averageStars;
        const totalStarsEarned = avgStars * prevProgress.levelsCompleted;
        if (totalStarsEarned < minStars) {
          return false;
        }
      }
    }
  }

  return true;
}

module.exports = exports;
