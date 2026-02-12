const User = require('./User');
const LevelProgress = require('./LevelProgress');
const { Achievement, UserAchievement } = require('./Achievement');

// Define associations
User.hasMany(LevelProgress, {
  foreignKey: 'userId',
  as: 'progress'
});

LevelProgress.belongsTo(User, {
  foreignKey: 'userId',
  as: 'user'
});

User.belongsToMany(Achievement, {
  through: UserAchievement,
  foreignKey: 'userId',
  as: 'achievements'
});

Achievement.belongsToMany(User, {
  through: UserAchievement,
  foreignKey: 'achievementId',
  as: 'users'
});

UserAchievement.belongsTo(User, {
  foreignKey: 'userId',
  as: 'user'
});

UserAchievement.belongsTo(Achievement, {
  foreignKey: 'achievementId',
  as: 'achievement'
});

module.exports = {
  User,
  LevelProgress,
  Achievement,
  UserAchievement
};
