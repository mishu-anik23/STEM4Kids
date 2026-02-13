const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Level = sequelize.define('Level', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  topicId: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'topics',
      key: 'id',
    },
    onDelete: 'CASCADE',
    comment: 'Foreign key to the topic this level belongs to',
  },
  levelNumber: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: 1,
      max: 20,
    },
    comment: 'Level number within the topic (1-20)',
  },
  code: {
    type: DataTypes.STRING(100),
    allowNull: false,
    unique: true,
    comment: 'Unique code for the level (e.g., "level_p1_light_sources_1")',
  },
  name: {
    type: DataTypes.STRING(150),
    allowNull: false,
    comment: 'Display name of the level (e.g., "Tap the lights")',
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: 'Detailed description of what the level involves',
  },
  challengeType: {
    type: DataTypes.ENUM(
      'tap_objects',
      'sort_items',
      'path_finding',
      'puzzle',
      'memory_game',
      'matching',
      'sequencing',
      'multiple_choice',
      'drag_drop',
      'interactive_scene'
    ),
    allowNull: false,
    comment: 'Type of challenge/gameplay for this level',
  },
  difficultyLevel: {
    type: DataTypes.ENUM('easy', 'medium', 'hard'),
    allowNull: false,
    defaultValue: 'easy',
    comment: 'Difficulty level of this specific level',
  },
  estimatedDurationMinutes: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 3,
    validate: {
      min: 1,
      max: 10,
    },
    comment: 'Estimated time to complete in minutes',
  },
  storyText: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: 'Story/narrative text for the level introduction',
  },
  lessonContent: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: 'Micro-lesson content before the challenge',
  },
  challengeConfig: {
    type: DataTypes.JSONB,
    allowNull: true,
    defaultValue: {},
    comment: 'JSON configuration for the level challenge (objects to find, correct answers, etc.)',
  },
  hints: {
    type: DataTypes.JSONB,
    allowNull: true,
    defaultValue: [],
    comment: 'Array of hints available for this level',
  },
  successMessage: {
    type: DataTypes.STRING(255),
    allowNull: true,
    comment: 'Message shown when level is completed successfully',
  },
  maxStars: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 3,
    validate: {
      min: 1,
      max: 3,
    },
    comment: 'Maximum stars achievable (typically 3)',
  },
  xpReward: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 10,
    validate: {
      min: 1,
    },
    comment: 'Base XP reward for completing the level',
  },
  coinsReward: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 5,
    validate: {
      min: 0,
    },
    comment: 'Base coins reward for completing the level',
  },
  isActive: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
    allowNull: false,
    comment: 'Whether this level is active and available to users',
  },
}, {
  tableName: 'levels',
  timestamps: true,
  indexes: [
    {
      unique: true,
      fields: ['code'],
    },
    {
      fields: ['topicId', 'levelNumber'],
    },
    {
      fields: ['challengeType'],
    },
    {
      fields: ['difficultyLevel'],
    },
  ],
});

module.exports = Level;
