/******************************************************************************************************
 * File: server.js
 * 
 * Author: Emmanuel Taylor
 * Created: April 3, 2025
 * Modified: April 4, 2025
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

// Middleware: Enables CORS to allow requests from different origins.
app.use(cors());

// Middleware: Parses incoming JSON payloads in HTTP request bodies.
app.use(express.json());

// Static Files: Serves uploaded profile images from the /uploads path.
app.use("/uploads", express.static("uploads"));

// Route Mounting: Register authentication and puzzle-related route handlers.
app.use("/api/auth", authRoutes);
app.use("/api/puzzle", puzzleRoutes);

// MongoDB Connection: Initializes Mongoose and starts the server.
mongoose.connect(process.env.MONGO_URI).then(() => {
    console.log("MongoDB Connected");
    app.listen(3000, () => console.log("Server Running on Port 3000"));
}).catch((err) => {
    console.error("MongoDB Connection Error: ", err);
});