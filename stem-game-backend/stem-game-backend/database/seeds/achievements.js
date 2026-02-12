const { Achievement } = require('../../src/models');
const { sequelize } = require('../../src/config/database');

const achievements = [
  {
    code: 'QUICK_THINKER',
    name: 'Quick Thinker',
    description: 'Complete 5 levels in a row with perfect 3-star scores',
    iconUrl: 'achievements/quick_thinker.png',
    category: 'speed',
    coinReward: 100,
    requirement: {
      type: 'consecutive_perfect',
      count: 5
    }
  },
  {
    code: 'PERSISTENT_LEARNER',
    name: 'Persistent Learner',
    description: 'Try the same level 3 times and finally succeed',
    iconUrl: 'achievements/persistent.png',
    category: 'persistence',
    coinReward: 75,
    requirement: {
      type: 'retry_success',
      attempts: 3
    }
  },
  {
    code: 'MATH_MASTER',
    name: 'Math Master',
    description: 'Complete all of Math Island with perfect 3-star scores',
    iconUrl: 'achievements/math_master.png',
    category: 'mastery',
    coinReward: 500,
    requirement: {
      type: 'world_perfect',
      worldId: 1
    }
  },
  {
    code: 'PHYSICS_PRO',
    name: 'Physics Pro',
    description: 'Complete all of Physics Planet with perfect 3-star scores',
    iconUrl: 'achievements/physics_pro.png',
    category: 'mastery',
    coinReward: 500,
    requirement: {
      type: 'world_perfect',
      worldId: 2
    }
  },
  {
    code: 'CHEMISTRY_CHAMPION',
    name: 'Chemistry Champion',
    description: 'Complete all of Chemistry Kingdom with perfect 3-star scores',
    iconUrl: 'achievements/chemistry_champion.png',
    category: 'mastery',
    coinReward: 500,
    requirement: {
      type: 'world_perfect',
      worldId: 3
    }
  },
  {
    code: 'NATURE_NAVIGATOR',
    name: 'Nature Navigator',
    description: 'Complete all of Nature Realm with perfect 3-star scores',
    iconUrl: 'achievements/nature_navigator.png',
    category: 'mastery',
    coinReward: 500,
    requirement: {
      type: 'world_perfect',
      worldId: 4
    }
  },
  {
    code: 'DAILY_DEDICATED',
    name: 'Daily Dedicated',
    description: 'Log in and play for 7 days in a row',
    iconUrl: 'achievements/daily_dedicated.png',
    category: 'streak',
    coinReward: 150,
    requirement: {
      type: 'login_streak',
      days: 7
    }
  },
  {
    code: 'WEEKLY_WARRIOR',
    name: 'Weekly Warrior',
    description: 'Maintain a 14-day login streak',
    iconUrl: 'achievements/weekly_warrior.png',
    category: 'streak',
    coinReward: 300,
    requirement: {
      type: 'login_streak',
      days: 14
    }
  },
  {
    code: 'SCIENCE_SUPERSTAR',
    name: 'Science Superstar',
    description: 'Complete all 4 worlds with perfect 3-star scores',
    iconUrl: 'achievements/superstar.png',
    category: 'completion',
    coinReward: 1000,
    requirement: {
      type: 'all_worlds_perfect',
      totalStars: 240
    }
  },
  {
    code: 'HELPING_HAND',
    name: 'Helping Hand',
    description: 'Complete 10 levels without using any hints',
    iconUrl: 'achievements/no_hints.png',
    category: 'mastery',
    coinReward: 200,
    requirement: {
      type: 'no_hints',
      count: 10
    }
  },
  {
    code: 'STAR_COLLECTOR',
    name: 'Star Collector',
    description: 'Earn 50 total stars',
    iconUrl: 'achievements/star_50.png',
    category: 'completion',
    coinReward: 100,
    requirement: {
      type: 'total_stars',
      count: 50
    }
  },
  {
    code: 'STAR_CHAMPION',
    name: 'Star Champion',
    description: 'Earn 100 total stars',
    iconUrl: 'achievements/star_100.png',
    category: 'completion',
    coinReward: 250,
    requirement: {
      type: 'total_stars',
      count: 100
    }
  },
  {
    code: 'EXPLORER',
    name: 'Explorer',
    description: 'Try at least one level in each world',
    iconUrl: 'achievements/explorer.png',
    category: 'exploration',
    coinReward: 50,
    requirement: {
      type: 'try_all_worlds',
      worlds: [1, 2, 3, 4]
    }
  },
  {
    code: 'SPEED_DEMON',
    name: 'Speed Demon',
    description: 'Complete a level in under 30 seconds with 3 stars',
    iconUrl: 'achievements/speed.png',
    category: 'speed',
    coinReward: 150,
    requirement: {
      type: 'fast_completion',
      seconds: 30,
      stars: 3
    }
  },
  {
    code: 'FIRST_STEPS',
    name: 'First Steps',
    description: 'Complete your very first level',
    iconUrl: 'achievements/first_level.png',
    category: 'completion',
    coinReward: 25,
    requirement: {
      type: 'complete_levels',
      count: 1
    }
  }
];

async function seedAchievements() {
  try {
    console.log('Seeding achievements...');

    for (const achievement of achievements) {
      await Achievement.findOrCreate({
        where: { code: achievement.code },
        defaults: achievement
      });
    }

    console.log(`✅ Successfully seeded ${achievements.length} achievements`);
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    throw error;
  }
}

module.exports = seedAchievements;
