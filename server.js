const express = require("express");
const cors = require("cors");
const mysql = require("mysql2");

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static("public"));

const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "election_db"
});

db.connect(err => {
  if (err) throw err;
  console.log("DB Connected");
});

// REGISTER
app.post("/api/register", (req, res) => {
  const { username, password } = req.body;
  db.query(
    "INSERT INTO users (username, password) VALUES (?, ?)",
    [username, password],
    () => res.json({ ok: true })
  );
});

// LOGIN
app.post("/api/login", (req, res) => {
  const { username, password } = req.body;

  db.query(
    "SELECT * FROM users WHERE username=? AND password=?",
    [username, password],
    (err, result) => {
      if (result.length > 0) res.json(result[0]);
      else res.json({ error: "Invalid login" });
    }
  );
});

// GET CANDIDATES
app.get("/api/candidates", (req, res) => {
  db.query("SELECT * FROM Candidate", (err, result) => {
    res.json(result);
  });
});

// VOTE
app.post("/api/vote", (req, res) => {
  const { user_id, candidate_ID } = req.body;

  db.query("SELECT has_voted FROM users WHERE user_id=?", [user_id],
    (err, result) => {

      if (result[0].has_voted) {
        return res.json({ error: "Already voted" });
      }

      db.query("UPDATE Candidate SET votes = votes + 1 WHERE candidate_ID=?",
        [candidate_ID]);

      db.query("UPDATE users SET has_voted = TRUE WHERE user_id=?",
        [user_id]);

      res.json({ success: true });
    }
  );
});

// RESULTS
app.get("/api/results", (req, res) => {
  db.query(
    "SELECT Name, votes FROM Candidate ORDER BY votes DESC",
    (err, result) => res.json(result)
  );
});

app.listen(5000, () => console.log("http://localhost:5000"));