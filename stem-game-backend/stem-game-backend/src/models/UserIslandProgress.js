const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const UserIslandProgress = sequelize.define('UserIslandProgress', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  userId: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'users',
      key: 'id',
    },
    onDelete: 'CASCADE',
    comment: 'Foreign key to the user',
  },
  islandId: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'islands',
      key: 'id',
    },
    onDelete: 'CASCADE',
    comment: 'Foreign key to the island',
  },
  topicId: {
    type: DataTypes.UUID,
    allowNull: true,
    references: {
      model: 'topics',
      key: 'id',
    },
    onDelete: 'SET NULL',
    comment: 'Optional: Foreign key to a specific topic within the island',
  },
  totalXp: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0,
    validate: {
      min: 0,
    },
    comment: 'Total XP earned in this island/topic',
  },
  levelsCompleted: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0,
    validate: {
      min: 0,
    },
    comment: 'Number of levels completed in this island/topic',
  },
  totalLevels: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 8,
    validate: {
      min: 1,
    },
    comment: 'Total number of levels in this island/topic',
  },
  averageStars: {
    type: DataTypes.DECIMAL(3, 2),
    allowNull: false,
    defaultValue: 0.00,
    validate: {
      min: 0.00,
      max: 3.00,
    },
    comment: 'Average star rating across completed levels',
  },
  masteryColor: {
    type: DataTypes.ENUM('red', 'yellow', 'green'),
    allowNull: false,
    defaultValue: 'red',
    comment: 'Mastery level color indicator (red=started, yellow=practicing, green=mastered)',
  },
  topicBadgeEarned: {
    type: DataTypes.BOOLEAN,
    allowNull: false,
    defaultValue: false,
    comment: 'Whether the user has earned the topic badge',
  },
  badgeEarnedAt: {
    type: DataTypes.DATE,
    allowNull: true,
    comment: 'Timestamp when the topic badge was earned',
  },
}, {
  tableName: 'user_island_progress',
  timestamps: true,
  indexes: [
    {
      unique: true,
      fields: ['userId', 'islandId', 'topicId'],
      name: 'unique_user_island_topic',
    },
    {
      fields: ['userId'],
    },
    {
      fields: ['islandId'],
    },
    {
      fields: ['topicId'],
    },
    {
      fields: ['masteryColor'],
    },
  ],
});

module.exports = UserIslandProgress;
