const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
    username: { type: String, required: true, unique: true },
    passwordHash: { type: String, required: true },
    streak: { type: Number, default: 0 },
    lastPlayed: { type: String },
});

module.exports = mongoose.model("User", userSchema);