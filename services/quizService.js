const quizModel = require('../models/quizModel'); // Import quiz model

// Service to create a new quiz
exports.createQuiz = async (title, description, timeLimit, startDate, endDate, createdBy, isActive) => {
    try {
        // Call the model function to create a quiz
        const newQuiz = await quizModel.createQuiz(title, description, timeLimit, startDate, endDate, createdBy, isActive);
        return newQuiz; // Return the newly created quiz
    } catch (err) {
        throw new Error('Error in quiz creation: ' + err.message);
    }
};

// Service to get all quizzes
exports.getAllQuizzes = async () => {
    try {
        // Call the model function to fetch all quizzes
        const quizzes = await quizModel.getQuizzes();
        return quizzes; // Return the list of quizzes
    } catch (err) {
        throw new Error('Error in fetching quizzes: ' + err.message);
    }
};

// Service to get quiz details by quiz ID
exports.getQuizById = async (quizId) => {
    try {
        // Call the model function to get quiz details
        const quizDetails = await quizModel.getQuizDetails(quizId);
        return quizDetails; // Return the quiz details
    } catch (err) {
        throw new Error('Error in fetching quiz details: ' + err.message);
    }
};

// Service to update a quiz (only for admin)
exports.updateQuiz = async (id, title, description, timeLimit, startDate, endDate, isActive, adminId) => {
    try {
        // Call the model function to update the quiz
        const updatedQuiz = await quizModel.updateQuiz(id, title, description, timeLimit, startDate, endDate, isActive, adminId);
        return updatedQuiz; // Return the updated quiz
    } catch (err) {
        throw new Error('Error in updating quiz: ' + err.message);
    }
};

// Service to delete a quiz (only for admin)
exports.deleteQuiz = async (id, adminId) => {
    try {
        // Call the model function to delete the quiz
        const deletedQuiz = await quizModel.deleteQuiz(id, adminId);
        return deletedQuiz; // Return the deleted quiz info
    } catch (err) {
        throw new Error('Error in deleting quiz: ' + err.message);
    }
};
