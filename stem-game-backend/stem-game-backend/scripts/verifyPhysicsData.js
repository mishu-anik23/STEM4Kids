require('dotenv').config();
const { sequelize } = require('../src/config/database');
const { Island, Topic, Level } = require('../src/models');

async function verifyData() {
  try {
    console.log('Verifying Physics Island data...\n');

    // Find Physics Island
    const island = await Island.findOne({
      where: { code: 'island_w1_physics' }
    });

    if (!island) {
      console.log('❌ Physics Island not found!');
      return;
    }

    console.log(`✅ Island found: ${island.name}`);
    console.log(`   World: ${island.worldId}, Order: ${island.orderIndex}\n`);

    // Find all topics for this island
    const topics = await Topic.findAll({
      where: { islandId: island.id },
      order: [['orderIndex', 'ASC']]
    });

    console.log(`📚 Topics: ${topics.length}\n`);

    let totalLevels = 0;

    for (const topic of topics) {
      const levels = await Level.findAll({
        where: { topicId: topic.id },
        order: [['levelNumber', 'ASC']]
      });

      totalLevels += levels.length;

      console.log(`${topic.orderIndex}. ${topic.name}`);
      console.log(`   Code: ${topic.code}`);
      console.log(`   Levels: ${levels.length}/${topic.levelCount}`);
      console.log(`   Difficulty: ${topic.difficultyLevel}`);

      if (levels.length > 0) {
        console.log(`   Level Types:`);
        const challengeTypes = [...new Set(levels.map(l => l.challengeType))];
        challengeTypes.forEach(type => {
          const count = levels.filter(l => l.challengeType === type).length;
          console.log(`     - ${type}: ${count}`);
        });
      }
      console.log('');
    }

    console.log(`\n📊 Summary:`);
    console.log(`   Island: ${island.name}`);
    console.log(`   Topics: ${topics.length}`);
    console.log(`   Total Levels: ${totalLevels}`);
    console.log(`   Expected Levels: ${topics.reduce((sum, t) => sum + t.levelCount, 0)}`);

    if (totalLevels === topics.reduce((sum, t) => sum + t.levelCount, 0)) {
      console.log(`\n✅ All levels created successfully!`);
    } else {
      console.log(`\n⚠️  Some levels may be missing!`);
    }

  } catch (error) {
    console.error('❌ Error verifying data:', error);
    throw error;
  } finally {
    await sequelize.close();
  }
}

if (require.main === module) {
  verifyData()
    .then(() => {
      console.log('\nDone!');
      process.exit(0);
    })
    .catch((error) => {
      console.error('Fatal error:', error);
      process.exit(1);
    });
}

module.exports = verifyData;
