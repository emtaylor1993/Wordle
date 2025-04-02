const express = require("express");
const router = express.Router();
const authMiddleware = require("../middleware/authMiddleware");
const { signup, login, getProfile } = require("../controllers/authController");

router.post("/signup", signup);
router.post("/login", login);
router.get("/profile", authMiddleware, getProfile);

module.exports = router;