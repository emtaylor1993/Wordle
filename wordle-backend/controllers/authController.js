/******************************************************************************************************
 * File: authController.js
 * 
 * Author: Emmanuel Taylor
 * Created: April 3, 2025
 * Modified: April 7, 2025
 * 
 * Description:
 *   - Handles authentication logic for user registration, login, and profile access.
 * 
 * Dependences:
 *   - bcryptjs: Used for hashing and comparing user passwords securely.\
 *   - Game: Mongoose schema for representing game progress, used for user statistics.
 *   - jsonwebtoken: Used for verifying and decoding JWT tokens.
 *   - User: Mongoose schema for interacting with user data in MongoDB.
 ******************************************************************************************************/

const bcrypt = require("bcryptjs");
const Game = require("../models/Game");
const jwt = require("jsonwebtoken");
const User = require("../models/User");

/**
 * @route POST /api/auth/signup
 * 
 * Creates a new user account and returns a JWT token.
 * 
 * @access Public 
 */
exports.signup = async (req, res) => {
    try {
        const { username, password } = req.body;
        const existing = await User.findOne({ username });

        if (existing) return res.status(400).json({ error: "Username Taken" });
        
        const passwordHash = await bcrypt.hash(password, 10);
        const user = await User.create({ username, passwordHash });
        const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET);
        
        console.log(`[AUTH] New User Registered: ${username}`);
        res.status(200).json({ token, username: user.username });
    } catch (err) {
        console.error("[AUTH] Signup Error: ", err);
        res.status(500).json({ error: "Signup Failed" });
    }
};

/**
 * @route POST /api/auth/login
 * 
 * Authenticates a user and returns a JWT token.
 * 
 * @access Public
 */
exports.login = async (req, res) => {
    try {
        const { username, password } = req.body;

        const user = await User.findOne({ username });
        if (!user) return res.status(400).json({ error: "Invalid Credentials" });

        const valid = await bcrypt.compare(password, user.passwordHash);
        if (!valid) return res.status(400).json({ error: "Invalid Credentials" });

        const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET);

        console.log(`[AUTH] Login Successful: ${username}`);
        res.json({ token, username: user.username });
    } catch (err) {
        console.log("[AUTH] Login Error: ", err);
        res.status(500).json({ error: "Login Failed" });
    }
};

/**
 * @route GET /api/auth/profile
 * 
 * Retrieves the authenticated user's profile and gameplay statistics.
 * 
 * @access Private (Requires JWT token)
 */
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
        const sortedGames = games.filter(g => g.isSolved).map(g => g.date).sort();

        // Calculates the current and maximum win streak.
        let currentStreak = 0;
        let maxStreak = 0;

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
        console.error("[AUTH] Failed to Fetch Profile: ", err);
        res.status(500).json({ error: "Failed to Fetch User" });
    }
};

/**
 * isYesterday
 * 
 * Utility function to check if two dates are consecutive days. This is
 * used for determining streak continuation.
 * 
 * @param {string} prev     - Previous day.
 * @param {string} current  - Current day.
 * @returns {boolean} - True if the previous day is one day before the current day. 
 */
function isYesterday(prev, current) {
    const prevDate = new Date(prev);
    const currDate = new Date(current);
    const diff = (currDate - prevDate) / (1000 * 60 * 60 * 24);
    return diff === 1;
}

/**
 * @route POST /api/auth/upload
 * 
 * Updates the user's profile with a new profile picture.
 * 
 * @access Private (Uses multer middleware)
 */
exports.uploadProfileImage = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: "No File Uploaded" });
        }

        const user = await User.findByIdAndUpdate(
            req.userId,
            { profileImage: req.file.path },
            { new: true }
        ).select("-passwordHash");

        console.log(`[PROFILE] Uploaded Image for User ${user.username}`);
        res.json(user);
    } catch (err) {
        console.error("[PROFILE] Image Upload Error: ", err);
        res.status(500).json({ error: "Failed to Upload Profile Image" });
    }
}

/**
 * @route PATCH /api/auth/settings
 * 
 * Updates user settings like hardMode.
 * 
 * @access Private (Requires JWT Token)
 */
exports.updateSettings = async (req, res) => {
    try {
        const { hardMode } = req.body;
        const user = await User.findByIdAndUpdate(
            req.userId,
            { hardMode },
            { new: true }
        ).select("-passwordHash");

        console.log(`[SETTINGS] Updated Hard Mode for ${user.username}: ${hardMode}`);
        res.json({ success: true, hardMode: user.hardMode });
    } catch (err) {
        console.error("[SETTINGS] Failed to Update Settings: ", err);
        res.status(500).json({ error: "Failed to Update Settings" });
    }
}

/**
 * @route GET /api/auth/settings/hard-mode
 * 
 * Returns the user's hard mode setting.
 * 
 * @access Private (Requires JWT Token)
 */
exports.getHardMode = async (req, res) => {
    try {
        const user = await User.findById(req.userId).select("hardMode");
        if (!user) return res.status(404).json({ error: "User Not Found" });

        console.log(`[SETTINGS] Fetched Hard Mode for ${user._id}: ${user.hardMode}`);
        res.json({ hardMode: user.hardMode });
    } catch (err) {
        console.error("[SETTINGS] Failed Fetching Hard Mode: ", err);
        res.status(500).json({ error: "Failed Fetching Hard Mode" });
    }
}