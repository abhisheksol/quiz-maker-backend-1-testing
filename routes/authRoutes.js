const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// Login user
router.post('/login', authController.loginUser);


// Logout user
router.post('/logout', authController.logoutUser);

// Get user profile (only if logged in)
router.get('/profile', authController.getUserProfile);

module.exports = router;
