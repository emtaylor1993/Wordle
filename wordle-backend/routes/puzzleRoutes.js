/******************************************************************************************************
 * File: puzzleRoutes.js
 * 
 * Author: Emmanuel Taylor
 * Created: April 3, 2025
 * Modified: April 4, 2025
 * 
 * Description:
 *   - Defines API routes for the Wordle puzzle logic, including fetching puzzles and
 *     submitting guesses.
 * 
 * Dependences:
 *   - authMiddleware:   Ensures the user is authenticated via JWT before accessing puzzle endpoints.
 *   - express:          Web framework for handling routing and middleware.
 *   - puzzleController: Contains handler for puzzle-related logic.
 * 
 * Routes:
 *   - GET  /api/puzzle/calendar: Returns a list of puzzle dates for completed games.
 *   - POST /api/puzzle/guess:    Accepts a user guess and returns feedback.
 *   - GET  /api/puzzle/today:    Returns today's puzzle and user progress.
 ******************************************************************************************************/

const express = require("express");
const router = express.Router();

// Middleware: Protects puzzle routes with authentication.
const authMiddleware = require("../middleware/authMiddleware");

// Controller functions for puzzle logic.
const { getTodayPuzzle, submitGuess, getStreakCalendar } = require("../controllers/puzzleController");

// Route to fetch the current day's puzzle and the user's progress.
router.get("/today", authMiddleware, getTodayPuzzle);

// Route to submit a guess for the current puzzle.
router.post("/guess", authMiddleware, submitGuess);

// Route to fetch the list of dates for the Calendar widget.
router.get("/calendar", authMiddleware, getStreakCalendar);

module.exports = router;