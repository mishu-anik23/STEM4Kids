const express = require('express');
const router = express.Router();
const progressController = require('../controllers/progressController');
const { auth } = require('../middleware/auth');
const { levelCompletionValidation, validate } = require('../middleware/validation');

/**
 * @route   POST /api/progress/complete
 * @desc    Submit level completion
 * @access  Private
 */
router.post('/complete', auth, levelCompletionValidation, validate, progressController.submitLevelCompletion);

/**
 * @route   GET /api/progress
 * @desc    Get user's progress across all worlds
 * @access  Private
 */
router.get('/', auth, progressController.getUserProgress);

/**
 * @route   GET /api/progress/:worldId/:levelId
 * @desc    Get specific level progress
 * @access  Private
 */
router.get('/:worldId/:levelId', auth, progressController.getLevelProgress);

module.exports = router;
