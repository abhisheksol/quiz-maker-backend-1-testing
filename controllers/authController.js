const bcrypt = require('bcryptjs'); // Import bcrypt for password hashing
const pool = require('../config/db'); // PostgreSQL connection
const userModel = require('../models/userModel'); // Import user model

// Login user
exports.loginUser = async (req, res) => {
    const { email, password } = req.body; // Get user credentials from request body

    try {
        // Check if user exists by email
        const user = await userModel.getUserByEmail(email);
        
        if (!user) {
            return res.status(400).json({ error: 'User not found' });
        }

        // Validate password using bcrypt
        const isMatch = await bcrypt.compare(password, user.password); // Compare the entered password with the hashed one

        if (!isMatch) {
            return res.status(400).json({ error: 'Invalid password' });
        }

        // Set session data after successful login
        req.session.userId = user.id;
        req.session.role = user.role;

        res.status(200).json({
            message: 'User logged in successfully',
            user: { id: user.id, name: user.name, email: user.email, role: user.role }, // Only return safe user data
        });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: 'Server error' });
    }
};

// Logout user (destroy session)
exports.logoutUser = (req, res) => {
    req.session.destroy((err) => {
        if (err) {
            return res.status(500).json({ error: 'Failed to logout' });
        }
        res.status(200).json({ message: 'Logged out successfully' });
    });
};

// Get current user's profile (only if logged in)
exports.getUserProfile = async (req, res) => {
    if (!req.session.userId) {
        return res.status(401).json({ error: 'Not authenticated' });
    }

    try {
        const user = await pool.query('SELECT id, name, email, role FROM users WHERE id = $1', [req.session.userId]);

        if (user.rows.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }

        res.status(200).json({
            message: 'User profile fetched successfully',
            user: user.rows[0],
        });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: 'Server error' });
    }
};
