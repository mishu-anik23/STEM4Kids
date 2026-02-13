module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Make age column nullable
    await queryInterface.changeColumn('users', 'age', {
      type: Sequelize.INTEGER,
      allowNull: true,
      validate: {
        min: 6,
        max: 10
      }
    });

    // Make grade column nullable
    await queryInterface.changeColumn('users', 'grade', {
      type: Sequelize.INTEGER,
      allowNull: true,
      validate: {
        min: 1,
        max: 5
      }
    });
  },

  down: async (queryInterface, Sequelize) => {
    // Revert age column to NOT NULL
    await queryInterface.changeColumn('users', 'age', {
      type: Sequelize.INTEGER,
      allowNull: false,
      validate: {
        min: 6,
        max: 10
      }
    });

    // Revert grade column to NOT NULL
    await queryInterface.changeColumn('users', 'grade', {
      type: Sequelize.INTEGER,
      allowNull: false,
      validate: {
        min: 1,
        max: 5
      }
    });
  }
};
