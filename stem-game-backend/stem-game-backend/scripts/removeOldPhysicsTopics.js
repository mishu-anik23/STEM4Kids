require('dotenv').config();
const { sequelize } = require('../src/config/database');
const { Topic } = require('../src/models');

async function removeOldPhysicsTopics() {
  try {
    console.log('Removing old Physics Island topics...\n');

    // Topics to remove (old ones)
    const oldTopicCodes = [
      'shadows_and_light',
      'push_and_pull'
    ];

    for (const code of oldTopicCodes) {
      const topic = await Topic.findOne({ where: { code } });

      if (topic) {
        console.log(`Found topic: ${topic.name} (${code})`);
        await topic.destroy();
        console.log(`✅ Deleted: ${topic.name}\n`);
      } else {
        console.log(`ℹ️  Topic not found: ${code}\n`);
      }
    }

    console.log('✅ Old topics removed successfully!');

  } catch (error) {
    console.error('❌ Error removing topics:', error);
    throw error;
  } finally {
    await sequelize.close();
  }
}

if (require.main === module) {
  removeOldPhysicsTopics()
    .then(() => {
      console.log('\nDone!');
      process.exit(0);
    })
    .catch((error) => {
      console.error('Fatal error:', error);
      process.exit(1);
    });
}

module.exports = removeOldPhysicsTopics;
