const mongoose = require("mongoose");

const gameSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
    date: { type: String },
    guessHistory: [String],
    isSolved: { type: Boolean, default: false },
    isFailed: { type: Boolean, default: false },
});

gameSchema.index({ userId: 1, date: 1}, { unique: true });

module.exports = mongoose.model("Game", gameSchema);