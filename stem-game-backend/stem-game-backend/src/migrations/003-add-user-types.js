module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Create ENUM type for user types
    await queryInterface.sequelize.query(`
      CREATE TYPE "enum_users_user_type" AS ENUM ('student', 'teacher', 'parent');
    `);

    // Add userType column with default 'student'
    await queryInterface.addColumn('users', 'user_type', {
      type: Sequelize.ENUM('student', 'teacher', 'parent'),
      allowNull: false,
      defaultValue: 'student'
    });

    // Add index for performance on userType queries
    await queryInterface.addIndex('users', ['user_type'], {
      name: 'users_user_type_idx'
    });

    // Update existing users to have 'student' type (for safety)
    await queryInterface.sequelize.query(`
      UPDATE users SET user_type = 'student' WHERE user_type IS NULL;
    `);
  },

  down: async (queryInterface) => {
    // Remove index
    await queryInterface.removeIndex('users', 'users_user_type_idx');

    // Remove column
    await queryInterface.removeColumn('users', 'user_type');

    // Drop ENUM type
    await queryInterface.sequelize.query('DROP TYPE "enum_users_user_type";');
  }
};
