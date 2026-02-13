/**
 * Seed Script: Islands and Topics
 *
 * Populates the islands and topics tables with initial data.
 * Run: node src/seeds/seedIslandsAndTopics.js
 */

require('dotenv').config();
const fs = require('fs');
const path = require('path');
const { sequelize } = require('../config/database');
const { Island, Topic } = require('../models');

async function seedIslandsAndTopics() {
  try {
    console.log('Starting island and topic seeding...');

    // Test database connection
    await sequelize.authenticate();
    console.log('✅ Database connection established');

    // Read islands.json
    const islandsPath = path.join(__dirname, '../../../../stem-game-flutter/stem-game-flutter/assets/data/islands.json');
    const topicsPath = path.join(__dirname, '../../../../stem-game-flutter/stem-game-flutter/assets/data/topics.json');

    if (!fs.existsSync(islandsPath)) {
      throw new Error(`Islands file not found at: ${islandsPath}`);
    }

    if (!fs.existsSync(topicsPath)) {
      throw new Error(`Topics file not found at: ${topicsPath}`);
    }

    const islandsData = JSON.parse(fs.readFileSync(islandsPath, 'utf8'));
    const topicsData = JSON.parse(fs.readFileSync(topicsPath, 'utf8'));

    console.log(`Found ${islandsData.islands.length} islands and ${topicsData.topics.length} topics`);

    // Seed islands
    console.log('\nSeeding islands...');
    for (const islandData of islandsData.islands) {
      // Check if island already exists
      const existing = await Island.findOne({ where: { code: islandData.code } });

      if (existing) {
        console.log(`  ⏭️  Island "${islandData.name}" already exists, skipping...`);
        continue;
      }

      await Island.create({
        // Let Sequelize auto-generate UUID
        code: islandData.code,
        worldId: islandData.worldId,
        name: islandData.name,
        description: islandData.description,
        topicCategory: islandData.topicCategory,
        orderIndex: islandData.orderIndex,
        iconUrl: islandData.iconUrl,
        unlockRequirements: islandData.unlockRequirements,
        isActive: islandData.isActive,
      });

      console.log(`  ✓ Created island: ${islandData.name}`);
    }

    // Seed topics
    console.log('\nSeeding topics...');
    for (const topicData of topicsData.topics) {
      // Check if topic already exists
      const existing = await Topic.findOne({ where: { code: topicData.code } });

      if (existing) {
        console.log(`  ⏭️  Topic "${topicData.name}" already exists, skipping...`);
        continue;
      }

      // Find the island by the islandId from JSON (which is actually the island code in the JSON)
      const island = await Island.findOne({ where: { code: topicData.islandId } });

      if (!island) {
        console.log(`  ⚠️  Island not found for topic "${topicData.name}", skipping...`);
        continue;
      }

      await Topic.create({
        // Let Sequelize auto-generate UUID
        islandId: island.id, // Use the actual UUID from the database
        code: topicData.code,
        name: topicData.name,
        description: topicData.description,
        learningObjectives: topicData.learningObjectives,
        orderIndex: topicData.orderIndex,
        iconUrl: topicData.iconUrl,
        difficultyLevel: topicData.difficultyLevel,
        levelCount: topicData.levelCount,
      });

      console.log(`  ✓ Created topic: ${topicData.name}`);
    }

    console.log('\n✅ Seeding completed successfully!');
    console.log(`\nSummary:`);
    console.log(`  - Islands: ${islandsData.islands.length}`);
    console.log(`  - Topics: ${topicsData.topics.length}`);

    process.exit(0);
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    console.error('Error stack:', error.stack);
    process.exit(1);
  }
}

seedIslandsAndTopics();
