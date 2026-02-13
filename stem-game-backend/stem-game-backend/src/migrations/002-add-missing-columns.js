/**
 * Migration: Add Missing Columns (Safe)
 *
 * This migration safely adds columns to existing tables,
 * checking if they exist first to avoid errors.
 */

module.exports = {
  up: async (queryInterface, Sequelize) => {
    const transaction = await queryInterface.sequelize.transaction();

    try {
      // Helper function to check if column exists
      const columnExists = async (tableName, columnName) => {
        const [results] = await queryInterface.sequelize.query(
          `SELECT column_name FROM information_schema.columns
           WHERE table_name='${tableName}' AND column_name='${columnName}';`,
          { transaction }
        );
        return results.length > 0;
      };

      // Add columns to users table if they don't exist
      if (!(await columnExists('users', 'total_xp'))) {
        await queryInterface.addColumn('users', 'total_xp', {
          type: Sequelize.INTEGER,
          allowNull: false,
          defaultValue: 0,
        }, { transaction });
        console.log('✓ Added total_xp to users');
      }

      if (!(await columnExists('users', 'weekly_stars'))) {
        await queryInterface.addColumn('users', 'weekly_stars', {
          type: Sequelize.INTEGER,
          allowNull: false,
          defaultValue: 0,
        }, { transaction });
        console.log('✓ Added weekly_stars to users');
      }

      if (!(await columnExists('users', 'weekly_stars_reset_at'))) {
        await queryInterface.addColumn('users', 'weekly_stars_reset_at', {
          type: Sequelize.DATE,
          allowNull: true,
        }, { transaction });
        console.log('✓ Added weekly_stars_reset_at to users');
      }

      if (!(await columnExists('users', 'current_island_id'))) {
        await queryInterface.addColumn('users', 'current_island_id', {
          type: Sequelize.UUID,
          allowNull: true,
          references: {
            model: 'islands',
            key: 'id',
          },
          onDelete: 'SET NULL',
        }, { transaction });
        console.log('✓ Added current_island_id to users');
      }

      // Add columns to level_progress table if they don't exist
      if (!(await columnExists('level_progress', 'island_id'))) {
        await queryInterface.addColumn('level_progress', 'island_id', {
          type: Sequelize.UUID,
          allowNull: true,
          references: {
            model: 'islands',
            key: 'id',
          },
          onDelete: 'SET NULL',
        }, { transaction });
        console.log('✓ Added island_id to level_progress');
      }

      if (!(await columnExists('level_progress', 'topic_id'))) {
        await queryInterface.addColumn('level_progress', 'topic_id', {
          type: Sequelize.UUID,
          allowNull: true,
          references: {
            model: 'topics',
            key: 'id',
          },
          onDelete: 'SET NULL',
        }, { transaction });
        console.log('✓ Added topic_id to level_progress');
      }

      if (!(await columnExists('level_progress', 'xp_earned'))) {
        await queryInterface.addColumn('level_progress', 'xp_earned', {
          type: Sequelize.INTEGER,
          allowNull: false,
          defaultValue: 0,
        }, { transaction });
        console.log('✓ Added xp_earned to level_progress');
      }

      if (!(await columnExists('level_progress', 'mastery_level'))) {
        // Create enum type if it doesn't exist
        await queryInterface.sequelize.query(
          `DO $$ BEGIN
            CREATE TYPE enum_level_progress_mastery_level AS ENUM('not_started', 'learning', 'practicing', 'mastered');
          EXCEPTION
            WHEN duplicate_object THEN null;
          END $$;`,
          { transaction }
        );

        await queryInterface.addColumn('level_progress', 'mastery_level', {
          type: Sequelize.ENUM('not_started', 'learning', 'practicing', 'mastered'),
          allowNull: false,
          defaultValue: 'not_started',
        }, { transaction });
        console.log('✓ Added mastery_level to level_progress');
      }

      if (!(await columnExists('level_progress', 'first_try_bonus'))) {
        await queryInterface.addColumn('level_progress', 'first_try_bonus', {
          type: Sequelize.BOOLEAN,
          allowNull: false,
          defaultValue: false,
        }, { transaction });
        console.log('✓ Added first_try_bonus to level_progress');
      }

      if (!(await columnExists('level_progress', 'no_hints_bonus'))) {
        await queryInterface.addColumn('level_progress', 'no_hints_bonus', {
          type: Sequelize.BOOLEAN,
          allowNull: false,
          defaultValue: false,
        }, { transaction });
        console.log('✓ Added no_hints_bonus to level_progress');
      }

      // Add indexes if they don't exist (PostgreSQL will skip if index exists)
      try {
        await queryInterface.addIndex('level_progress', ['island_id'], { transaction });
        console.log('✓ Added index on level_progress.island_id');
      } catch (e) {
        if (!e.message.includes('already exists')) throw e;
      }

      try {
        await queryInterface.addIndex('level_progress', ['topic_id'], { transaction });
        console.log('✓ Added index on level_progress.topic_id');
      } catch (e) {
        if (!e.message.includes('already exists')) throw e;
      }

      await transaction.commit();
      console.log('\n✓ All columns added successfully!');
    } catch (error) {
      await transaction.rollback();
      throw error;
    }
  },

  down: async (queryInterface, Sequelize) => {
    // Rollback is same as the original migration
    await queryInterface.removeIndex('level_progress', ['island_id']);
    await queryInterface.removeIndex('level_progress', ['topic_id']);

    await queryInterface.removeColumn('level_progress', 'island_id');
    await queryInterface.removeColumn('level_progress', 'topic_id');
    await queryInterface.removeColumn('level_progress', 'xp_earned');
    await queryInterface.removeColumn('level_progress', 'mastery_level');
    await queryInterface.removeColumn('level_progress', 'first_try_bonus');
    await queryInterface.removeColumn('level_progress', 'no_hints_bonus');

    await queryInterface.removeColumn('users', 'total_xp');
    await queryInterface.removeColumn('users', 'weekly_stars');
    await queryInterface.removeColumn('users', 'weekly_stars_reset_at');
    await queryInterface.removeColumn('users', 'current_island_id');
  }
};
