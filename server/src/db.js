const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');

const dbPath = path.join(__dirname, '..', 'lumina_vault.sqlite');
const db = new sqlite3.Database(dbPath);

// Helper for promise-based queries
const run = (sql, params = []) => {
  return new Promise((resolve, reject) => {
    db.run(sql, params, function (err) {
      if (err) reject(err);
      else resolve({ lastID: this.lastID, changes: this.changes });
    });
  });
};

const get = (sql, params = []) => {
  return new Promise((resolve, reject) => {
    db.get(sql, params, (err, row) => {
      if (err) reject(err);
      else resolve(row);
    });
  });
};

const all = (sql, params = []) => {
  return new Promise((resolve, reject) => {
    db.all(sql, params, (err, rows) => {
      if (err) reject(err);
      else resolve(rows);
    });
  });
};

// Initialize schema
const initDb = async () => {
  await run(`
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      email TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL,
      full_name TEXT NOT NULL,
      avatar_url TEXT DEFAULT 'assets/avatars/boy_1.png',
      phone_number TEXT,
      bio TEXT,
      tier TEXT DEFAULT 'Titanium Sovereign',
      is_verified INTEGER DEFAULT 0,
      is_profile_completed INTEGER DEFAULT 0,
      created_at TEXT DEFAULT (datetime('now')),
      updated_at TEXT DEFAULT (datetime('now'))
    );
  `);

  await run(`
    CREATE TABLE IF NOT EXISTS otps (
      id TEXT PRIMARY KEY,
      email TEXT NOT NULL,
      otp_hash TEXT NOT NULL,
      type TEXT NOT NULL, -- 'register' | 'reset'
      attempts INTEGER DEFAULT 0,
      expires_at INTEGER NOT NULL,
      created_at INTEGER NOT NULL,
      is_used INTEGER DEFAULT 0
    );
  `);

  await run(`
    CREATE TABLE IF NOT EXISTS accounts (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      account_number TEXT UNIQUE NOT NULL,
      currency TEXT DEFAULT 'USD',
      balance REAL DEFAULT 128450.85,
      locked_balance REAL DEFAULT 0.0,
      status TEXT DEFAULT 'active',
      created_at TEXT DEFAULT (datetime('now')),
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    );
  `);

  await run(`
    CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
  `);
  await run(`
    CREATE INDEX IF NOT EXISTS idx_otps_email ON otps(email, type);
  `);
};

module.exports = {
  db,
  run,
  get,
  all,
  initDb,
};
