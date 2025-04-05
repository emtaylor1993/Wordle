/******************************************************************************************************
 * File: Game.js
 * 
 * Author: Emmanuel Taylor
 * Created: April 3, 2025
 * Modified: April 4, 2025
 * 
 * Description:
 *   - Mongoose schema for tracking Users' game progress in the Wordle application.
 * 
 * Dependences:
 *   - mongoose: MongoDB object modeling tool.
 ******************************************************************************************************/

const mongoose = require("mongoose");

const gameSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
    date: { type: String },
    guessHistory: [{word: String, feedback: [String]}],
    isSolved: { type: Boolean, default: false },
    isFailed: { type: Boolean, default: false },
});

// This ensures that each user gets one game per date.
gameSchema.index({ userId: 1, date: 1}, { unique: true });

module.exports = mongoose.model("Game", gameSchema);