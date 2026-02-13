const express = require('express');
const router = express.Router();
const islandController = require('../controllers/islandController');

/**
 * @route   GET /api/topics/:topicId/levels
 * @desc    Get all levels for a topic
 * @access  Public (but enhanced with user data if authenticated)
 */
router.get('/:topicId/levels', islandController.getTopicLevels);

module.exports = router;
