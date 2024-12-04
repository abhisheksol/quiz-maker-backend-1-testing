const pool = require('../config/db'); // PostgreSQL connection
const quizModel = require('../models/quizModel'); // Import quiz model

// Create a new quiz (only for admin)
exports.createQuiz = async (req, res) => {
    const { title, description, timeLimit, startDate, endDate } = req.body;
    const adminId = req.session.userId;

    if (!adminId) {
        return res.status(401).json({ error: 'Unauthorized: Admin login required' });
    }

    try {
        // Call the createQuiz function from the quiz model
        const newQuiz = await quizModel.createQuiz(title, description, timeLimit, startDate, endDate, adminId, true);
        
        res.status(201).json({
            message: 'Quiz created successfully',
            quiz: newQuiz,
        });
    } catch (err) {
        console.error(err.message);  // Log the error for debugging
        res.status(500).json({ error: 'Server error' });
    }
};

// Get all quizzes (Admin/User)
exports.getQuizzes = async (req, res) => {
    try {
        const result = await pool.query(
            'SELECT q.id, q.title, q.description, COUNT(que.id) AS questions_count, u.name AS created_by, q.is_active, q.start_date, q.end_date, q.time_limit ' +
            'FROM quizzes q ' +
            'LEFT JOIN questions que ON q.id = que.quiz_id ' +
            'JOIN users u ON q.created_by = u.id ' +
            'GROUP BY q.id, u.name'
        );

        res.status(200).json(result.rows);
    } catch (err) {
        console.error(err.message);  // Log the error for debugging
        res.status(500).json({ error: 'Server error' });
    }
};

// Get quiz details by quiz ID
exports.getQuizDetails = async (req, res) => {
    const { id } = req.params; // Get quiz ID from the URL

    try {
        const result = await pool.query(
            'SELECT q.id AS quiz_id, q.title, q.description, que.id AS question_id, que.question_text, que.type, que.correct_answer, ' +
            'ARRAY_AGG(o.option_text) AS options ' +
            'FROM quizzes q ' +
            'JOIN questions que ON q.id = que.quiz_id ' +
            'LEFT JOIN options o ON que.id = o.question_id ' +
            'WHERE q.id = $1 ' +
            'GROUP BY q.id, que.id',
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Quiz not found' });
        }

        res.status(200).json(result.rows);
    } catch (err) {
        console.error(err.message);  // Log the error for debugging
        res.status(500).json({ error: 'Server error' });
    }
};

// Update quiz (only for admin)
exports.updateQuiz = async (req, res) => {
    const { id } = req.params; // Get quiz ID from the URL
    const { title, description, timeLimit, startDate, endDate, isActive } = req.body; // Get new quiz data from the request body
    const adminId = req.session.userId; // Get the admin user ID from the session

    if (!adminId) {
        return res.status(401).json({ error: 'Unauthorized: Admin login required' });
    }

    try {
        const result = await pool.query(
            'UPDATE quizzes ' +
            'SET title = $1, description = $2, time_limit = $3, start_date = $4, end_date = $5, is_active = $6 ' +
            'WHERE id = $7 AND created_by = $8 ' +
            'RETURNING *',
            [title, description, timeLimit, startDate, endDate, isActive, id, adminId]
        );

        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Quiz not found or you are not authorized to edit this quiz' });
        }

        res.status(200).json({
            message: 'Quiz updated successfully',
            quiz: result.rows[0], // Return the updated quiz
        });
    } catch (err) {
        console.error(err.message);  // Log the error for debugging
        res.status(500).json({ error: 'Server error' });
    }
};

// Delete quiz (only for admin)
exports.deleteQuiz = async (req, res) => {
    const { id } = req.params; // Get quiz ID from the URL
    const adminId = req.session.userId; // Get the admin user ID from the session

    if (!adminId) {
        return res.status(401).json({ error: 'Unauthorized: Admin login required' });
    }

    try {
        const result = await pool.query(
            'DELETE FROM quizzes ' +
            'WHERE id = $1 AND created_by = $2 ' +
            'RETURNING *',
            [id, adminId]
        );

        if (result.rowCount === 0) {
            return res.status(404).json({ error: 'Quiz not found or you are not authorized to delete this quiz' });
        }

        res.status(200).json({
            message: 'Quiz deleted successfully',
        });
    } catch (err) {
        console.error(err.message);  // Log the error for debugging
        res.status(500).json({ error: 'Server error' });
    }
};

exports.addQuestionToQuiz = async (req, res) => {
    const { id } = req.params; // Quiz ID from the URL
    const { question_text, type, correct_answer, options } = req.body; // Question details from the request body

    if (!question_text || !type || !correct_answer || !options || options.length < 2) {
        return res.status(400).json({ error: 'All fields are required, and at least two options must be provided.' });
    }

    try {
        // Insert the question into the questions table
        const questionResult = await pool.query(
            'INSERT INTO questions (quiz_id, question_text, type, correct_answer) VALUES ($1, $2, $3, $4) RETURNING *',
            [id, question_text, type, correct_answer]
        );

        const questionId = questionResult.rows[0].id;

        // Insert the options into the options table
        const optionPromises = options.map((option) =>
            pool.query('INSERT INTO options (question_id, option_text) VALUES ($1, $2)', [questionId, option])
        );
        await Promise.all(optionPromises);

        res.status(201).json({
            message: 'Question added successfully',
            question: {
                id: questionId,
                quiz_id: id,
                question_text,
                type,
                correct_answer,
                options,
            },
        });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: 'Server error' });
    }
};


exports.submitQuiz = async (req, res) => {
    const { userId, quizId, answers } = req.body; // Get user ID, quiz ID, and answers from the request body
    
    console.log(userId);
    
    // Validate request data
    if (!userId || !quizId || !answers || answers.length === 0) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    try {
        // Fetch the correct answers for the quiz
        const quizQuestions = await pool.query(
            'SELECT id, correct_answer FROM questions WHERE quiz_id = $1',
            [quizId]
        );

        // Calculate the score
        let score = 0;
        for (let i = 0; i < answers.length; i++) {
            const question = quizQuestions.rows.find(q => q.id === answers[i].questionId);
            if (question && question.correct_answer === answers[i].answer) {
                score++; // Increment score if the answer is correct
            }
        }

        // Fetch the total number of questions for the quiz
        const totalQuestions = quizQuestions.rows.length;

        // Insert the result (score) into the submissions table
        const result = await pool.query(
            'INSERT INTO submissions (user_id, quiz_id, score, total_questions) VALUES ($1, $2, $3, $4) RETURNING *',
            [userId, quizId, score, totalQuestions]
        );

        res.status(201).json({
            message: 'Quiz submitted successfully!',
            score: result.rows[0].score,
            totalQuestions: totalQuestions,
            dateTaken: result.rows[0].date_taken,
        });
    } catch (err) {
        console.error(err.message);
        res.status(500).json({ error: 'Server error' });
    }
};
