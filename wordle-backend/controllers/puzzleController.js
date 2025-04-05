/******************************************************************************************************
 * File: puzzleController.js
 * 
 * Author: Emmanuel Taylor
 * Created: April 3, 2025
 * Modified: April 4, 2025
 * 
 * Description:
 *   - Contains controller logic for handling puzzle interactions like retrieving today's puzzle 
 *     and submitting user guesses.
 * 
 * Dependences:
 *   - User: For updating streak and last played date.
 *   - Game: For storing guesses and the puzzle state.
 *   - getWordOfTheDay: Generates the daily word puzzle.
 *   - getTodayDate, isYesterday: Utility functions for date logic
 ******************************************************************************************************/

const User = require("../models/User");
const Game = require("../models/Game");
const getWordOfTheDay = require("../utils/wordOfTheDay");
const { isYesterday } = require("../utils/dateHelpers");

/**
 * @route get /api/puzzle/today
 * 
 * Retrieves or initializes today's puzzle for the authenticated user.
 * Returns existing history and solved status.
 * 
 * @access Private (uses authMiddleware) 
 */
const getTodayPuzzle = async (req, res) => {
    const userId = req.userId;
    const date = new Date().toISOString().split("T")[0];

    try {
        let game = await Game.findOne({ userId, date });
        
        // If the user has not played today, create a new game record.
        if (!game) {
            game = await Game.create({ userId, date, guessHistory: [] });
        }

        res.json({ 
            date: game.date, 
            guesses: game.guessHistory.map(g => ({guess: g.word, feedback: g.feedback})), 
            isSolved: game.isSolved 
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Failed to Fetch Today's Puzzle" });
    }
};

/**
 * @route POST /api/puzzle/guess
 * 
 * Handles a user's guess submission. Evaluates feedback, track guesses, 
 * updates user statistics (streak, wins), and returns feedback and updated state.
 * 
 * @access Private (uses authMiddleware)
 */
const submitGuess = async (req, res) => {
    const userId = req.userId;
    const { guess } = req.body;
    const date = new Date().toISOString().split("T")[0];
    const word = getWordOfTheDay();
    const normalizedGuess = guess.toLowerCase();

    // Validate guess format.
    if (!normalizedGuess || normalizedGuess.length !== word.length) {
        return res.status(400).json({ error: "Invalid Guess" });
    }

    try {
        const user = await User.findById(userId);
        const game = await Game.findOne({ userId, date });
        if (!game) return res.status(400).json({ error: "Start the Puzzle First" });
        if (game.isSolved) return res.status(400).json({ error: "Puzzle Solved" });

        if (game.guessHistory.length >= 6) {
            return res.status(400).json({ error: "No More Attempts Left" });
        }

        // Generate feedback based on position and character match.
        const feedback = normalizedGuess.split("").map((letter, i) => {
            if (word[i] === letter) return "Correct";
            else if (word.includes(letter)) return "Misplaced";
            else return "Incorrect";
        });

        // Prevent duplicate guesses.
        if (game.guessHistory.some(g => g.word === normalizedGuess)) {
            return res.status(400).json({ error: "You Already Guessed This Word" });
        }

        // Record the new guess and feedback.
        game.guessHistory.push({word: normalizedGuess, feedback: feedback});

        if (game.guessHistory.length >= 6 && normalizedGuess !== word) {
            game.isFailed = true;
        }

        const isFinalGuess = game.guessHistory.length >= 6;

        // Handles correct guesses.
        if (normalizedGuess === word) {
            game.isSolved = true;
            user.gamesWon = (user.gamesWon || 0) + 1;
            user.gamesPlayed = (user.gamesPlayed || 0) + 1;

            if (user.lastPlayed === date) {
                // ...
            } else if (user.lastPlayed && isYesterday(user.lastPlayed)) {
                user.streak += 1;
            } else {
                user.streak = 1;
            }

            // Tracks the user's best streak.
            if (!user.bestStreak || user.streak > user.bestStreak) {
                user.bestStreak = user.streak;
            }

            user.lastPlayed = date;
            await user.save();
        }

        // Handles incorrect guesses.
        if (isFinalGuess && normalizedGuess !== word) {
            game.isFailed = true;
            user.gamesPlayed = (user.gamesPlayed || 0) + 1;
            user.streak = 0;
            user.lastPlayed = date;
            await user.save();
        }

        await game.save();

        res.json({ 
            normalizedGuess, 
            feedback, 
            isSolved: game.isSolved, 
            attempts: game.guessHistory.length, 
            correctWord: word,
            streak: game.isSolved ? user.streak : undefined,
            gamesPlayed: user.gamesPlayed,
            gamesWon: user.gamesWon,
            bestStreak: user.bestStreak,
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Guess Submission Failed" });
    }
};

module.exports = { getTodayPuzzle, submitGuess };