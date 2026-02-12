require('dotenv').config();
const jwt = require('jsonwebtoken');
const { User } = require('../models');
const { redisClient } = require('../config/redis');

// Generate JWT token
const generateToken = (userId) => {
  return jwt.sign(
    { id: userId },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRE || '7d' }
  );
};

// Generate refresh token
const generateRefreshToken = (userId) => {
  return jwt.sign(
    { id: userId },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: process.env.JWT_REFRESH_EXPIRE || '30d' }
  );
};

// Register new user
exports.register = async (req, res) => {
  try {
    const { username, password, parentEmail, age, grade } = req.body;

    // Check if username already exists
    const existingUser = await User.findOne({ where: { username } });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: 'Username already taken'
      });
    }

    // Create user
    const user = await User.create({
      username,
      password,
      parentEmail,
      age,
      grade
    });

    // Generate tokens
    const token = generateToken(user.id);
    const refreshToken = generateRefreshToken(user.id);

    // Store refresh token in Redis
    await redisClient.setex(
      `refresh_token:${user.id}`,
      30 * 24 * 60 * 60, // 30 days
      refreshToken
    );

    // Send verification email to parent (implement email service)
    // await sendParentVerificationEmail(parentEmail, user.username);

    res.status(201).json({
      success: true,
      message: 'User registered successfully. Verification email sent to parent.',
      data: {
        user: {
          id: user.id,
          username: user.username,
          age: user.age,
          grade: user.grade,
          coins: user.coins,
          totalStars: user.totalStars,
          currentWorld: user.currentWorld,
          currentLevel: user.currentLevel,
          avatarUrl: user.avatarUrl,
          parentVerified: user.parentVerified
        },
        token,
        refreshToken
      }
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating user account',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// Login user
exports.login = async (req, res) => {
  try {
    const { username, password } = req.body;

    // Find user
    const user = await User.findOne({ where: { username } });
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid username or password'
      });
    }

    // Check password
    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Invalid username or password'
      });
    }

    // Check if account is active
    if (!user.isActive) {
      return res.status(403).json({
        success: false,
        message: 'Account is inactive. Please contact support.'
      });
    }

    // Update login streak
    const streak = await user.updateLoginStreak();

    // Generate tokens
    const token = generateToken(user.id);
    const refreshToken = generateRefreshToken(user.id);

    // Store refresh token in Redis
    await redisClient.setex(
      `refresh_token:${user.id}`,
      30 * 24 * 60 * 60,
      refreshToken
    );

    res.json({
      success: true,
      message: 'Login successful',
      data: {
        user: {
          id: user.id,
          username: user.username,
          age: user.age,
          grade: user.grade,
          coins: user.coins,
          totalStars: user.totalStars,
          currentWorld: user.currentWorld,
          currentLevel: user.currentLevel,
          avatarUrl: user.avatarUrl,
          parentVerified: user.parentVerified,
          loginStreak: streak
        },
        token,
        refreshToken
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Error logging in',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// Refresh token
exports.refreshToken = async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({
        success: false,
        message: 'Refresh token required'
      });
    }

    // Verify refresh token
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);

    // Check if token exists in Redis
    const storedToken = await redisClient.get(`refresh_token:${decoded.id}`);
    if (storedToken !== refreshToken) {
      return res.status(401).json({
        success: false,
        message: 'Invalid refresh token'
      });
    }

    // Generate new tokens
    const newToken = generateToken(decoded.id);
    const newRefreshToken = generateRefreshToken(decoded.id);

    // Update refresh token in Redis
    await redisClient.setex(
      `refresh_token:${decoded.id}`,
      30 * 24 * 60 * 60,
      newRefreshToken
    );

    res.json({
      success: true,
      data: {
        token: newToken,
        refreshToken: newRefreshToken
      }
    });
  } catch (error) {
    res.status(401).json({
      success: false,
      message: 'Invalid or expired refresh token'
    });
  }
};

// Logout
exports.logout = async (req, res) => {
  try {
    // Remove refresh token from Redis
    await redisClient.del(`refresh_token:${req.userId}`);

    res.json({
      success: true,
      message: 'Logged out successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error logging out'
    });
  }
};

// Get current user
exports.getCurrentUser = async (req, res) => {
  try {
    const user = await User.findByPk(req.userId, {
      attributes: { exclude: ['password'] }
    });

    res.json({
      success: true,
      data: { user }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching user data'
    });
  }
};
