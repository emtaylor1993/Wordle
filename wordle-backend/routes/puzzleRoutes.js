const express = require("express");
const router = express.Router();
const authMiddleware = require("../middleware/authMiddleware");
const { getTodayPuzzle, submitGuess } = require("../controllers/puzzleController");

router.get("/today", authMiddleware, getTodayPuzzle);
router.post("/guess", authMiddleware, submitGuess);

module.exports = router;