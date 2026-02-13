const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Island = sequelize.define('Island', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  code: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true,
    comment: 'Unique code for the island (e.g., "island_w1_physics")',
  },
  worldId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: 1,
      max: 4,
    },
    comment: 'World ID (1-4) that this island belongs to',
  },
  name: {
    type: DataTypes.STRING(100),
    allowNull: false,
    comment: 'Display name of the island (e.g., "Physics Island")',
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: true,
    comment: 'Description of what students will learn on this island',
  },
  topicCategory: {
    type: DataTypes.ENUM('physics', 'chemistry', 'math', 'nature'),
    allowNull: false,
    comment: 'Subject category of the island',
  },
  orderIndex: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: 1,
      max: 4,
    },
    comment: 'Display order within the world (1-4)',
  },
  iconUrl: {
    type: DataTypes.STRING(255),
    allowNull: true,
    comment: 'URL to the island icon/image',
  },
  unlockRequirements: {
    type: DataTypes.JSONB,
    allowNull: true,
    defaultValue: null,
    comment: 'JSON object defining unlock requirements (e.g., {previousIsland: "island_w1_math", minStars: 15})',
  },
  isActive: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
    allowNull: false,
    comment: 'Whether this island is active and visible to users',
  },
}, {
  tableName: 'islands',
  timestamps: true,
  indexes: [
    {
      unique: true,
      fields: ['code'],
    },
    {
      fields: ['worldId', 'orderIndex'],
    },
    {
      fields: ['topicCategory'],
    },
  ],
});

module.exports = Island;
