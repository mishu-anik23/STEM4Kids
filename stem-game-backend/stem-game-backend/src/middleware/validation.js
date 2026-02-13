const { body, validationResult } = require('express-validator');

// Validation error handler
const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      errors: errors.array().map(err => ({
        field: err.path,
        message: err.msg
      }))
    });
  }
  next();
};

// Registration validation rules
const registerValidation = [
  body('username')
    .trim()
    .isLength({ min: 3, max: 50 })
    .withMessage('Username must be 3-50 characters')
    .isAlphanumeric()
    .withMessage('Username can only contain letters and numbers'),
  
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters'),
  
  body('parentEmail')
    .isEmail()
    .normalizeEmail()
    .withMessage('Valid parent email is required'),

  body('age')
    .optional()
    .isInt({ min: 6, max: 10 })
    .withMessage('Age must be between 6 and 10'),

  body('grade')
    .optional()
    .isInt({ min: 1, max: 5 })
    .withMessage('Grade must be between 1 and 5'),

  body('userType')
    .optional()
    .isIn(['student', 'teacher', 'parent'])
    .withMessage('User type must be student, teacher, or parent')
];

// Login validation rules
const loginValidation = [
  body('username')
    .trim()
    .notEmpty()
    .withMessage('Username is required'),
  
  body('password')
    .notEmpty()
    .withMessage('Password is required')
];

// Level completion validation
const levelCompletionValidation = [
  body('worldId')
    .isInt({ min: 1, max: 4 })
    .withMessage('Invalid world ID'),
  
  body('levelId')
    .isInt({ min: 1, max: 20 })
    .withMessage('Invalid level ID'),
  
  body('score')
    .isInt({ min: 0, max: 100 })
    .withMessage('Score must be between 0 and 100'),
  
  body('timeSpentSeconds')
    .isInt({ min: 0 })
    .withMessage('Time spent must be positive'),
  
  body('hintsUsed')
    .optional()
    .isInt({ min: 0, max: 3 })
    .withMessage('Hints used must be between 0 and 3')
];

module.exports = {
  validate,
  registerValidation,
  loginValidation,
  levelCompletionValidation
};
