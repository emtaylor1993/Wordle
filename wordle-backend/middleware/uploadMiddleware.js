/******************************************************************************************************
 * File: uploadMiddleware.js
 * 
 * Author: Emmanuel Taylor
 * Created: April 3, 2025
 * Modified: April 7, 2025
 * 
 * Description:
 *   - Middleware configuration for handling user-uploaded profile images using
 *     Multer. It saves uploaded files to the `uploads` directory with unique
 *     filenames based on user ID.
 * 
 * Dependences:
 *   - multer: Middleware for handling multipart/form-data (used for file uploads).
 *   - path:   Node.js utility module for handling file and directory paths.
 ******************************************************************************************************/

const multer = require("multer");
const path = require("path");

// Storage engine configuration for Multer.
const storage = multer.diskStorage({
    // Where to store uploaded files.
    destination: function (req, file, cb) {

        // Local folder to store user profile images.
        cb(null, "uploads/");
    },

    // How uploaded file should be named.
    filename: function (req, file, cb) {
        // Extract file extension.
        const ext = path.extname(file.originalname);

        // Construct unique file name: [userId]_[timestamp].[ext]
        const filename = `${req.userId}_${Date.now()}${ext}`;
        cb(null, filename);
    }
});

// Multer upload instance with custom settings.
const upload = multer({
    storage,

    // Limit fil esize to 2MB.
    limit: { fileSize: 2 * 1024 * 1024 },

    // Only allow JPEG and PNG image formats.
    fileFilter: function (req, file, cb) {
        const allowed = ["image/jpeg", "image/png"];

        if (allowed.includes(file.mimetype)) {
            cb(null, true);
        } else {
            cb(new Error("Only JPEG and PNG files are allowed."), false);
        }
    },
});

module.exports = upload;