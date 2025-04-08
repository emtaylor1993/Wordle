/******************************************************************************************************
 * File: authRoutes.js
 * 
 * Author: Emmanuel Taylor
 * Created: April 3, 2025
 * Modified: April 7, 2025
 * 
 * Description:
 *   - Defines all authentication-related API endpoints for the Wordle backend, including:
 *     signup, login, profile retrieval, profile image upload, and settings management.
 * 
 * Dependences:
 *   - authMiddleware: Protects private routes using JWT validation.
 *   - authController: Contains handler for authentication-related logic.
 *   - express: Web framework for handling routing and middleware.
 *   - uploadMiddleware: Handles multipart file uploads.
 * 
 * Routes:
 *   - POST   /api/auth/login:              Authenticate user and return JWT token.
 *   - GET    /api/auth/profile:            Return current user's profile data.
 *   - PATCH  /api/auth/settings:           Update user settings like hardMode.
 *   - GET    /api/auth/settings/hard-mode: Fetch only the current hardMode setting.
 *   - POST   /api/auth/signup:             Registers a new user.
 *   - POST   /api/auth/upload:             Upload or update profile picture.
 ******************************************************************************************************/

const express = require("express");
const router = express.Router();

// Middleware: Route protection and image upload.
const authMiddleware = require("../middleware/authMiddleware");
const upload = require("../middleware/uploadMiddleware");

// Controller helper methods.
const { signup, login, getProfile, uploadProfileImage, updateSettings, getHardMode } = require("../controllers/authController");

// Public routes that do not require any authentication.
router.post("/login", login);
router.post("/signup", signup);

// Protected routes that require JWT authentication.
router.get("/profile", authMiddleware, getProfile);
router.get("/settings/hard-mode", authMiddleware, getHardMode);
router.patch("/settings", authMiddleware, updateSettings);
router.post("/upload", authMiddleware, upload.single("image"), uploadProfileImage);

module.exports = router;