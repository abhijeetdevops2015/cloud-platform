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

// Routes
app.get("/", (req, res) => {
  res.send("Cloud Platform Backend Running 🚀");
});

app.get("/health", (req, res) => {
  res.json({ status: "ok" });
});

app.get("/db", async (req, res) => {
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

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});