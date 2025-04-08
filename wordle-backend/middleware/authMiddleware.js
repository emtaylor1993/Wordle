/******************************************************************************************************
 * File: authMiddleware.js
 * 
 * Author: Emmanuel Taylor
 * Created: April 3, 2025
 * Modified: April 7, 2025
 * 
 * Description:
 *   - Express middleware that protects private routes by verifying JWT tokens.
 *   - Valid tokens will attach the user ID to the request object (`req.userId`).
 * 
 * Dependencies:
 *   - jsonwebtoken: For decoding and verifying JWT tokens.
 ******************************************************************************************************/

const jwt = require("jsonwebtoken");

const authMiddleware = (req, res, next) => {
    // Extract token from Authorization header: 'Bearer <token>'.
    const authHeader = req.headers.authorization;
    const token = authHeader?.startsWith("Bearer ") ? authHeader.split(" ")[1] : null;
    
    // If no token is found, deny access.
    if (!token) {
        console.warn("[AUTH] Missing or Malformed Token in Request.");
        return res.status(401).json({ error: "Unauthorized: Token Required" });
    }

    try {
        // Verify the token and extract user payload.
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        // Attach the user ID to the request object for route handlers.
        req.userId = decoded.id;

        // Allow request to proceed.
        next();
    } catch {
        console.warn("[AUTH] Token Verification Failed: ", err.message);
        return res.status(401).json({ error: "Unauthorized: Invalid or Expired Token" });
    }
};

module.exports = authMiddleware;