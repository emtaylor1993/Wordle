/******************************************************************************************************
 * File: authRoutes.js
 * 
 * Author: Emmanuel Taylor
 * Created: April 3, 2025
 * Modified: April 4, 2025
 * 
 * Description:
 *   - Defines API for authentication-related routes for the Wordle application, including user
 *     signup, login, and profile access.
 * 
 * Dependences:
 *   - express: Web framework for handling routing and middleware.
 *   - authMiddleware: Ensures the user is authenticated via JWT before accessing puzzle endpoints.
 *   - authController: Contains handler for autnentication-related logic.
 * 
 * Routes:
 *   - POST /api/auth/signup:  Registers a new user. 
 *   - GET  /api/auth/login:   Authenticates an existing user and returns a JWT token.
 *   - POST /api/auth/profile: Returns the authenticated user's profile information.
 ******************************************************************************************************/

const express = require("express");
const router = express.Router();

// Middleware: Route protection and image upload.
const authMiddleware = require("../middleware/authMiddleware");
const upload = require("../middleware/uploadMiddleware");

// Controller helper methods.
const { signup, login, getProfile, uploadProfileImage } = require("../controllers/authController");

// Public routes that do not require any authentication.
router.post("/signup", signup);
router.post("/login", login);

// Protected routes that require authentication.
router.get("/profile", authMiddleware, getProfile);
router.post("/upload", authMiddleware, upload.single("image"), uploadProfileImage);

module.exports = router;