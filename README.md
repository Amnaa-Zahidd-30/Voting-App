🗳️ Election Voting System

A full-stack web application for managing elections — voter registration, authenticated vote casting, and real-time result tracking — built with Node.js and SQL.


📋 Description:
The Election Voting System is a backend-driven web application that simulates a complete election workflow. It handles candidate registration, voter authentication, one-vote-per-voter enforcement, and live vote count aggregation — all backed by a normalized relational database. Built to demonstrate full-stack development with RESTful API design and database integrity constraints.
Technologies: Node.js · Express.js · SQL (MySQL) · JavaScript

⚙️ Installation
1. Clone the repository
git clone https://github.com/Amnaa-Zahidd-30/Voting-App.git
cd Voting-App

Install Node dependencies
npm install
Set up the database

# Make sure MySQL is running, then import the schema:
mysql -u root -p < Election_Voting_System.sql

Requirements: Node.js 16+, MySQL 8+


🚀 Usage
Start the Express server
node server.js
The server will start on http://localhost:3000. Example API calls:
Register a voter
POST /api/voters

# Cast a vote
POST /api/votes

# Get election results
GET /api/results

✨ Features

Voter registration and identity management
Candidate registration with party affiliation
One-vote-per-voter constraint enforced at the database level via SQL unique constraints
Real-time vote count aggregation per candidate
RESTful API design with Express.js route handling
Normalized relational schema — Voters, Candidates, Elections, Votes tables with foreign key integrity


🤝 Contributing
Contributions are welcome!

Fork the repository
Create a new branch: git checkout -b feature/your-feature
Commit your changes: git commit -m 'Add your feature'
Push and open a Pull Request

📬 Contact
amnazahid894@gmail.com
