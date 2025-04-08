/******************************************************************************************************
 * File: puzzleController.js
 * 
 * Author: Emmanuel Taylor
 * Created: April 3, 2025
 * Modified: April 7, 2025
 * 
 * Description:
 *   - Contains controller logic for handling puzzle interactions like retrieving today's puzzle 
 *     and submitting user guesses.
 * 
 * Dependences:
 *   - Game:            Mongoose model for puzzle sessions.
 *   - getWordOfTheDay: Returns today's word for the puzzle.
 *   - isYesterday:     Utility function for streak logic.
 *   - User:            Mongoose model for user data.
 ******************************************************************************************************/

const Game = require("../models/Game");
const User = require("../models/User");
const { getWordOfTheDay, words } = require("../utils/wordOfTheDay");
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
            console.log(`[PUZZLE] New Game Created For User ${userId} on ${date}`);
            game = await Game.create({ userId, date, guessHistory: [] });
        }

        res.json({ 
            date: game.date, 
            guesses: game.guessHistory.map(g => ({guess: g.word, feedback: g.feedback})), 
            isSolved: game.isSolved
        });
    } catch (err) {
        console.error(`[PUZZLE] Failed to Fetch Today's Puzzle for User ${userId}:`, err);
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
    const normalizedGuess = guess?.toLowerCase();

    // Validate guess format.
    if (!normalizedGuess || normalizedGuess.length !== word.length) {
        return res.status(400).json({ error: "Invalid Guess" });
    }

    // Validate whether the guess is a valid dictionary word.
    if (!words.includes(normalizedGuess)) {
        return res.status(400).json({ error: "Invalid Word" });
    }

    try {
        const user = await User.findById(userId);
        const game = await Game.findOne({ userId, date });

        // Enforce hard mode logic.
        if (user.hardMode && game.guessHistory.length > 0) {
            const lastGuess = game.guessHistory[game.guessHistory.length - 1];
            const lastWord = lastGuess.word;
            const feedback = lastGuess.feedback;

            for (let i = 0; i < feedback.length; i++) {
                const letter = lastWord[i];

                if (feedback[i] === 'Correct' && normalizedGuess[i] !== letter) {
                    return res.status(400).json({
                        error: `Hard Mode: You Must Reuse '${letter.toUpperCase()}' in position ${i + 1}`
                    });
                }

                if (feedback[i] === 'Misplaced' && !normalizedGuess.includes(letter)) {
                    return res.status(400).json({
                        error: `Hard Mode: You must reuse '${letter.toUpperCase()} somewhere in your guess`
                    });
                }
            }
        }

        if (!game) return res.status(400).json({ error: "Start the Puzzle First" });
        if (game.isSolved) return res.status(400).json({ error: "Puzzle Solved" });

        if (game.guessHistory.length >= 6) {
            return res.status(400).json({ error: "No More Attempts Left" });
        }

        // Prevent duplicate guesses.
        if (game.guessHistory.some(g => g.word === normalizedGuess)) {
            return res.status(400).json({ error: "You Already Guessed This Word" });
        }

        // Track letter counts in the correct word.
        const letterCounts = [];
        for (const letter of word) {
            letterCounts[letter] = (letterCounts[letter] || 0) + 1;
        }

        // First pass to identify correct letters.
        const feedback = Array(word.length).fill("Incorrect");
        for (let i = 0; i < word.length; i++) {
            if (normalizedGuess[i] === word[i]) {
                feedback[i] = "Correct";
                letterCounts[normalizedGuess[i]]--;
            }
        }

        // Second pass to identify misplaced letters.
        for (let i = 0; i < word.length; i++) {
            if (feedback[i] === "Correct") continue;
            const letter = normalizedGuess[i];
            if (letterCounts[letter] > 0) {
                feedback[i] = "Misplaced";
                letterCounts[letter]--;
            }
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

        console.log(`[GUESS] User ${userId} submitted guess: '${normalizedGuess}' with feedback: `, feedback);
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
        console.error(`[GUESS] Error Processing Guess for User ${userId}: `, err);
        res.status(500).json({ error: "Guess Submission Failed" });
    }
};

/**
 * @route GET /api/puzzle/calendar
 * 
 * Returns a list of dates where the user successfully completed the puzzle.
 * (Used for generating the streak calendar heatmap we use).
 * 
 * @access Private (Requires JWT Authentication)
 */
const getStreakCalendar = async (req, res) => {
    const userId = req.userId;

    try {
        const games = await Game.find({ userId, isSolved: true });
        const solvedDates = games.map(game => game.date);
        res.json({ streakDates: solvedDates });
    } catch (err) {
        console.error(`[CALENDAR] Failed to fetch streak dates for ${userId}: err`);
        res.status(500).json({ error: "Failed to fetch calendar data" });
    }
};

module.exports = { getTodayPuzzle, submitGuess, getStreakCalendar };