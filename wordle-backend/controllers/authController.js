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
        res.json(user);
    } catch (err) {
        res.status(500).json({ error: "Failed to Fetch User" });
    }
};