const User = require("../models/User");
const Game = require("../models/Game");
const getWordOfTheDay = require("../utils/wordOfTheDay");
const { getTodayDate, isYesterday } = require("../utils/dateHelpers");
const date = getTodayDate();

const getTodayPuzzle = async (req, res) => {
    const userId = req.userId;
    const date = new Date().toISOString().split("T")[0];

    try {
        let game = await Game.findOne({ userId, date });
        
        if (!game) {
            game = await Game.create({ userId, date, guessHistory: [] });
        }

        res.json({ date, guesses: game.guessHistory, isSolved: game.isSolved });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Failed to Fetch Today's Puzzle" });
    }
};

const submitGuess = async (req, res) => {
    const userId = req.userId;
    const { guess } = req.body;
    const date = new Date().toISOString().split("T")[0];
    const word = getWordOfTheDay();
    const normalizedGuess = guess.toLowerCase();

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

        const feedback = normalizedGuess.split("").map((letter, i) => {
            if (word[i] === letter) return "Correct";
            else if (word.includes(letter)) return "Misplaced";
            else return "Incorrect";
        });

        if (game.guessHistory.includes(normalizedGuess)) {
            return res.status(400).json({ error: "You Already Guessed This Word" });
        }

        game.guessHistory.push(normalizedGuess);

        if (game.guessHistory.length >= 6 && normalizedGuess !== word) {
            game.isFailed = true;
        }

        if (normalizedGuess === word) {
            game.isSolved = true;

            if (user.lastPlayed === date) {

            } else if (user.lastPlayed && isYesterday(user.lastPlayed)) {
                user.streak += 1;
            } else {
                user.streak = 1;
            }

            user.lastPlayed = date;
            await user.save();
        }

        await game.save();

        res.json({ 
            normalizedGuess, 
            feedback, 
            isSolved: game.isSolved, 
            attempts: game.guessHistory.length, 
            streak: game.isSolved ? user.streak : undefined
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Guess Submission Failed" });
    }
};

module.exports = { getTodayPuzzle, submitGuess };