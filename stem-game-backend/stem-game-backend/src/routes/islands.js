const express = require('express');
const router = express.Router();
const islandController = require('../controllers/islandController');
const { auth } = require('../middleware/auth');

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

module.exports = router;
