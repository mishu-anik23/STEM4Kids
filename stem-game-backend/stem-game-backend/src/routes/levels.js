const express = require('express');
const router = express.Router();
const islandController = require('../controllers/islandController');

/**
 * @route   GET /api/levels/:levelId
 * @desc    Get detailed level information for playing
 * @access  Public (but enhanced with user data if authenticated)
 */
router.get('/:levelId', islandController.getLevelDetails);

module.exports = router;
