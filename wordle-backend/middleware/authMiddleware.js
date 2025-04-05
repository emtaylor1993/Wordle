/******************************************************************************************************
 * File: authMiddleware.js
 * 
 * Author: Emmanuel Taylor
 * Created: April 3, 2025
 * Modified: April 4, 2025
 * 
 * Description:
 *   - Express middleware to protect certain routes by verifying JWT authentication.
 * 
 * Dependences:
 *   - jsonwebtoken: Used for verifying and decoding JWT tokens.
 ******************************************************************************************************/

const jwt = require("jsonwebtoken");

const authMiddleware = (req, res, next) => {
    const token = req.headers.authorization?.split(" ")[1];             // Extract token after 'Bearer '.
    if (!token) return res.status(401).json({ error: "Unauthorized" }); // No token present.

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);      // Validate/Decode token.
        req.userId = decoded.id;                                        // Attach user ID to request payload.
        next();                                                         // Continues request.
    } catch {
        res.status(401).json({ error: "Invalid Token" });               // Token is invalid/expired.
    }
};

module.exports = authMiddleware;