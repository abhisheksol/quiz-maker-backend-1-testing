const pool = require('../config/db'); // PostgreSQL connection

// Create a new quiz
exports.createQuiz = async (title, description, timeLimit, startDate, endDate, createdBy, isActive) => {
    try {
        const result = await pool.query(
            'INSERT INTO quizzes (title, description, time_limit, start_date, end_date, created_by, is_active) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *',
            [title, description, timeLimit, startDate, endDate, createdBy, isActive]
        );
        return result.rows[0]; // Return the newly created quiz
    } catch (err) {
        throw new Error('Error creating quiz: ' + err.message);
    }
};

// Get all quizzes (Admin/User)
exports.getQuizzes = async () => {
    try {
        const result = await pool.query(
            'SELECT q.id, q.title, q.description, COUNT(que.id) AS questions_count, u.name AS created_by, q.is_active, q.start_date, q.end_date, q.time_limit FROM quizzes q LEFT JOIN questions que ON q.id = que.quiz_id JOIN users u ON q.created_by = u.id GROUP BY q.id, u.name'
        );
        return result.rows; // Return all quizzes
    } catch (err) {
        throw new Error('Error fetching quizzes: ' + err.message);
    }
};

// Get quiz details by quiz ID
exports.getQuizDetails = async (quizId) => {
    try {
        const result = await pool.query(
            'SELECT q.id AS quiz_id, q.title, q.description, que.id AS question_id, que.question_text, que.type, que.correct_answer, ARRAY_AGG(o.option_text) AS options FROM quizzes q JOIN questions que ON q.id = que.quiz_id LEFT JOIN options o ON que.id = o.question_id WHERE q.id = $1 GROUP BY q.id, que.id',
            [quizId]
        );
        return result.rows; // Return quiz details
    } catch (err) {
        throw new Error('Error fetching quiz details: ' + err.message);
    }
};

// Update quiz (only for admin)
exports.updateQuiz = async (id, title, description, timeLimit, startDate, endDate, isActive, adminId) => {
    try {
        const result = await pool.query(
            'UPDATE quizzes SET title = $1, description = $2, time_limit = $3, start_date = $4, end_date = $5, is_active = $6 WHERE id = $7 AND created_by = $8 RETURNING *',
            [title, description, timeLimit, startDate, endDate, isActive, id, adminId]
        );
        return result.rows[0]; // Return the updated quiz
    } catch (err) {
        throw new Error('Error updating quiz: ' + err.message);
    }
};

// Delete quiz (only for admin)
exports.deleteQuiz = async (id, adminId) => {
    try {
        const result = await pool.query(
            'DELETE FROM quizzes WHERE id = $1 AND created_by = $2 RETURNING *',
            [id, adminId]
        );
        return result.rows[0]; // Return the deleted quiz
    } catch (err) {
        throw new Error('Error deleting quiz: ' + err.message);
    }
};
