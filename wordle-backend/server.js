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
 *   - helmet: Secures application by setting HTTP headers.
 *   - compression: Improve performance via compression.
 * 
 * Routes:
 *   - /api/auth: Handles user signup, login, and profile. (authRoutes.js)
 *   - /api/puzzle: Handles puzzle logic and submissions. (puzzleRoutes.js)
 ******************************************************************************************************/

const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const helmet = require("helmet");
const compression = require("compression");

require("dotenv").config();

const authRoutes = require("./routes/authRoutes");
const puzzleRoutes = require("./routes/puzzleRoutes");
const app = express();
const PORT = process.env.PORT || 3000;

// Middleware Stack.
app.use(cors());
app.use(express.json());
app.use(helmet());
app.use(compression());

// Static Files: Serves uploaded profile images from the /uploads path.
app.use("/uploads", express.static("uploads"));

// Health check route. Used by Docker/Kubernetes to verify if the service is running.
app.get("/health", (req, res) => {
    res.status(200).json({ status: "OK" });
})

// Route Mounting: Register authentication and puzzle-related route handlers.
app.use("/api/auth", authRoutes);
app.use("/api/puzzle", puzzleRoutes);

// Global error handler.
app.use((err, req, res, next) => {
    console.error("Unhandled Error: ", err.stack);
    res.status(500).json({ error: "Internal Server Error" });
});

// MongoDB Connection: Initializes Mongoose and starts the server.
mongoose.connect(process.env.MONGO_URI).then(() => {
    console.log("MongoDB Connected");
    app.listen(PORT, () => console.log("Server Running on Port 3000"));
}).catch((err) => {
    console.error("MongoDB Connection Error: ", err);
    process.exit(1);
});