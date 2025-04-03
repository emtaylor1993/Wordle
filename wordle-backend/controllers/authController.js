/******************************************************************************************************
 * File: authController.js
 * 
 * Author: Emmanuel Taylor
 * Created: April 3, 2025
 * Modified: April 5, 2025
 * 
 * Description:
 *   - Handles authentication logic for user registration, login, and profile access.
 * 
 * Dependences:
 *   - bcryptjs: Used for hashing and comparing user passwords securely.
 *   - jsonwebtoken: Used for verifying and decoding JWT tokens.
 *   - User: Mongoose schema for interacting with user data in MongoDB.
 ******************************************************************************************************/

const User = require("../models/User");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const Game = require("../models/Game");

exports.signup = async (req, res) => {
    try {
        const { username, password } = req.body;

        const existing = await User.findOne({ username });
        if (existing) return res.status(400).json({ error: "Username Taken" });

        const passwordHash = await bcrypt.hash(password, 10);
        const user = await User.create({ username, passwordHash });
        const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET);
        res.status(200).json({ token, username: user.username });
    } catch (err) {
        console.error("Signup Error: ", err);
        res.status(500).json({ error: "Signup Failed" });
    }
};

exports.login = async (req, res) => {
    try {
        const { username, password } = req.body;

        const user = await User.findOne({ username });
        if (!user) return res.status(400).json({ error: "Invalid Credentials" });

        const valid = await bcrypt.compare(password, user.passwordHash);
        if (!valid) return res.status(400).json({ error: "Invalid Credentials" });

        const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET);
        res.json({ token, username: user.username });
    } catch (err) {
        res.status(500).json({ error: "Login Failed" });
    }
};

exports.getProfile = async (req, res) => {
    try {
        const user = await User.findById(req.userId).select("-passwordHash");
        if (!user) return res.status(404).json({ error: "User Not Found" });

        const games = await Game.find({ userId: user._id });
        const totalGames = games.length;
        const wins = games.filter(g => g.isSolved).length;
        const winRate = totalGames > 0 ? ((wins / totalGames) * 100).toFixed(1) : 0;
        const totalGuessesInWins = games.filter(g => g.isSolved).reduce((sum, g) => sum + g.guessHistory.length, 0);
        const avgGuesses = wins > 0 ? (totalGuessesInWins / wins).toFixed(1) : 0;

        let currentStreak = 0;
        let maxStreak = 0;

        const sortedGames = games.filter(g => g.isSolved).map(g => g.date).sort();

        for (let i = 0; i < sortedGames.length; i++) {
            if (i === 0 || isYesterday(sortedGames[i - 1], sortedGames[i])) {
                currentStreak++;
                maxStreak = Math.max(maxStreak, currentStreak);
            } else {
                currentStreak = 1;
            }
        }

        res.json({
            username: user.username,
            streak: user.streak,
            profileImage: user.profileImage || null,
            totalGames,
            wins,
            winRate,
            avgGuesses,
            maxStreak,
        });
    } catch (err) {
        res.status(500).json({ error: "Failed to Fetch User" });
    }
};

function isYesterday(prev, current) {
    const prevDate = new Date(prev);
    const currDate = new Date(current);
    const diff = (currDate - prevDate) / (1000 * 60 * 60 * 24);
    return diff === 1;
}

exports.uploadProfileImage = async (reg, res) => {
    try {
        const user = await User.findByIdAndUpdate(
            req.userId,
            { profileImage: req.file.path },
            { new: true }
        ).select("-passwordHash");
        res.json(user);
    } catch (err) {
        console.error("Upload Error: ", err);
        res.status(500).json({ error: "Failed to Upload Profile Image" });
    }
}