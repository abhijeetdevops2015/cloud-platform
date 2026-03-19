const express = require("express");
const { Pool } = require("pg");

const app = express();
const port = 3000;

// PostgreSQL connection (RDS + SSL)
const pool = new Pool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER || "postgres",
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || "appdb",
  port: 5432,

  ssl: {
    rejectUnauthorized: false, // ✅ Required for AWS RDS
  },
});

// Root route
app.get("/", (req, res) => {
  res.send("Cloud Platform Backend Running 🚀");
});

// Health check
app.get("/health", (req, res) => {
  res.json({ status: "ok" });
});

// DB test route
app.get("/db", async (req, res) => {
  try {
    const result = await pool.query("SELECT NOW()");
    res.json(result.rows);
  } catch (err) {
    console.error("DB ERROR:", err);
    res.status(500).json({
      error: "DB connection failed",
      details: err.message,
    });
  }
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});