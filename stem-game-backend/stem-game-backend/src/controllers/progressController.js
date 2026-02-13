const { User, LevelProgress, Achievement, UserAchievement, Island, Topic, UserIslandProgress } = require('../models');
const { leaderboardHelpers } = require('../config/redis');
const { sequelize } = require('../config/database');

// Calculate stars based on score
const calculateStars = (score) => {
  if (score >= 90) return 3;
  if (score >= 70) return 2;
  if (score >= 50) return 1;
  return 0;
};

// Calculate coins based on stars and hints
const calculateCoins = (stars, hintsUsed) => {
  const baseCoins = stars * 10; // 10, 20, or 30
  const hintPenalty = hintsUsed * 2; // -2 coins per hint
  return Math.max(0, baseCoins - hintPenalty);
};

// Submit level completion
exports.submitLevelCompletion = async (req, res) => {
  const transaction = await sequelize.transaction();
  
  try {
    const { worldId, levelId, score, timeSpentSeconds, hintsUsed = 0 } = req.body;
    const userId = req.userId;

    // Calculate stars and coins
    const stars = calculateStars(score);
    const coinsEarned = calculateCoins(stars, hintsUsed);

    if (stars === 0) {
      return res.status(400).json({
        success: false,
        message: 'Score too low to pass level. Try again!',
        data: { score, requiredScore: 50 }
      });
    }

    // Find or create progress record
    let progress = await LevelProgress.findOne({
      where: { userId, worldId, levelId }
    });

    let isNewCompletion = false;
    let previousStars = 0;

    if (progress) {
      previousStars = progress.stars;
      
      // Only update if new score is better
      if (stars > progress.stars || (stars === progress.stars && score > progress.score)) {
        const coinDifference = coinsEarned - progress.coinsEarned;
        
        await progress.update({
          stars,
          score,
          attempts: progress.attempts + 1,
          timeSpentSeconds: progress.timeSpentSeconds + timeSpentSeconds,
          hintsUsed: progress.hintsUsed + hintsUsed,
          completed: true,
          completedAt: new Date(),
          coinsEarned
        }, { transaction });

        // Update user stats
        const user = await User.findByPk(userId, { transaction });
        await user.update({
          coins: user.coins + coinDifference,
          totalStars: user.totalStars + (stars - previousStars)
        }, { transaction });
      } else {
        // Just increment attempts
        await progress.update({
          attempts: progress.attempts + 1
        }, { transaction });
      }
    } else {
      // New level completion
      isNewCompletion = true;
      
      progress = await LevelProgress.create({
        userId,
        worldId,
        levelId,
        stars,
        score,
        attempts: 1,
        timeSpentSeconds,
        hintsUsed,
        completed: true,
        completedAt: new Date(),
        coinsEarned
      }, { transaction });

      // Update user stats
      const user = await User.findByPk(userId, { transaction });
      await user.update({
        coins: user.coins + coinsEarned,
        totalStars: user.totalStars + stars,
        currentWorld: worldId,
        currentLevel: Math.min(levelId + 1, 20)
      }, { transaction });
    }

    // Update island progress and check world completion
    await updateIslandProgressAndWorldCompletion(userId, progress, transaction);

    await transaction.commit();

    // Update leaderboard (async, don't wait) - only for students
    const user = await User.findByPk(userId);
    if (user.userType === 'student') {
      leaderboardHelpers.updateScore(userId, user.totalStars, 'global');
      leaderboardHelpers.updateScore(userId, user.totalStars, 'weekly');
    }

    // Check for achievements (async)
    checkAndUnlockAchievements(userId);

    res.json({
      success: true,
      message: isNewCompletion ? 'Level completed!' : 'Score updated!',
      data: {
        progress,
        stars,
        coinsEarned,
        previousStars,
        isNewCompletion,
        totalCoins: user.coins,
        totalStars: user.totalStars
      }
    });
  } catch (error) {
    await transaction.rollback();
    console.error('Level completion error:', error);
    res.status(500).json({
      success: false,
      message: 'Error submitting level completion',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// Get user progress
exports.getUserProgress = async (req, res) => {
  try {
    const userId = req.userId;

    const progress = await LevelProgress.findAll({
      where: { userId },
      order: [['worldId', 'ASC'], ['levelId', 'ASC']]
    });

    // Group by world
    const progressByWorld = {
      1: [],
      2: [],
      3: [],
      4: []
    };

    progress.forEach(p => {
      progressByWorld[p.worldId].push(p);
    });

    // Calculate world completion stats
    const worldStats = {};
    for (let worldId = 1; worldId <= 4; worldId++) {
      const worldProgress = progressByWorld[worldId];
      const totalLevels = 20;
      const completedLevels = worldProgress.filter(p => p.completed).length;
      const totalStars = worldProgress.reduce((sum, p) => sum + p.stars, 0);
      const maxStars = totalLevels * 3;
      
      worldStats[worldId] = {
        completedLevels,
        totalLevels,
        completionPercentage: Math.round((completedLevels / totalLevels) * 100),
        totalStars,
        maxStars,
        starPercentage: Math.round((totalStars / maxStars) * 100)
      };
    }

    res.json({
      success: true,
      data: {
        progress: progressByWorld,
        worldStats
      }
    });
  } catch (error) {
    console.error('Get progress error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching progress'
    });
  }
};

// Get specific level progress
exports.getLevelProgress = async (req, res) => {
  try {
    const { worldId, levelId } = req.params;
    const userId = req.userId;

    const progress = await LevelProgress.findOne({
      where: { userId, worldId, levelId }
    });

    res.json({
      success: true,
      data: { progress }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching level progress'
    });
  }
};

// Helper function to check achievements
async function checkAndUnlockAchievements(userId) {
  try {
    const user = await User.findByPk(userId, {
      include: [
        { model: LevelProgress, as: 'progress' },
        { model: Achievement, as: 'achievements' }
      ]
    });

    const unlockedAchievementIds = user.achievements.map(a => a.id);

    // Get all active achievements
    const allAchievements = await Achievement.findAll({
      where: { isActive: true }
    });

    // Check each achievement
    for (const achievement of allAchievements) {
      // Skip if already unlocked
      if (unlockedAchievementIds.includes(achievement.id)) continue;

      let unlocked = false;

      // Check based on achievement type
      switch (achievement.code) {
        case 'QUICK_THINKER':
          // 5 levels in a row with 3 stars
          const recentProgress = user.progress.slice(-5);
          if (recentProgress.length === 5 && recentProgress.every(p => p.stars === 3)) {
            unlocked = true;
          }
          break;

        case 'PERSISTENT_LEARNER':
          // Retry same level 3 times and succeed
          const retriedLevel = user.progress.find(p => p.attempts >= 3 && p.completed);
          if (retriedLevel) unlocked = true;
          break;

        case 'MATH_MASTER':
          // Complete Math Island (World 1) with all 3 stars
          const mathProgress = user.progress.filter(p => p.worldId === 1);
          if (mathProgress.length === 20 && mathProgress.every(p => p.stars === 3)) {
            unlocked = true;
          }
          break;

        case 'DAILY_DEDICATED':
          // 7-day login streak
          if (user.loginStreak >= 7) unlocked = true;
          break;
      }

      // Unlock achievement
      if (unlocked) {
        await UserAchievement.create({
          userId: user.id,
          achievementId: achievement.id
        });

        // Award coins
        await user.update({
          coins: user.coins + achievement.coinReward
        });

        console.log(`Achievement unlocked: ${achievement.name} for user ${userId}`);
      }
    }
  } catch (error) {
    console.error('Achievement check error:', error);
  }
}

/**
 * Update island progress and check world completion
 * Called after level completion to update UserIslandProgress and check if user should advance worlds
 */
async function updateIslandProgressAndWorldCompletion(userId, levelProgress, transaction) {
  try {
    // Skip if level doesn't have topic/island association
    if (!levelProgress.topicId || !levelProgress.islandId) {
      return;
    }

    const topicId = levelProgress.topicId;
    const islandId = levelProgress.islandId;

    // Get the topic to know total level count
    const topic = await Topic.findByPk(topicId, {
      include: [{ model: Island, as: 'island' }],
      transaction
    });

    if (!topic) return;

    const worldId = topic.island.worldId;

    // Get all completed levels for this topic
    const topicLevels = await LevelProgress.findAll({
      where: {
        userId,
        topicId,
        completed: true
      },
      transaction
    });

    // Calculate topic progress stats
    const levelsCompleted = topicLevels.length;
    const totalLevels = topic.levelCount;
    const totalStars = topicLevels.reduce((sum, lp) => sum + lp.stars, 0);
    const averageStars = levelsCompleted > 0 ? totalStars / levelsCompleted : 0;
    const totalXp = topicLevels.reduce((sum, lp) => sum + lp.xpEarned, 0);

    // Determine mastery color based on completion and stars
    let masteryColor = 'red'; // Started
    if (levelsCompleted >= totalLevels) {
      masteryColor = averageStars >= 2.5 ? 'green' : 'yellow'; // Mastered vs Practicing
    } else if (levelsCompleted >= totalLevels * 0.5) {
      masteryColor = 'yellow'; // Practicing
    }

    const topicBadgeEarned = levelsCompleted >= totalLevels && averageStars >= 2.5;

    // Update or create UserIslandProgress for this topic
    const [topicProgress] = await UserIslandProgress.findOrCreate({
      where: {
        userId,
        islandId,
        topicId
      },
      defaults: {
        totalXp,
        levelsCompleted,
        totalLevels,
        averageStars,
        masteryColor,
        topicBadgeEarned,
        badgeEarnedAt: topicBadgeEarned ? new Date() : null
      },
      transaction
    });

    // Update if already exists
    if (!topicProgress._options.isNewRecord) {
      await topicProgress.update({
        totalXp,
        levelsCompleted,
        totalLevels,
        averageStars,
        masteryColor,
        topicBadgeEarned,
        badgeEarnedAt: topicBadgeEarned && !topicProgress.badgeEarnedAt ? new Date() : topicProgress.badgeEarnedAt
      }, { transaction });
    }

    // Now check island-level completion
    // Get all topics for this island
    const allTopics = await Topic.findAll({
      where: { islandId },
      transaction
    });

    // Get all topic progress for this island
    const allTopicProgress = await UserIslandProgress.findAll({
      where: {
        userId,
        islandId,
        topicId: allTopics.map(t => t.id)
      },
      transaction
    });

    // Calculate island-level stats
    const islandTotalLevels = allTopics.reduce((sum, t) => sum + t.levelCount, 0);
    const islandLevelsCompleted = allTopicProgress.reduce((sum, p) => sum + p.levelsCompleted, 0);
    const islandTotalXp = allTopicProgress.reduce((sum, p) => sum + p.totalXp, 0);
    const islandAverageStars = allTopicProgress.length > 0
      ? allTopicProgress.reduce((sum, p) => sum + (p.averageStars * p.levelsCompleted), 0) / islandLevelsCompleted
      : 0;

    // Check if island is complete (all topics have all levels completed)
    const islandComplete = allTopics.length > 0 && allTopicProgress.length === allTopics.length &&
      allTopicProgress.every(p => p.levelsCompleted >= p.totalLevels);

    // Update or create island-level progress (no topicId)
    const [islandProgress] = await UserIslandProgress.findOrCreate({
      where: {
        userId,
        islandId,
        topicId: null
      },
      defaults: {
        totalXp: islandTotalXp,
        levelsCompleted: islandLevelsCompleted,
        totalLevels: islandTotalLevels,
        averageStars: islandAverageStars,
        masteryColor: islandComplete ? (islandAverageStars >= 2.5 ? 'green' : 'yellow') : 'red',
        topicBadgeEarned: islandComplete && islandAverageStars >= 2.5,
        badgeEarnedAt: islandComplete && islandAverageStars >= 2.5 ? new Date() : null
      },
      transaction
    });

    if (!islandProgress._options.isNewRecord) {
      await islandProgress.update({
        totalXp: islandTotalXp,
        levelsCompleted: islandLevelsCompleted,
        totalLevels: islandTotalLevels,
        averageStars: islandAverageStars,
        masteryColor: islandComplete ? (islandAverageStars >= 2.5 ? 'green' : 'yellow') : 'red',
        topicBadgeEarned: islandComplete && islandAverageStars >= 2.5,
        badgeEarnedAt: islandComplete && islandAverageStars >= 2.5 && !islandProgress.badgeEarnedAt ? new Date() : islandProgress.badgeEarnedAt
      }, { transaction });
    }

    // Check world completion - if all islands in the world are completed
    if (islandComplete) {
      await checkAndUpdateWorldProgression(userId, worldId, transaction);
    }

  } catch (error) {
    console.error('Error updating island progress:', error);
    // Don't throw - this is a secondary operation
  }
}

/**
 * Check if all islands in a world are completed and update user.currentWorld
 */
async function checkAndUpdateWorldProgression(userId, completedWorldId, transaction) {
  try {
    // Get all islands for this world
    const worldIslands = await Island.findAll({
      where: {
        worldId: completedWorldId,
        isActive: true
      },
      transaction
    });

    // Each world should have 4 islands
    if (worldIslands.length !== 4) {
      console.warn(`World ${completedWorldId} doesn't have exactly 4 islands`);
      return;
    }

    // Get island-level progress for all islands in this world
    const islandProgress = await UserIslandProgress.findAll({
      where: {
        userId,
        islandId: worldIslands.map(i => i.id),
        topicId: null // Island-level progress only
      },
      transaction
    });

    // Check if all 4 islands are completed
    const allIslandsCompleted = islandProgress.length === 4 &&
      islandProgress.every(p => p.levelsCompleted >= p.totalLevels);

    if (allIslandsCompleted) {
      // Update user's currentWorld to the next world
      const user = await User.findByPk(userId, { transaction });
      const nextWorld = completedWorldId + 1;

      if (user.currentWorld < nextWorld && nextWorld <= 4) {
        await user.update({
          currentWorld: nextWorld
        }, { transaction });

        console.log(`✨ User ${userId} unlocked World ${nextWorld}! All islands in World ${completedWorldId} completed.`);
      }
    }
  } catch (error) {
    console.error('Error checking world progression:', error);
    // Don't throw - this is a secondary operation
  }
}

module.exports = { ...exports, checkAndUnlockAchievements, updateIslandProgressAndWorldCompletion };
