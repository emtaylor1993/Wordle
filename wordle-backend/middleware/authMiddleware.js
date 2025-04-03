/******************************************************************************************************
 * File: authMiddleware.js
 * 
 * Author: Emmanuel Taylor
 * Created: April 3, 2025
 * Modified: April 5, 2025
 * 
 * Description:
 *   - Express middleware to protect certain routes by verifying JWT authentication.
 * 
 * Dependences:
 *   - jsonwebtoken: Used for verifying and decoding JWT tokens.
 ******************************************************************************************************/

const jwt = require("jsonwebtoken");

const authMiddleware = (req, res, next) => {
    const token = req.headers.authorization?.split(" ")[1];
    if (!token) return res.status(401).json({ error: "Unauthorized" });

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.userId = decoded.id;
        next();
    } catch {
        res.status(401).json({ error: "Invalid Token" });
    }
};

module.exports = authMiddleware;