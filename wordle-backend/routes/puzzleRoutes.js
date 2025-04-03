/******************************************************************************************************
 * File: puzzleRoutes.js
 * 
 * Author: Emmanuel Taylor
 * Created: April 3, 2025
 * Modified: April 3, 2025
 * 
 * Description:
 *   - Defines API routes for the Wordle puzzle logic, including fetching puzzles and
 *     submitting guesses.
 * 
 * Dependences:
 *   - express: Web framework for handling routing and middleware.
 *   - authMiddleware: Ensures the user is authenticated via JWT before accessing puzzle endpoints.
 *   - puzzleController: Contains handler for puzzle-related logic.
 * 
 * Routes:
 *   - GET  /api/puzzle/today: Returns today's puzzle and user progress.
 *   - POST /api/puzzle/guess: Accepts a user guess and returns feedback.
 ******************************************************************************************************/

const express = require("express");
const router = express.Router();
const authMiddleware = require("../middleware/authMiddleware");
const { getTodayPuzzle, submitGuess } = require("../controllers/puzzleController");

router.get("/today", authMiddleware, getTodayPuzzle);
router.post("/guess", authMiddleware, submitGuess);

module.exports = router;