const { User } = require('../models');
const { leaderboardHelpers } = require('../config/redis');
const { Op } = require('sequelize');

// Get global leaderboard
exports.getGlobalLeaderboard = async (req, res) => {
  try {
    const { limit = 100, offset = 0 } = req.query;
    const userId = req.userId;

    // Get top players from Redis
    const topPlayers = await leaderboardHelpers.getTopPlayers(parseInt(limit), 'global');

    // Fetch user details
    const userIds = topPlayers.map(p => p.userId);
    const users = await User.findAll({
      where: { id: { [Op.in]: userIds } },
      attributes: ['id', 'username', 'avatarUrl', 'totalStars', 'grade']
    });

    // Map users to leaderboard
    const leaderboard = topPlayers.map((player, index) => {
      const user = users.find(u => u.id === player.userId);
      return {
        rank: index + 1,
        userId: player.userId,
        username: user?.username || 'Unknown',
        avatarUrl: user?.avatarUrl || 'default_avatar.png',
        totalStars: player.score,
        grade: user?.grade
      };
    });

    // Get current user's rank
    let userRank = null;
    let userScore = null;
    if (userId) {
      userRank = await leaderboardHelpers.getUserRank(userId, 'global');
      userScore = await leaderboardHelpers.getUserScore(userId, 'global');
    }

    res.json({
      success: true,
      data: {
        leaderboard,
        userRank,
        userScore,
        total: leaderboard.length
      }
    });
  } catch (error) {
    console.error('Leaderboard error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching leaderboard'
    });
  }
};

// Get weekly leaderboard
exports.getWeeklyLeaderboard = async (req, res) => {
  try {
    const { limit = 100 } = req.query;
    const userId = req.userId;

    // Get top players from Redis (weekly)
    const topPlayers = await leaderboardHelpers.getTopPlayers(parseInt(limit), 'weekly');

    // Fetch user details
    const userIds = topPlayers.map(p => p.userId);
    const users = await User.findAll({
      where: { id: { [Op.in]: userIds } },
      attributes: ['id', 'username', 'avatarUrl', 'totalStars', 'grade']
    });

    // Map users to leaderboard
    const leaderboard = topPlayers.map((player, index) => {
      const user = users.find(u => u.id === player.userId);
      return {
        rank: index + 1,
        userId: player.userId,
        username: user?.username || 'Unknown',
        avatarUrl: user?.avatarUrl || 'default_avatar.png',
        weeklyStars: player.score,
        grade: user?.grade
      };
    });

    // Get current user's rank
    let userRank = null;
    let userScore = null;
    if (userId) {
      userRank = await leaderboardHelpers.getUserRank(userId, 'weekly');
      userScore = await leaderboardHelpers.getUserScore(userId, 'weekly');
    }

    res.json({
      success: true,
      data: {
        leaderboard,
        userRank,
        userScore,
        total: leaderboard.length,
        resetDate: getNextMonday()
      }
    });
  } catch (error) {
    console.error('Weekly leaderboard error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching weekly leaderboard'
    });
  }
};

// Get leaderboard by grade
exports.getLeaderboardByGrade = async (req, res) => {
  try {
    const { grade } = req.params;
    const { limit = 50 } = req.query;

    const users = await User.findAll({
      where: { grade: parseInt(grade), isActive: true },
      attributes: ['id', 'username', 'avatarUrl', 'totalStars', 'grade'],
      order: [['totalStars', 'DESC']],
      limit: parseInt(limit)
    });

    const leaderboard = users.map((user, index) => ({
      rank: index + 1,
      userId: user.id,
      username: user.username,
      avatarUrl: user.avatarUrl,
      totalStars: user.totalStars,
      grade: user.grade
    }));

    res.json({
      success: true,
      data: {
        grade: parseInt(grade),
        leaderboard,
        total: leaderboard.length
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching grade leaderboard'
    });
  }
};

// Get user's position in leaderboard
exports.getUserLeaderboardPosition = async (req, res) => {
  try {
    const userId = req.userId;

    const [globalRank, globalScore, weeklyRank, weeklyScore] = await Promise.all([
      leaderboardHelpers.getUserRank(userId, 'global'),
      leaderboardHelpers.getUserScore(userId, 'global'),
      leaderboardHelpers.getUserRank(userId, 'weekly'),
      leaderboardHelpers.getUserScore(userId, 'weekly')
    ]);

    const user = await User.findByPk(userId, {
      attributes: ['username', 'avatarUrl', 'totalStars', 'grade']
    });

    res.json({
      success: true,
      data: {
        global: {
          rank: globalRank,
          score: globalScore
        },
        weekly: {
          rank: weeklyRank,
          score: weeklyScore
        },
        user: {
          username: user.username,
          avatarUrl: user.avatarUrl,
          totalStars: user.totalStars,
          grade: user.grade
        }
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching user position'
    });
  }
};

// Helper to get next Monday for weekly reset
function getNextMonday() {
  const now = new Date();
  const dayOfWeek = now.getDay();
  const daysUntilMonday = dayOfWeek === 0 ? 1 : 8 - dayOfWeek;
  
  const nextMonday = new Date(now);
  nextMonday.setDate(now.getDate() + daysUntilMonday);
  nextMonday.setHours(0, 0, 0, 0);
  
  return nextMonday.toISOString();
}

module.exports = exports;
