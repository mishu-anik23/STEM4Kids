const express = require('express');
const router = express.Router();
const islandController = require('../controllers/islandController');
const { protect } = require('../middleware/auth');

/**
 * @route   GET /api/islands/:worldId
 * @desc    Get all islands for a world
 * @access  Public (but enhanced with user data if authenticated)
 */
router.get('/:worldId', islandController.getWorldIslands);

/**
 * @route   GET /api/islands/:islandId/topics
 * @desc    Get all topics for an island
 * @access  Public (but enhanced with user data if authenticated)
 */
router.get('/:islandId/topics', islandController.getIslandTopics);

/**
 * @route   GET /api/topics/:topicId/levels
 * @desc    Get all levels for a topic
 * @access  Public (but enhanced with user data if authenticated)
 */
router.get('/topics/:topicId/levels', islandController.getTopicLevels);

/**
 * @route   GET /api/progress/islands/:userId
 * @desc    Get user's progress across all islands
 * @access  Private (requires authentication)
 */
router.get('/progress/islands/:userId', protect, islandController.getUserIslandProgress);

module.exports = router;
