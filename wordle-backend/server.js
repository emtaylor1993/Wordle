/******************************************************************************************************
 * File: server.js
 * 
 * Author: Emmanuel Taylor
 * Created: April 3, 2025
 * Modified: April 7, 2025
 * 
 * Description:
 *   - Entry point for the Wordle backend service. Initializes and configures the Express
 *     server, MongoDB connection, middleware stack, and core route handlers for authentication
 *     and puzzle logic.
 * 
 * Dependences:
 *   - cors:     Enables cross-origin resource sharing for frontend-backend interaction.
 *   - dotenv:   Loads environment variables from `.env` at runtime.
 *   - express:  Minimalist web framework for routing and middleware.
 *   - helmet:   Secures HTTP headers for production readiness.
 *   - mongoose: ODM library for MongoDB integration.
 * 
 * Routes:
 *   - /api/auth:   Handles user signup, login, and profile. (authRoutes.js)
 *   - /api/puzzle: Handles puzzle logic and submissions. (puzzleRoutes.js)
 ******************************************************************************************************/

const cors = require("cors");
const compression = require("compression");
const express = require("express");
const helmet = require("helmet");
const mongoose = require("mongoose");

require("dotenv").config();

// Custom Routes Modules.
const authRoutes = require("./routes/authRoutes");
const puzzleRoutes = require("./routes/puzzleRoutes");

// Initialize the Express Server.
const app = express();
const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI;

// Middleware Stack.
app.use(cors());
app.use(express.json());
app.use(helmet());
app.use(compression());

// Static Files: Serves uploaded profile images from the /uploads path.
app.use("/uploads", express.static("uploads"));

// Health check endpoint. Used by Docker/Kubernetes to verify if the service is running.
app.get("/health", (req, res) => {
    console.error("[SERVER] Health Check Accessed")
    res.status(200).json({ status: "OK" });
})

// Route Mounting: Register authentication and puzzle-related route handlers.
app.use("/api/auth", authRoutes);
app.use("/api/puzzle", puzzleRoutes);

// Global error handler. Catches all uncaught errors to keep server from crashing.
app.use((err, req, res, next) => {
    console.error("[ERROR] Unhandled Error: ", err.stack);
    res.status(500).json({ error: "Internal Server Error" });
});

// MongoDB Connection: Initializes Mongoose and starts the Express server.
mongoose.connect(process.env.MONGO_URI).then(() => {
    console.log("[SERVER] MongoDB Connected");
    app.listen(PORT, () => console.log(`[SERVER] Server Running at ${MONGO_URI}:${PORT}`));
}).catch((err) => {
    console.error("[SERVER] MongoDB Connection Error: ", err);
    process.exit(1);
});