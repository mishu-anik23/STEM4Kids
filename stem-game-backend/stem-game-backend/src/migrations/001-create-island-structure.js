/**
 * Migration: Create Island Structure (Phase 1)
 *
 * This migration creates the new island/topic hierarchy structure:
 * - Creates islands table
 * - Creates topics table
 * - Creates user_island_progress table
 * - Adds island/topic columns to existing tables (users, level_progress)
 */

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // 1. Create islands table
    await queryInterface.createTable('islands', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      code: {
        type: Sequelize.STRING(50),
        allowNull: false,
        unique: true,
      },
      worldId: {
        type: Sequelize.INTEGER,
        allowNull: false,
        field: 'world_id',
      },
      name: {
        type: Sequelize.STRING(100),
        allowNull: false,
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      topicCategory: {
        type: Sequelize.ENUM('physics', 'chemistry', 'math', 'nature'),
        allowNull: false,
        field: 'topic_category',
      },
      orderIndex: {
        type: Sequelize.INTEGER,
        allowNull: false,
        field: 'order_index',
      },
      iconUrl: {
        type: Sequelize.STRING(255),
        allowNull: true,
        field: 'icon_url',
      },
      unlockRequirements: {
        type: Sequelize.JSONB,
        allowNull: true,
        field: 'unlock_requirements',
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
        field: 'created_at',
      },
      updatedAt: {
        type: Sequelize.DATE,
        allowNull: false,
        field: 'updated_at',
      },
    });

    // Add indexes for islands
    await queryInterface.addIndex('islands', ['code'], { unique: true });
    await queryInterface.addIndex('islands', ['world_id', 'order_index']);
    await queryInterface.addIndex('islands', ['topic_category']);

    // 2. Create topics table
    await queryInterface.createTable('topics', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      islandId: {
        type: Sequelize.UUID,
        allowNull: false,
        field: 'island_id',
        references: {
          model: 'islands',
          key: 'id',
        },
        onDelete: 'CASCADE',
      },
      code: {
        type: Sequelize.STRING(50),
        allowNull: false,
        unique: true,
      },
      name: {
        type: Sequelize.STRING(100),
        allowNull: false,
      },
      description: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      learningObjectives: {
        type: Sequelize.JSONB,
        allowNull: true,
        defaultValue: [],
        field: 'learning_objectives',
      },
      orderIndex: {
        type: Sequelize.INTEGER,
        allowNull: false,
        field: 'order_index',
      },
      iconUrl: {
        type: Sequelize.STRING(255),
        allowNull: true,
        field: 'icon_url',
      },
      difficultyLevel: {
        type: Sequelize.ENUM('beginner', 'intermediate', 'advanced'),
        allowNull: false,
        defaultValue: 'beginner',
        field: 'difficulty_level',
      },
      levelCount: {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 8,
        field: 'level_count',
      },
      createdAt: {
        type: Sequelize.DATE,
        allowNull: false,
        field: 'created_at',
      },
      updatedAt: {
        type: Sequelize.DATE,
        allowNull: false,
        field: 'updated_at',
      },
    });

    // Add indexes for topics
    await queryInterface.addIndex('topics', ['code'], { unique: true });
    await queryInterface.addIndex('topics', ['island_id', 'order_index']);
    await queryInterface.addIndex('topics', ['difficulty_level']);

    // 3. Create user_island_progress table
    await queryInterface.createTable('user_island_progress', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      userId: {
        type: Sequelize.UUID,
        allowNull: false,
        field: 'user_id',
        references: {
          model: 'users',
          key: 'id',
        },
        onDelete: 'CASCADE',
      },
      islandId: {
        type: Sequelize.UUID,
        allowNull: false,
        field: 'island_id',
        references: {
          model: 'islands',
          key: 'id',
        },
        onDelete: 'CASCADE',
      },
      topicId: {
        type: Sequelize.UUID,
        allowNull: true,
        field: 'topic_id',
        references: {
          model: 'topics',
          key: 'id',
        },
        onDelete: 'SET NULL',
      },
      totalXp: {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 0,
        field: 'total_xp',
      },
      levelsCompleted: {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 0,
        field: 'levels_completed',
      },
      totalLevels: {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 8,
        field: 'total_levels',
      },
      averageStars: {
        type: Sequelize.DECIMAL(3, 2),
        allowNull: false,
        defaultValue: 0.00,
        field: 'average_stars',
      },
      masteryColor: {
        type: Sequelize.ENUM('red', 'yellow', 'green'),
        allowNull: false,
        defaultValue: 'red',
        field: 'mastery_color',
      },
      topicBadgeEarned: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
        field: 'topic_badge_earned',
      },
      badgeEarnedAt: {
        type: Sequelize.DATE,
        allowNull: true,
        field: 'badge_earned_at',
      },
      createdAt: {
        type: Sequelize.DATE,
        allowNull: false,
        field: 'created_at',
      },
      updatedAt: {
        type: Sequelize.DATE,
        allowNull: false,
        field: 'updated_at',
      },
    });

    // Add indexes for user_island_progress
    await queryInterface.addIndex('user_island_progress', ['user_id', 'island_id', 'topic_id'], {
      unique: true,
      name: 'unique_user_island_topic',
    });
    await queryInterface.addIndex('user_island_progress', ['user_id']);
    await queryInterface.addIndex('user_island_progress', ['island_id']);
    await queryInterface.addIndex('user_island_progress', ['topic_id']);
    await queryInterface.addIndex('user_island_progress', ['mastery_color']);

    // 4. Add new columns to users table
    await queryInterface.addColumn('users', 'total_xp', {
      type: Sequelize.INTEGER,
      allowNull: false,
      defaultValue: 0,
    });

    await queryInterface.addColumn('users', 'weekly_stars', {
      type: Sequelize.INTEGER,
      allowNull: false,
      defaultValue: 0,
    });

    await queryInterface.addColumn('users', 'weekly_stars_reset_at', {
      type: Sequelize.DATE,
      allowNull: true,
    });

    await queryInterface.addColumn('users', 'current_island_id', {
      type: Sequelize.UUID,
      allowNull: true,
      references: {
        model: 'islands',
        key: 'id',
      },
      onDelete: 'SET NULL',
    });

    // 5. Add new columns to level_progress table
    await queryInterface.addColumn('level_progress', 'island_id', {
      type: Sequelize.UUID,
      allowNull: true,
      references: {
        model: 'islands',
        key: 'id',
      },
      onDelete: 'SET NULL',
    });

    await queryInterface.addColumn('level_progress', 'topic_id', {
      type: Sequelize.UUID,
      allowNull: true,
      references: {
        model: 'topics',
        key: 'id',
      },
      onDelete: 'SET NULL',
    });

    await queryInterface.addColumn('level_progress', 'xp_earned', {
      type: Sequelize.INTEGER,
      allowNull: false,
      defaultValue: 0,
    });

    await queryInterface.addColumn('level_progress', 'mastery_level', {
      type: Sequelize.ENUM('not_started', 'learning', 'practicing', 'mastered'),
      allowNull: false,
      defaultValue: 'not_started',
    });

    await queryInterface.addColumn('level_progress', 'first_try_bonus', {
      type: Sequelize.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    });

    await queryInterface.addColumn('level_progress', 'no_hints_bonus', {
      type: Sequelize.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    });

    // Add indexes for level_progress new columns
    await queryInterface.addIndex('level_progress', ['island_id']);
    await queryInterface.addIndex('level_progress', ['topic_id']);
  },

  down: async (queryInterface, Sequelize) => {
    // Remove indexes from level_progress
    await queryInterface.removeIndex('level_progress', ['island_id']);
    await queryInterface.removeIndex('level_progress', ['topic_id']);

    // Remove new columns from level_progress
    await queryInterface.removeColumn('level_progress', 'island_id');
    await queryInterface.removeColumn('level_progress', 'topic_id');
    await queryInterface.removeColumn('level_progress', 'xp_earned');
    await queryInterface.removeColumn('level_progress', 'mastery_level');
    await queryInterface.removeColumn('level_progress', 'first_try_bonus');
    await queryInterface.removeColumn('level_progress', 'no_hints_bonus');

    // Remove new columns from users
    await queryInterface.removeColumn('users', 'total_xp');
    await queryInterface.removeColumn('users', 'weekly_stars');
    await queryInterface.removeColumn('users', 'weekly_stars_reset_at');
    await queryInterface.removeColumn('users', 'current_island_id');

    // Drop tables
    await queryInterface.dropTable('user_island_progress');
    await queryInterface.dropTable('topics');
    await queryInterface.dropTable('islands');

    // Drop ENUM types
    await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_topics_difficulty_level";');
    await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_islands_topic_category";');
    await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_user_island_progress_mastery_color";');
    await queryInterface.sequelize.query('DROP TYPE IF EXISTS "enum_level_progress_mastery_level";');
  }
};
