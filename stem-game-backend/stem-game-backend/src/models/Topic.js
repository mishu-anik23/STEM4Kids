const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Topic = sequelize.define('Topic', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  islandId: {
    type: DataTypes.UUID,
    allowNull: false,
    references: {
      model: 'islands',
      key: 'id',
    },
    onDelete: 'CASCADE',
    comment: 'Foreign key to the island this topic belongs to',
  },
  code: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true,
    comment: 'Unique code for the topic (e.g., "topic_shadows")',
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false,
    comment: 'Display name of the topic (e.g., "Shadows & Light")',
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: 'Description of what students will learn in this topic',
  },
  learningObjectives: {
    type: DataTypes.JSONB,
    allowNull: true,
    defaultValue: [],
    comment: 'Array of learning objectives for this topic',
  },
  orderIndex: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: 1,
    },
    comment: 'Display order within the island',
  },
  iconUrl: {
    type: DataTypes.STRING(255),
    allowNull: true,
    comment: 'URL to the topic icon/image',
  },
  difficultyLevel: {
    type: DataTypes.ENUM('beginner', 'intermediate', 'advanced'),
    allowNull: false,
    defaultValue: 'beginner',
    comment: 'Difficulty level of the topic',
  },
  levelCount: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 8,
    validate: {
      min: 1,
    },
    comment: 'Number of levels in this topic',
  },
}, {
  tableName: 'topics',
  timestamps: true,
  indexes: [
    {
      unique: true,
      fields: ['code'],
    },
    {
      fields: ['islandId', 'orderIndex'],
    },
    {
      fields: ['difficultyLevel'],
    },
  ],
});

module.exports = Topic;
