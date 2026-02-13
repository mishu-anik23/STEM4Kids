/**
 * Migration: Create Levels Table
 *
 * This migration creates the levels table to store individual level definitions
 * for each topic in the island structure.
 */

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Create levels table
    await queryInterface.createTable('levels', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      topicId: {
        type: Sequelize.UUID,
        allowNull: false,
        field: 'topic_id',
        references: {
          model: 'topics',
          key: 'id',
        },
        onDelete: 'CASCADE',
      },
      levelNumber: {
        type: Sequelize.INTEGER,
        allowNull: false,
        field: 'level_number',
      },
      code: {
        type: Sequelize.STRING(100),
        allowNull: false,
        unique: true,
      },
      name: {
        type: Sequelize.STRING(150),
        allowNull: false,
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      challengeType: {
        type: Sequelize.ENUM(
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
        field: 'challenge_type',
      },
      difficultyLevel: {
        type: Sequelize.ENUM('easy', 'medium', 'hard'),
        allowNull: false,
        defaultValue: 'easy',
        field: 'difficulty_level',
      },
      estimatedDurationMinutes: {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 3,
        field: 'estimated_duration_minutes',
      },
      storyText: {
        type: Sequelize.TEXT,
        allowNull: true,
        field: 'story_text',
      },
      lessonContent: {
        type: Sequelize.TEXT,
        allowNull: true,
        field: 'lesson_content',
      },
      challengeConfig: {
        type: Sequelize.JSONB,
        allowNull: true,
        defaultValue: '{}',
        field: 'challenge_config',
      },
      hints: {
        type: Sequelize.JSONB,
        allowNull: true,
        defaultValue: '[]',
        field: 'hints',
      },
      successMessage: {
        type: Sequelize.STRING(255),
        allowNull: true,
        field: 'success_message',
      },
      maxStars: {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 3,
        field: 'max_stars',
      },
      xpReward: {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 10,
        field: 'xp_reward',
      },
      coinsReward: {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 5,
        field: 'coins_reward',
      },
      isActive: {
        type: Sequelize.BOOLEAN,
        defaultValue: true,
        allowNull: false,
        field: 'is_active',
      },
      createdAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW,
        field: 'created_at',
      },
      updatedAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW,
        field: 'updated_at',
      },
    });

    // Create indexes
    await queryInterface.addIndex('levels', ['code'], {
      unique: true,
      name: 'levels_code_unique',
    });

    await queryInterface.addIndex('levels', ['topic_id', 'level_number'], {
      name: 'levels_topic_level_idx',
    });

    await queryInterface.addIndex('levels', ['challenge_type'], {
      name: 'levels_challenge_type_idx',
    });

    await queryInterface.addIndex('levels', ['difficulty_level'], {
      name: 'levels_difficulty_idx',
    });

    console.log('✅ Created levels table with indexes');
  },

  down: async (queryInterface, Sequelize) => {
    // Drop indexes first
    await queryInterface.removeIndex('levels', 'levels_difficulty_idx');
    await queryInterface.removeIndex('levels', 'levels_challenge_type_idx');
    await queryInterface.removeIndex('levels', 'levels_topic_level_idx');
    await queryInterface.removeIndex('levels', 'levels_code_unique');

    // Drop the table
    await queryInterface.dropTable('levels');

    console.log('✅ Dropped levels table and indexes');
  },
};
