const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const bcrypt = require('bcryptjs');

const User = sequelize.define('User', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  username: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true,
    validate: {
      len: [3, 50],
      isAlphanumeric: true
    }
  },
  password: {
    type: DataTypes.STRING,
    allowNull: false,
    validate: {
      len: [6, 100]
    }
  },
  parentEmail: {
    type: DataTypes.STRING,
    allowNull: false,
    validate: {
      isEmail: true
    }
  },
  age: {
    type: DataTypes.INTEGER,
    allowNull: true,
    validate: {
      min: 6,
      max: 10,
      isValidAge(value) {
        // Only validate for student accounts
        const userType = this.userType || this.getDataValue('userType');
        if (userType === 'student' && (value === null || value === undefined)) {
          throw new Error('Age is required for student accounts');
        }
      }
    }
  },
  grade: {
    type: DataTypes.INTEGER,
    allowNull: true,
    validate: {
      min: 1,
      max: 5,
      isValidGrade(value) {
        // Only validate for student accounts
        const userType = this.userType || this.getDataValue('userType');
        if (userType === 'student' && (value === null || value === undefined)) {
          throw new Error('Grade is required for student accounts');
        }
      }
    }
  },
  avatarUrl: {
    type: DataTypes.STRING,
    defaultValue: 'default_avatar.png'
  },
  coins: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    validate: {
      min: 0
    }
  },
  totalStars: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    validate: {
      min: 0
    }
  },
  currentWorld: {
    type: DataTypes.INTEGER,
    defaultValue: 1,
    validate: {
      min: 1,
      max: 4
    }
  },
  currentLevel: {
    type: DataTypes.INTEGER,
    defaultValue: 1,
    validate: {
      min: 1,
      max: 20
    }
  },
  parentVerified: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  userType: {
    type: DataTypes.ENUM('student', 'teacher', 'parent'),
    allowNull: false,
    defaultValue: 'student',
    field: 'user_type',
    validate: {
      isIn: [['student', 'teacher', 'parent']]
    }
  },
  lastLoginAt: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  },
  loginStreak: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  isActive: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  // Phase 1: XP and Island Structure
  totalXp: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0,
    validate: {
      min: 0
    },
    comment: 'Total XP earned across all levels and topics'
  },
  weeklyStars: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0,
    validate: {
      min: 0
    },
    comment: 'Stars earned this week (resets every Monday)'
  },
  weeklyStarsResetAt: {
    type: DataTypes.DATE,
    allowNull: true,
    comment: 'Timestamp of last weekly stars reset (used for weekly leaderboard)'
  },
  currentIslandId: {
    type: DataTypes.UUID,
    allowNull: true,
    references: {
      model: 'islands',
      key: 'id'
    },
    onDelete: 'SET NULL',
    comment: 'Foreign key to the island user is currently on (nullable)'
  }
}, {
  tableName: 'users',
  hooks: {
    beforeCreate: async (user) => {
      if (user.password) {
        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(user.password, salt);
      }
    },
    beforeUpdate: async (user) => {
      if (user.changed('password')) {
        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(user.password, salt);
      }
    }
  }
});

// Instance method to compare password
User.prototype.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Instance method to update login streak
User.prototype.updateLoginStreak = async function() {
  const today = new Date();
  const lastLogin = new Date(this.lastLoginAt);

  const daysDiff = Math.floor((today - lastLogin) / (1000 * 60 * 60 * 24));

  if (daysDiff === 1) {
    // Consecutive day login
    this.loginStreak += 1;
  } else if (daysDiff > 1) {
    // Streak broken
    this.loginStreak = 1;
  }
  // If same day, don't change streak

  this.lastLoginAt = today;
  await this.save();

  return this.loginStreak;
};

// Helper methods for user type checking
User.prototype.isStudent = function() {
  return this.userType === 'student';
};

User.prototype.isTeacher = function() {
  return this.userType === 'teacher';
};

User.prototype.isParent = function() {
  return this.userType === 'parent';
};

User.prototype.hasUnrestrictedAccess = function() {
  return this.userType === 'teacher' || this.userType === 'parent';
};

module.exports = User;
