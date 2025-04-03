const multer = require("multer");
const path = require("path");

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, "uploads/");
    },
    filename: function (req, file, cb) {
        const ext = path.extname(file.originalname);
        cb(null, `${req.userId}_${Date.now()}${ext}`);
    },
});

const upload = multer({
    storage,
    limit: { fileSize: 2 * 1024 * 1024 },
    fileFilter: function (req, file, cb) {
        const allowed = ["image/jpeg", "image/png"];
        cb(null, allowed.includes(file.mimetype));
    },
})

module.exports = upload;