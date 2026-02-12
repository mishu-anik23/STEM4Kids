require('dotenv').config();
const Redis = require('ioredis');

const redisClient = new Redis({
  host: process.env.REDIS_HOST || 'localhost',
  port: process.env.REDIS_PORT || 6379,
  password: process.env.REDIS_PASSWORD || undefined,
  retryStrategy(times) {
    const delay = Math.min(times * 50, 2000);
    return delay;
  },
  maxRetriesPerRequest: 3
});

redisClient.on('connect', () => {
  console.log('✅ Redis client connected');
});

redisClient.on('error', (err) => {
  console.error('❌ Redis Client Error:', err);
});

// Helper functions for leaderboard
const leaderboardHelpers = {
  // Add or update user score
  async updateScore(userId, score, timeframe = 'global') {
    const key = `leaderboard:${timeframe}`;
    await redisClient.zadd(key, score, userId);
  },

  // Get top N players
  async getTopPlayers(n = 10, timeframe = 'global') {
    const key = `leaderboard:${timeframe}`;
    const results = await redisClient.zrevrange(key, 0, n - 1, 'WITHSCORES');
    
    const leaderboard = [];
    for (let i = 0; i < results.length; i += 2) {
      leaderboard.push({
        userId: results[i],
        score: parseInt(results[i + 1])
      });
    }
    return leaderboard;
  },

  // Get user rank
  async getUserRank(userId, timeframe = 'global') {
    const key = `leaderboard:${timeframe}`;
    const rank = await redisClient.zrevrank(key, userId);
    return rank !== null ? rank + 1 : null;
  },

  // Get user score
  async getUserScore(userId, timeframe = 'global') {
    const key = `leaderboard:${timeframe}`;
    const score = await redisClient.zscore(key, userId);
    return score ? parseInt(score) : 0;
  },

  // Reset weekly leaderboard (call via cron job)
  async resetWeeklyLeaderboard() {
    await redisClient.del('leaderboard:weekly');
    console.log('Weekly leaderboard reset');
  }
};

module.exports = { redisClient, leaderboardHelpers };
