const { Island, Topic, UserIslandProgress, LevelProgress } = require('../models');

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
      const isUnlocked = checkIslandUnlocked(island, islands, progressMap);

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

    // Add progress to each topic
    const topicsWithProgress = island.topics.map(topic => ({
      ...topic.toJSON(),
      userProgress: progressMap[topic.id] || null
    }));

    res.json({
      success: true,
      data: {
        island: {
          id: island.id,
          code: island.code,
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
 * Get all level IDs for a specific topic
 * GET /api/topics/:topicId/levels
 */
exports.getTopicLevels = async (req, res) => {
  try {
    const { topicId } = req.params;
    const userId = req.userId;

    // Get topic
    const topic = await Topic.findByPk(topicId, {
      include: [
        {
          model: Island,
          as: 'island',
          attributes: ['id', 'worldId', 'name']
        }
      ]
    });

    if (!topic) {
      return res.status(404).json({
        success: false,
        message: 'Topic not found'
      });
    }

    // Get level progress for this topic
    const levelProgress = userId ? await LevelProgress.findAll({
      where: {
        userId,
        topicId
      },
      order: [['levelId', 'ASC']]
    }) : [];

    // Generate level list (assuming 8 levels per topic by default)
    const levels = [];
    for (let i = 1; i <= topic.levelCount; i++) {
      const progress = levelProgress.find(lp => lp.levelId === i);
      levels.push({
        levelId: i,
        worldId: topic.island.worldId,
        topicId: topic.id,
        completed: progress?.completed || false,
        stars: progress?.stars || 0,
        score: progress?.score || 0,
        attempts: progress?.attempts || 0
      });
    }

    res.json({
      success: true,
      data: {
        topic: {
          id: topic.id,
          code: topic.code,
          name: topic.name,
          description: topic.description,
          island: topic.island
        },
        levels
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
