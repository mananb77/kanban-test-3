const express = require('express');
const { randomUUID } = require('crypto');
const { getDb } = require('../db/database');

const router = express.Router();

// POST /api/polls — Create a new poll
router.post('/', (req, res) => {
  try {
    const { question, options } = req.body;

    if (!question || !question.trim())
      return res.status(400).json({ error: 'Question is required' });
    if (!Array.isArray(options) || options.length < 2 || options.length > 6)
      return res.status(400).json({ error: 'Between 2 and 6 options are required' });
    if (options.some(o => !o || !o.trim()))
      return res.status(400).json({ error: 'All options must be non-empty' });

    const db = getDb();
    const id = randomUUID();
    const created_at = Math.floor(Date.now() / 1000);

    const insertPoll = db.prepare('INSERT INTO polls (id, question, created_at) VALUES (?, ?, ?)');
    const insertOption = db.prepare('INSERT INTO options (poll_id, text) VALUES (?, ?)');

    const insertAll = db.transaction(() => {
      insertPoll.run(id, question.trim(), created_at);
      options.forEach(text => insertOption.run(id, text.trim()));
    });
    insertAll();

    const opts = db.prepare('SELECT * FROM options WHERE poll_id = ? ORDER BY id ASC').all(id);
    res.status(201).json({ id, question: question.trim(), created_at, options: opts });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// GET /api/polls/:id — Fetch a poll by ID
router.get('/:id', (req, res) => {
  try {
    const db = getDb();
    const poll = db.prepare('SELECT * FROM polls WHERE id = ?').get(req.params.id);
    if (!poll) return res.status(404).json({ error: 'Poll not found' });

    const opts = db.prepare('SELECT * FROM options WHERE poll_id = ? ORDER BY id ASC').all(poll.id);
    res.json({ ...poll, options: opts });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// POST /api/polls/:id/vote — Cast a vote
router.post('/:id/vote', (req, res) => {
  try {
    const { optionIndex } = req.body;

    if (!Number.isInteger(optionIndex) || optionIndex < 0)
      return res.status(400).json({ error: 'optionIndex must be a non-negative integer' });

    const db = getDb();
    const poll = db.prepare('SELECT * FROM polls WHERE id = ?').get(req.params.id);
    if (!poll) return res.status(404).json({ error: 'Poll not found' });

    const opts = db.prepare('SELECT * FROM options WHERE poll_id = ? ORDER BY id ASC').all(poll.id);
    if (optionIndex >= opts.length)
      return res.status(400).json({ error: 'Option index out of range' });

    db.prepare('UPDATE options SET vote_count = vote_count + 1 WHERE id = ?').run(opts[optionIndex].id);

    const updatedOpts = db.prepare('SELECT * FROM options WHERE poll_id = ? ORDER BY id ASC').all(poll.id);
    res.json({ ...poll, options: updatedOpts });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;
