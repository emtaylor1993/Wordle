/******************************************************************************************************
 * File: User.js
 * 
 * Author: Emmanuel Taylor
 * Created: April 3, 2025
 * Modified: April 3, 2025
 * 
 * Description:
 *   - Mongoose schema for user accounts in the Wordle application.
 * 
 * Dependences:
 *   - mongoose: MongoDB object modeling tool.
 ******************************************************************************************************/

const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
    username: { type: String, required: true, unique: true },
    passwordHash: { type: String, required: true },
    streak: { type: Number, default: 0 },
    bestStreak: { type: Number, default: 0 },
    gamesPlayed: { type: Number, default: 0},
    gamesWon: { type: Number, default: 0},
    lastPlayed: { type: String },
    profileImage: { type: String },
    hardMode: { type: Boolean, default: false },
});

module.exports = mongoose.model("User", userSchema);