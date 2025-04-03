/******************************************************************************************************
 * File: authRoutes.js
 * 
 * Author: Emmanuel Taylor
 * Created: April 3, 2025
 * Modified: April 3, 2025
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
const authMiddleware = require("../middleware/authMiddleware");
const { signup, login, getProfile } = require("../controllers/authController");

router.post("/signup", signup);
router.post("/login", login);
router.get("/profile", authMiddleware, getProfile);

module.exports = router;