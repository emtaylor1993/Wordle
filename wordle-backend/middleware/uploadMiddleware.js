/******************************************************************************************************
 * File: uploadMiddleware.js
 * 
 * Author: Emmanuel Taylor
 * Created: April 3, 2025
 * Modified: April 4, 2025
 * 
 * Description:
 *   - Middleware configuration for handling user-uploaded profile images using
 *     Multer. It saves uploaded files to the `uploads` directory with unique
 *     filenames based on user ID.
 * 
 * Dependences:
 *   - multer: Middleware for handling multipart/form-data (used for file uploads).
 *   - path: Node.js utility module for handling file and directory paths.
 ******************************************************************************************************/

const multer = require("multer");
const path = require("path");

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, "uploads/");                           // Save uploads to local 'uploads' directory.
    },
    filename: function (req, file, cb) {
        const ext = path.extname(file.originalname);    // Extract file extension.
        cb(null, `${req.userId}_${Date.now()}${ext}`);  // Unique filename using user ID + timestamp
    },
});

const upload = multer({
    storage,
    limit: { fileSize: 2 * 1024 * 1024 },               // File Limit: 2MB.
    fileFilter: function (req, file, cb) {
        const allowed = ["image/jpeg", "image/png"];
        if (allowed.includes(file.mimetype)) {
            cb(null, true);
        } else {
            cb(new Error("Only JPEG and PNG files are allowed."), false);
        }
    },
})

module.exports = upload;