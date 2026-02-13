require('dotenv').config();
const { sequelize } = require('../src/config/database');

async function createLevelsTable() {
  try {
    console.log('Creating levels table...');

    await sequelize.query(`
      CREATE TABLE IF NOT EXISTS levels (
        id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
        topic_id UUID NOT NULL REFERENCES topics(id) ON DELETE CASCADE,
        level_number INTEGER NOT NULL,
        code VARCHAR(100) NOT NULL UNIQUE,
        name VARCHAR(150) NOT NULL,
        description TEXT,
        challenge_type VARCHAR(50) NOT NULL CHECK (challenge_type IN (
          'tap_objects', 'sort_items', 'path_finding', 'puzzle',
          'memory_game', 'matching', 'sequencing', 'multiple_choice',
          'drag_drop', 'interactive_scene'
        )),
        difficulty_level VARCHAR(20) NOT NULL DEFAULT 'easy' CHECK (difficulty_level IN ('easy', 'medium', 'hard')),
        estimated_duration_minutes INTEGER NOT NULL DEFAULT 3,
        story_text TEXT,
        lesson_content TEXT,
        challenge_config JSONB DEFAULT '{}'::jsonb,
        hints JSONB DEFAULT '[]'::jsonb,
        success_message VARCHAR(255),
        max_stars INTEGER NOT NULL DEFAULT 3,
        xp_reward INTEGER NOT NULL DEFAULT 10,
        coins_reward INTEGER NOT NULL DEFAULT 5,
        is_active BOOLEAN NOT NULL DEFAULT true,
        created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
      );
    `);

    console.log('Creating indexes...');

    await sequelize.query(`
      CREATE INDEX IF NOT EXISTS levels_topic_level_idx ON levels(topic_id, level_number);
    `);

    await sequelize.query(`
      CREATE INDEX IF NOT EXISTS levels_challenge_type_idx ON levels(challenge_type);
    `);

    await sequelize.query(`
      CREATE INDEX IF NOT EXISTS levels_difficulty_idx ON levels(difficulty_level);
    `);

    console.log('✅ Levels table created successfully!');

  } catch (error) {
    console.error('❌ Error creating levels table:', error);
    throw error;
  } finally {
    await sequelize.close();
  }
}

if (require.main === module) {
  createLevelsTable()
    .then(() => {
      console.log('Done!');
      process.exit(0);
    })
    .catch((error) => {
      console.error('Fatal error:', error);
      process.exit(1);
    });
}

module.exports = createLevelsTable;
