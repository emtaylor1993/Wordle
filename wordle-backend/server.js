const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

require("dotenv").config();

const authRoutes = require("./routes/authRoutes");
const puzzleRoutes = require("./routes/puzzleRoutes");
const app = express();

app.use(cors());
app.use(express.json());
app.use("/api/auth", authRoutes);
app.use("/api/puzzle", puzzleRoutes);

mongoose.connect(process.env.MONGO_URI).then(() => {
    console.log("MongoDB Connected");
    app.listen(3000, () => console.log("Server Running on Port 3000"));
}).catch((err) => {
    console.error("MongoDB Connection Error: ", err);
});