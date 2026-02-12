const User = require('./User');
const LevelProgress = require('./LevelProgress');
const { Achievement, UserAchievement } = require('./Achievement');
const Island = require('./Island');
const Topic = require('./Topic');
const UserIslandProgress = require('./UserIslandProgress');

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

// Island associations
Island.hasMany(Topic, {
  foreignKey: 'islandId',
  as: 'topics',
  onDelete: 'CASCADE'
});

Topic.belongsTo(Island, {
  foreignKey: 'islandId',
  as: 'island'
});

// UserIslandProgress associations
User.hasMany(UserIslandProgress, {
  foreignKey: 'userId',
  as: 'islandProgress'
});

UserIslandProgress.belongsTo(User, {
  foreignKey: 'userId',
  as: 'user'
});

Island.hasMany(UserIslandProgress, {
  foreignKey: 'islandId',
  as: 'userProgress'
});

UserIslandProgress.belongsTo(Island, {
  foreignKey: 'islandId',
  as: 'island'
});

Topic.hasMany(UserIslandProgress, {
  foreignKey: 'topicId',
  as: 'userProgress'
});

UserIslandProgress.belongsTo(Topic, {
  foreignKey: 'topicId',
  as: 'topic'
});

// LevelProgress associations with Island/Topic
Island.hasMany(LevelProgress, {
  foreignKey: 'islandId',
  as: 'levelProgress'
});

LevelProgress.belongsTo(Island, {
  foreignKey: 'islandId',
  as: 'island'
});

Topic.hasMany(LevelProgress, {
  foreignKey: 'topicId',
  as: 'levelProgress'
});

LevelProgress.belongsTo(Topic, {
  foreignKey: 'topicId',
  as: 'topic'
});

// User association with current island
User.belongsTo(Island, {
  foreignKey: 'currentIslandId',
  as: 'currentIsland'
});

module.exports = {
  User,
  LevelProgress,
  Achievement,
  UserAchievement,
  Island,
  Topic,
  UserIslandProgress
};
