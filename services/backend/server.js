const express = require("express");
const { Pool } = require("pg");
const cors = require("cors");

const app = express();
const port = 3000;

// ✅ Enable CORS
app.use(cors());

// PostgreSQL connection
const pool = new Pool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: 5432,
  ssl: {
    rejectUnauthorized: false,
  },
});

// 🔥 Create API router
const router = express.Router();

// Routes
router.get("/", (req, res) => {
  res.send("Cloud Platform Backend Running 🚀");
});

router.get("/health", (req, res) => {
  res.json({ status: "ok" });
});

router.get("/db", async (req, res) => {
  try {
    const result = await pool.query("SELECT NOW()");
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({
      error: "DB connection failed",
      details: err.message,
    });
  }
});

// 🔥 Mount everything under /api
app.use("/api", router);

// Optional root route (nice to have)
app.get("/", (req, res) => {
  res.send("Backend root. Use /api/*");
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});