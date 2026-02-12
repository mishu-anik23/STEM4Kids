const { User, LevelProgress, Achievement, UserAchievement } = require('../models');
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

    await transaction.commit();

    // Update leaderboard (async, don't wait)
    const user = await User.findByPk(userId);
    leaderboardHelpers.updateScore(userId, user.totalStars, 'global');
    leaderboardHelpers.updateScore(userId, user.totalStars, 'weekly');

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

module.exports = { ...exports, checkAndUnlockAchievements };
