/**
 * Migration Runner Script
 *
 * Usage:
 *   node src/migrations/runMigration.js up   - Run migrations
 *   node src/migrations/runMigration.js down - Rollback migrations
 */

require('dotenv').config();
const { sequelize } = require('../config/database');

const migrations = [
  // require('./001-create-island-structure'), // Already partially applied
  require('./002-add-missing-columns'), // Safe migration with existence checks
];

async function runMigrations(direction = 'up') {
  try {
    console.log(`Running migrations (${direction})...`);

    // Test database connection
    await sequelize.authenticate();
    console.log('Database connection established successfully.');

    // Get Sequelize query interface
    const queryInterface = sequelize.getQueryInterface();

    if (direction === 'up') {
      // Run migrations forward
      for (const migration of migrations) {
        console.log(`\nApplying migration...`);
        await migration.up(queryInterface, sequelize.Sequelize);
        console.log('✓ Migration applied successfully');
      }
    } else if (direction === 'down') {
      // Rollback migrations in reverse order
      for (const migration of migrations.reverse()) {
        console.log(`\nRolling back migration...`);
        await migration.down(queryInterface, sequelize.Sequelize);
        console.log('✓ Migration rolled back successfully');
      }
    } else {
      console.error('Invalid direction. Use "up" or "down".');
      process.exit(1);
    }

    console.log('\n✓ All migrations completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('\n✗ Migration failed:', error);
    process.exit(1);
  }
}

// Get direction from command line arguments
const direction = process.argv[2] || 'up';
runMigrations(direction);
