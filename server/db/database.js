const Database = require('better-sqlite3');
const path = require('path');

const DB_PATH = process.env.DB_PATH || path.join(__dirname, 'polls.db');
let db;

function initDb() {
  db = new Database(DB_PATH);
  db.pragma('journal_mode = WAL');
  db.pragma('foreign_keys = ON');
  db.exec(`
    CREATE TABLE IF NOT EXISTS polls (
      id         TEXT    PRIMARY KEY,
      question   TEXT    NOT NULL,
      created_at INTEGER NOT NULL
    );
    CREATE TABLE IF NOT EXISTS options (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      poll_id    TEXT    NOT NULL REFERENCES polls(id),
      text       TEXT    NOT NULL,
      vote_count INTEGER NOT NULL DEFAULT 0
    );
  `);
  return db;
}

function getDb() {
  if (!db) throw new Error('Database not initialized');
  return db;
}

module.exports = { initDb, getDb };
