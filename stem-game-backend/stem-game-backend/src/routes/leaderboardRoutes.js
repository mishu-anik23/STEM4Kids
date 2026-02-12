const express = require('express');
const router = express.Router();
const leaderboardController = require('../controllers/leaderboardController');
const { optionalAuth, auth } = require('../middleware/auth');

/**
 * @route   GET /api/leaderboard/global
 * @desc    Get global leaderboard
 * @access  Public (but shows user rank if authenticated)
 */
router.get('/global', optionalAuth, leaderboardController.getGlobalLeaderboard);

/**
 * @route   GET /api/leaderboard/weekly
 * @desc    Get weekly leaderboard
 * @access  Public (but shows user rank if authenticated)
 */
router.get('/weekly', optionalAuth, leaderboardController.getWeeklyLeaderboard);

/**
 * @route   GET /api/leaderboard/grade/:grade
 * @desc    Get leaderboard by grade
 * @access  Public
 */
router.get('/grade/:grade', leaderboardController.getLeaderboardByGrade);

/**
 * @route   GET /api/leaderboard/me
 * @desc    Get current user's leaderboard position
 * @access  Private
 */
router.get('/me', auth, leaderboardController.getUserLeaderboardPosition);

module.exports = router;
