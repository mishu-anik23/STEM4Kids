const { sequelize } = require('../src/config/database');
const { User } = require('../src/models');
const bcrypt = require('bcryptjs');

async function seed() {
  try {
    console.log('Starting database seeding...');

    // Create test users
    const hashedPassword = await bcrypt.hash('test123', 10);

    const testUsers = [
      {
        username: 'teststudent',
        password: hashedPassword,
        parentEmail: 'parent@example.com',
        age: 8,
        grade: 3,
        avatarUrl: 'default_avatar.png',
        coins: 150,
        totalStars: 25,
        currentWorld: 2,
        currentLevel: 3,
        parentVerified: true,
        loginStreak: 5,
        isActive: true,
      },
      {
        username: 'student2',
        password: hashedPassword,
        parentEmail: 'parent2@example.com',
        age: 9,
        grade: 4,
        avatarUrl: 'default_avatar.png',
        coins: 200,
        totalStars: 35,
        currentWorld: 3,
        currentLevel: 1,
        parentVerified: true,
        loginStreak: 3,
        isActive: true,
      },
    ];

    for (const userData of testUsers) {
      const [user, created] = await User.findOrCreate({
        where: { username: userData.username },
        defaults: userData,
      });

      if (created) {
        console.log(`✅ Created test user: ${userData.username}`);
      } else {
        console.log(`ℹ️  Test user already exists: ${userData.username}`);
      }
    }

    // Seed achievements
    await require('./seeds/achievements')();

    console.log('✅ Database seeding completed successfully');
    process.exit(0);
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  }
}

seed();