/******************************************************************************************************
 * File: server.js
 * 
 * Author: Emmanuel Taylor
 * Created: April 3, 2025
 * Modified: April 5, 2025
 * 
 * Description:
 *   - Entry point for the Wordle backend server. Sets up Express, a MongoDB connection, 
 *     and routes.
 * 
 * Dependences:
 *   - express: Web framework for handling routing and middleware.
 *   - mongoose: MongoDB object modeling tool.
 *   - cors: Enables cross-origin resource sharing.
 *   - dotenv: Loads environment variables from .env file.
 * 
 * Routes:
 *   - /api/auth: Handles user signup, login, and profile. (authRoutes.js)
 *   - /api/puzzle: Handles puzzle logic and submissions. (puzzleRoutes.js)
 ******************************************************************************************************/

const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

require("dotenv").config();

const authRoutes = require("./routes/authRoutes");
const puzzleRoutes = require("./routes/puzzleRoutes");
const app = express();

app.use(cors());
app.use(express.json());
app.use("/uploads", express.static("uploads"));
app.use("/api/auth", authRoutes);
app.use("/api/puzzle", puzzleRoutes);

mongoose.connect(process.env.MONGO_URI).then(() => {
    console.log("MongoDB Connected");
    app.listen(3000, () => console.log("Server Running on Port 3000"));
}).catch((err) => {
    console.error("MongoDB Connection Error: ", err);
});