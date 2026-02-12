const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const LevelProgress = sequelize.define('LevelProgress', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  userId: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'users',
      key: 'id'
    }
  },
  worldId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: 1,
      max: 4
    }
  },
  levelId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: 1,
      max: 20
    }
  },
  stars: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0,
    validate: {
      min: 0,
      max: 3
    }
  },
  score: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0,
    validate: {
      min: 0,
      max: 100
    }
  },
  attempts: {
    type: DataTypes.INTEGER,
    defaultValue: 1,
    validate: {
      min: 1
    }
  },
  timeSpentSeconds: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    validate: {
      min: 0
    }
  },
  hintsUsed: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    validate: {
      min: 0,
      max: 3
    }
  },
  completed: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  completedAt: {
    type: DataTypes.DATE,
    allowNull: true
  },
  coinsEarned: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  // Phase 1: Island/Topic Structure
  islandId: {
    type: DataTypes.UUID,
    allowNull: true,
    references: {
      model: 'islands',
      key: 'id'
    },
    onDelete: 'SET NULL',
    comment: 'Foreign key to the island (nullable for migration)'
  },
  topicId: {
    type: DataTypes.UUID,
    allowNull: true,
    references: {
      model: 'topics',
      key: 'id'
    },
    onDelete: 'SET NULL',
    comment: 'Foreign key to the topic (nullable for migration)'
  },
  xpEarned: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0,
    validate: {
      min: 0
    },
    comment: 'XP earned for completing this level'
  },
  masteryLevel: {
    type: DataTypes.ENUM('not_started', 'learning', 'practicing', 'mastered'),
    allowNull: false,
    defaultValue: 'not_started',
    comment: 'Mastery level for this specific level'
  },
  firstTryBonus: {
    type: DataTypes.BOOLEAN,
    allowNull: false,
    defaultValue: false,
    comment: 'Whether user completed on first attempt (bonus XP)'
  },
  noHintsBonus: {
    type: DataTypes.BOOLEAN,
    allowNull: false,
    defaultValue: false,
    comment: 'Whether user completed without using hints (bonus XP)'
  }
}, {
  tableName: 'level_progress',
  indexes: [
    {
      unique: true,
      fields: ['user_id', 'world_id', 'level_id']
    },
    {
      fields: ['user_id']
    },
    {
      fields: ['world_id', 'level_id']
    },
    {
      fields: ['island_id']
    },
    {
      fields: ['topic_id']
    }
  ]
});

module.exports = LevelProgress;
