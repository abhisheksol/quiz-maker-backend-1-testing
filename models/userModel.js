const bcrypt = require('bcryptjs'); // Import bcrypt for hashing passwords
const pool = require('../config/db'); // PostgreSQL connection

// Register a new user
exports.registerUser = async (name, email, password, role = 'user') => {
    try {
        // Hash the password before storing it
        const salt = await bcrypt.genSalt(10); // Generate salt
        const hashedPassword = await bcrypt.hash(password, salt); // Hash password

        const result = await pool.query(
            'INSERT INTO users (name, email, password, role) VALUES ($1, $2, $3, $4) RETURNING *',
            [name, email, hashedPassword, role] // Store hashed password
        );
        return result.rows[0]; // Return the newly created user
    } catch (err) {
        throw new Error('Error registering user: ' + err.message);
    }
};

// Check if user exists by email
exports.checkUserExists = async (email) => {
    try {
        const result = await pool.query(
            'SELECT * FROM users WHERE email = $1',
            [email]
        );
        return result.rows.length > 0; // Returns true if user exists, otherwise false
    } catch (err) {
        throw new Error('Error checking user existence: ' + err.message);
    }
};

// Get user by ID (for profile or other user info)
exports.getUserById = async (id) => {
    try {
        const result = await pool.query(
            'SELECT id, name, email, role FROM users WHERE id = $1',
            [id]
        );
        return result.rows[0]; // Return the user details
    } catch (err) {
        throw new Error('Error fetching user: ' + err.message);
    }
};

// Get user by email (for login validation)
exports.getUserByEmail = async (email) => {
    try {
        const result = await pool.query(
            'SELECT id, name, email, password, role FROM users WHERE email = $1',
            [email]
        );
        return result.rows[0]; // Return the user details (including password for validation)
    } catch (err) {
        throw new Error('Error fetching user by email: ' + err.message);
    }
};
