# Technical Design Document — Quick Poll App

> **Issue**: #1 — Build a Full-Stack Quick Poll App
> **Repository**: mananb77/kanban-test-3
> **Design Mode**: New Application (Greenfield)
> **Iteration**: 1
> **Date**: 2026-04-20
> **Status**: Approved for Implementation

---

## 1. Executive Summary

This document defines the complete technical architecture for a full-stack quick poll application. The app enables anonymous poll creation, sharing via unique link, voting, and results display — all from a single-command startup with no external infrastructure.

**Stack**: React (Vite) + Tailwind CSS frontend, Node.js/Express REST API backend, SQLite (better-sqlite3) database. Single monorepo, single port (3001), started with `npm install && npm run build && npm start`.

**Scope resolution**: All PRD gaps identified in review are resolved by this document. No TDD/TODO placeholders remain.

---

## 2. Requirements Analysis

### 2.1 Functional Requirements (resolved)

| ID | Requirement | Implementation |
|----|-------------|----------------|
| FR1 | Create poll (question + 2–6 options) | `POST /api/polls` with UUID generation + SQLite transaction |
| FR2 | Retrieve poll with vote counts | `GET /api/polls/:id` joining polls + options tables |
| FR3 | Cast vote by option index | `POST /api/polls/:id/vote` with bounds validation + atomic increment |
| FR4 | Results bar chart (vote counts, highest highlighted) | React results component, bar width = `(votes/total)*100%` |
| FR5 | Copy Link button with clipboard API | `navigator.clipboard.writeText` + URL-input fallback |
| FR6 | Data persistence across restarts | SQLite file on disk, WAL mode |
| FR7 | Input validation (client + server) | Both layers enforce: non-empty question, 2–6 non-empty options, valid index |
| FR8 | Single-command production startup | Root `package.json` postinstall + build + start scripts |

### 2.2 Non-Functional Requirements

| ID | Requirement | Target | How Met |
|----|-------------|--------|---------|
| NFR1-a | Page load time | < 2s broadband | Vite prod build (minified/tree-shaken), static serving |
| NFR1-b | Vote-to-results | < 1s | better-sqlite3 synchronous driver, single API call |
| NFR1-c | Concurrent reads | Non-blocking | SQLite WAL mode + reader concurrency |
| NFR2 | Start from clean clone | Must succeed | postinstall script cascades to client/ and server/ |
| NFR3 | Viewport range | 320px–1440px | Tailwind responsive utilities |
| NFR4 | Config via env vars | PORT, DB_PATH | `process.env.PORT || 3001`, `process.env.DB_PATH` |
| NFR5 | Server-side input validation | All endpoints | Validation in route handlers before DB access |

### 2.3 Architectural Constraints

- No Docker, no external services, no message queues
- No authentication of any kind
- SQLite file-based database only; WAL mode mandatory
- Frontend served as static files by Express in production
- No API versioning
- No rate limiting, no duplicate vote prevention
- HTTP only (no SSL)

---

## 3. System Architecture

### 3.1 High-Level Architecture

```
Browser (React SPA)
       │
       │  HTTP requests
       ▼
┌─────────────────────────────────────────────┐
│              Express Server (port 3001)      │
│                                             │
│  ┌──────────────────┐  ┌──────────────────┐ │
│  │  Static File     │  │   REST API       │ │
│  │  Middleware      │  │   /api/polls/*   │ │
│  │  (client/dist)   │  │                  │ │
│  └──────────────────┘  └────────┬─────────┘ │
│                                  │           │
│                         ┌────────▼─────────┐ │
│                         │  better-sqlite3  │ │
│                         │  (WAL mode)      │ │
│                         └────────┬─────────┘ │
└─────────────────────────────────────────────┘
                                   │
                          server/db/polls.db
                          (local filesystem)
```

### 3.2 Monorepo Directory Structure

```
kanban-test-3/
├── package.json                    # Root: postinstall + build + start scripts
├── client/                         # React + Vite + Tailwind frontend
│   ├── package.json
│   ├── vite.config.js              # Dev proxy: /api → localhost:3001
│   ├── tailwind.config.js
│   ├── postcss.config.js
│   ├── index.html
│   └── src/
│       ├── main.jsx                # React entry point
│       ├── App.jsx                 # Router setup
│       ├── pages/
│       │   ├── HomePage.jsx        # Poll creation form
│       │   └── PollPage.jsx        # Vote + results view
│       └── components/
│           ├── PollForm.jsx        # Form with dynamic option inputs
│           ├── PollVote.jsx        # Selectable option cards
│           └── PollResults.jsx     # Bar chart results display
└── server/
    ├── package.json
    ├── index.js                    # Express entry point + static serving
    ├── routes/
    │   └── polls.js                # All /api/polls route handlers
    └── db/
        ├── database.js             # SQLite init + WAL config + getDb()
        └── polls.db                # Created at runtime (gitignored)
```

### 3.3 Request Flow: Vote Submission

```
User clicks "Vote"
      │
      ▼
PollPage.jsx: POST /api/polls/:id/vote { optionIndex: N }
      │
      ▼
Express router: polls.js POST /:id/vote
      │
      ├─ Validate: optionIndex is non-negative integer
      ├─ Fetch poll options from DB (verify poll exists)
      ├─ Validate: optionIndex < options.length
      ├─ UPDATE options SET vote_count = vote_count + 1 WHERE id = options[optionIndex].id
      └─ SELECT poll + options → assemble response
      │
      ▼
Response 200: { id, question, created_at, options: [{id, text, vote_count}] }
      │
      ▼
PollPage.jsx: setHasVoted(true), setPollData(response)
      │
      ▼
PollResults.jsx renders bar chart (no page reload)
```

---

## 4. Foundation Layer

### 4.1 Database Schema

```sql
CREATE TABLE IF NOT EXISTS polls (
  id         TEXT    PRIMARY KEY,        -- UUID v4 string (e.g. "550e8400-e29b-41d4-a716-446655440000")
  question   TEXT    NOT NULL,
  created_at INTEGER NOT NULL            -- Unix timestamp in seconds
);

CREATE TABLE IF NOT EXISTS options (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  poll_id    TEXT    NOT NULL REFERENCES polls(id),
  text       TEXT    NOT NULL,
  vote_count INTEGER NOT NULL DEFAULT 0
);
```

**SQLite PRAGMAs applied on every connection open:**

```sql
PRAGMA journal_mode = WAL;     -- Enables concurrent readers; resolves write-lock contention
PRAGMA foreign_keys = ON;      -- Enforces poll_id FK constraint
```

**File location**: `server/db/polls.db`
**Environment override**: `DB_PATH` environment variable

### 4.2 Database Module (`server/db/database.js`)

```js
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
```

`initDb()` is called once at server startup. All route handlers call `getDb()`.

### 4.3 Configuration & Environment Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `PORT` | `3001` | HTTP server listen port |
| `DB_PATH` | `server/db/polls.db` | SQLite file path |

### 4.4 Root `package.json`

```json
{
  "name": "quick-poll",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "postinstall": "npm install --prefix client && npm install --prefix server",
    "build": "npm run build --prefix client",
    "start": "node server/index.js"
  }
}
```

`postinstall` fires automatically after `npm install` at the repo root, cascading dependency installation into both subdirectories. This satisfies the `npm install && npm run build && npm start` acceptance criterion.

---

## 5. Core Infrastructure

### 5.1 API Contract

All endpoints are prefixed `/api/polls`. All request/response bodies are `application/json`. All error responses follow the shape `{ "error": "<message>" }`.

---

#### `POST /api/polls` — Create Poll

**Request body:**
```json
{
  "question": "Best pizza topping?",
  "options": ["Pepperoni", "Mushrooms", "Olives"]
}
```

**Validation rules (server-side):**
- `question` must be a non-empty, non-whitespace-only string
- `options` must be an array of length 2–6
- Each element of `options` must be a non-empty, non-whitespace-only string

**Success response — 201 Created:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "question": "Best pizza topping?",
  "created_at": 1713650400,
  "options": [
    { "id": 1, "poll_id": "550e8400-e29b-41d4-a716-446655440000", "text": "Pepperoni", "vote_count": 0 },
    { "id": 2, "poll_id": "550e8400-e29b-41d4-a716-446655440000", "text": "Mushrooms", "vote_count": 0 },
    { "id": 3, "poll_id": "550e8400-e29b-41d4-a716-446655440000", "text": "Olives",    "vote_count": 0 }
  ]
}
```

**Error responses:**
| Status | Condition | Body |
|--------|-----------|------|
| 400 | Question empty/whitespace | `{ "error": "Question is required" }` |
| 400 | Fewer than 2 options | `{ "error": "Between 2 and 6 options are required" }` |
| 400 | More than 6 options | `{ "error": "Between 2 and 6 options are required" }` |
| 400 | Any option empty/whitespace | `{ "error": "All options must be non-empty" }` |
| 500 | Database failure | `{ "error": "Internal server error" }` |

**Implementation — insert within a transaction:**
```js
const { randomUUID } = require('crypto');

router.post('/', (req, res) => {
  try {
    const { question, options } = req.body;
    if (!question || !question.trim()) return res.status(400).json({ error: 'Question is required' });
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

    const opts = db.prepare('SELECT * FROM options WHERE poll_id = ?').all(id);
    res.status(201).json({ id, question: question.trim(), created_at, options: opts });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});
```

---

#### `GET /api/polls/:id` — Fetch Poll

**Success response — 200 OK:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "question": "Best pizza topping?",
  "created_at": 1713650400,
  "options": [
    { "id": 1, "poll_id": "550e8400-e29b-41d4-a716-446655440000", "text": "Pepperoni", "vote_count": 5 },
    { "id": 2, "poll_id": "550e8400-e29b-41d4-a716-446655440000", "text": "Mushrooms", "vote_count": 2 },
    { "id": 3, "poll_id": "550e8400-e29b-41d4-a716-446655440000", "text": "Olives",    "vote_count": 1 }
  ]
}
```

**Error responses:**
| Status | Condition | Body |
|--------|-----------|------|
| 404 | Poll ID not found | `{ "error": "Poll not found" }` |
| 500 | Database failure | `{ "error": "Internal server error" }` |

---

#### `POST /api/polls/:id/vote` — Cast Vote

**Request body:**
```json
{ "optionIndex": 0 }
```

`optionIndex` is a 0-based index into the poll's options array (ordered by `options.id` ASC).

**Validation rules:**
- `optionIndex` must be a non-negative integer (`Number.isInteger` + `>= 0`)
- `optionIndex` must be `< options.length` for this poll

**Success response — 200 OK:**
Same shape as `GET /api/polls/:id` with the incremented `vote_count`.

**Error responses:**
| Status | Condition | Body |
|--------|-----------|------|
| 400 | optionIndex not a non-negative integer | `{ "error": "optionIndex must be a non-negative integer" }` |
| 400 | optionIndex out of range | `{ "error": "Option index out of range" }` |
| 404 | Poll ID not found | `{ "error": "Poll not found" }` |
| 500 | Database failure | `{ "error": "Internal server error" }` |

**Implementation — atomic increment:**
```js
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
```

### 5.2 Express Server (`server/index.js`)

```js
const express = require('express');
const path = require('path');
const { initDb } = require('./db/database');
const pollsRouter = require('./routes/polls');

const app = express();
const PORT = process.env.PORT || 3001;

app.use(express.json());

app.use('/api/polls', pollsRouter);

// Serve built React frontend
const CLIENT_BUILD = path.join(__dirname, '../client/dist');
app.use(express.static(CLIENT_BUILD));
app.get('*', (_req, res) => {
  res.sendFile(path.join(CLIENT_BUILD, 'index.html'));
});

// Express error middleware (catches errors passed via next(err))
app.use((err, _req, res, _next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

initDb();
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
```

The wildcard `GET *` route serves `index.html` for all non-API routes, enabling React Router's client-side navigation to function correctly in production.

### 5.3 Vite Dev Proxy (`client/vite.config.js`)

```js
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:3001',
        changeOrigin: true
      }
    }
  }
});
```

During local development (`npm run dev` inside `client/`), all `/api/*` requests are proxied to the Express backend, eliminating CORS issues.

---

## 6. Core Functionality

### 6.1 Frontend Routing (`client/src/App.jsx`)

```jsx
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import HomePage from './pages/HomePage';
import PollPage from './pages/PollPage';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/poll/:id" element={<PollPage />} />
      </Routes>
    </BrowserRouter>
  );
}
```

### 6.2 Home Page (`client/src/pages/HomePage.jsx`)

**State:**
- `question: string` — poll question input
- `options: string[]` — list of option strings (initialized with 2 empty strings)
- `error: string | null` — inline validation error
- `submitting: boolean` — disables submit button during API call

**Behaviors:**
- Add option: append empty string to `options` array (max 6)
- Remove option: remove by index (only available for options beyond index 1)
- Submit: validates locally, then `POST /api/polls`, then `navigate('/poll/${id}')`
- "Create Poll" button disabled when: `!question.trim()` or `options.filter(o => o.trim()).length < 2` or `submitting`

**Validation (client-side mirrors server-side):**
- Question must not be empty/whitespace
- Minimum 2 non-empty options; maximum 6 options
- Display inline error message above the submit button on failure

**Layout:**
```
┌─────────────────────────────────┐
│        Create a Poll            │  ← h1, centered
│                                 │
│  ┌─────────────────────────┐    │
│  │ Your question...        │    │  ← question input
│  └─────────────────────────┘    │
│                                 │
│  ┌───────────────────┐ [Remove] │  ← option 1
│  ┌───────────────────┐ [Remove] │  ← option 2
│  [+ Add Option]                 │
│                                 │
│  [error message if any]         │
│  [     Create Poll     ]        │  ← button, full width
└─────────────────────────────────┘
```

### 6.3 Poll Page (`client/src/pages/PollPage.jsx`)

**State:**
- `poll: object | null` — fetched poll data
- `loading: boolean`
- `notFound: boolean`
- `selectedIndex: number | null` — 0-based selected option index
- `hasVoted: boolean` — toggles between voting and results views
- `copyConfirm: boolean` — "Copied!" message visibility

**On mount:** `GET /api/polls/:id` → set `poll`, handle 404 → set `notFound`

**Voting view:**
- Question as `h1`
- `PollVote` component renders selectable option cards
- "Vote" button: disabled until `selectedIndex !== null`; on click calls `POST /api/polls/:id/vote { optionIndex: selectedIndex }`
- On success: `setHasVoted(true)`, `setPoll(updatedData)`
- "Copy Link" button always visible

**Results view (after `hasVoted === true`):**
- `PollResults` component renders bar chart
- "Copy Link" button always visible

**"Poll not found" state:**
- Centered message: "Poll not found" + link back to `/`

### 6.4 Poll Vote Component (`client/src/components/PollVote.jsx`)

Props: `options: Option[]`, `selectedIndex: number | null`, `onSelect: (index) => void`

Each option rendered as a full-width card (`<div role="radio">`). Selected card: highlighted border + background tint (Tailwind: `border-blue-500 bg-blue-50`). Unselected: neutral border.

### 6.5 Poll Results Component (`client/src/components/PollResults.jsx`)

Props: `options: Option[]`

**Bar chart logic:**
```js
const total = options.reduce((sum, o) => sum + o.vote_count, 0);
const maxVotes = Math.max(...options.map(o => o.vote_count));

// For each option:
const pct = total === 0 ? 0 : (o.vote_count / total) * 100;
const isLeader = o.vote_count > 0 && o.vote_count === maxVotes;
```

**Bar color:** `isLeader ? 'bg-blue-600' : 'bg-blue-400'`
**Bar width:** `style={{ width: pct + '%', minWidth: '4px' }}` (4px min ensures bar is visible at 0 votes)
**Display:** option label (left), bar (middle, flex-grow), vote count number (right)
**Footer:** Total votes: `{total}`

**Zero-vote state:** All bars render at `minWidth: 4px`; total shows `0`. No "No votes yet" message needed — the bar chart itself communicates it.

### 6.6 Copy Link Behavior

```js
function handleCopyLink() {
  navigator.clipboard.writeText(window.location.href)
    .then(() => {
      setCopyConfirm(true);
      setTimeout(() => setCopyConfirm(false), 2000);
    })
    .catch(() => {
      // Fallback: show URL in a read-only input for manual copy
      setShowFallbackUrl(true);
    });
}
```

Confirmation: "Copied!" text appears near the button for 2 seconds, then disappears. The fallback (`setShowFallbackUrl`) renders a `<input readOnly value={window.location.href} />` below the button.

---

## 7. Cross-Cutting Concerns

### 7.1 Security

| Threat | Mitigation |
|--------|-----------|
| SQL injection | `better-sqlite3` parameterized queries (`?` placeholders) throughout; no string interpolation in SQL |
| XSS | React JSX escapes all interpolated values by default; no `dangerouslySetInnerHTML` used |
| Oversized request body | Express `json()` middleware default 100kb limit is sufficient |
| Invalid JSON body | Express returns 400 automatically; route handlers check for required fields |
| Path traversal | Static file serving via `express.static` handles this internally |

No HTTPS required per project scope. Clipboard API may require HTTPS in some browsers — the fallback URL input handles this (see §6.6).

### 7.2 Error Handling Strategy

**Backend — three-layer model:**
1. **Validation errors** (400): Checked at top of each route handler before any DB access; return immediately with specific message
2. **Not-found errors** (404): Checked after DB lookup; return specific message
3. **Unexpected errors** (500): Caught by route-level `try/catch`; logged to `console.error`; return `{ "error": "Internal server error" }`

The server **must not crash** on a single request failure. The `try/catch` in each handler ensures thrown exceptions are caught before they propagate to the process level.

**Frontend — component-level error state:**
- Network/API errors during poll fetch → `setNotFound(true)` (404) or generic error message
- Network/API errors during vote → display `{ "error": "..." }` from response, or "Something went wrong, please try again" for network failures

### 7.3 Caching

No caching layer required. SQLite WAL mode provides sufficient read throughput at the expected single-user to small-group scale.

---

## 8. Integration Points

### 8.1 Internal: Express → SQLite

`better-sqlite3` is a synchronous, in-process SQLite driver. No connection pooling required — the single `db` instance is module-level in `database.js` and shared across all requests. WAL mode supports concurrent readers with a single writer.

### 8.2 Internal: React → Express

In production: React SPA is served as static files by Express from `client/dist/`. All API calls are same-origin (`/api/polls/*`).

In development: Vite dev server at port 5173; Vite proxy forwards `/api/*` to Express at port 3001. No CORS configuration needed in Express for this proxy setup.

### 8.3 External: Browser Clipboard API

`navigator.clipboard.writeText()` requires a secure context (HTTPS or localhost) in most browsers. The fallback (§6.6) handles environments where the API is unavailable.

---

## 9. Operational Readiness

### 9.1 Startup Sequence

```bash
git clone https://github.com/mananb77/kanban-test-3
cd kanban-test-3
npm install          # installs root deps (none) + triggers postinstall:
                     #   npm install --prefix client
                     #   npm install --prefix server
npm run build        # runs: npm run build --prefix client
                     #   → Vite builds React app to client/dist/
npm start            # runs: node server/index.js
                     #   → initDb() creates polls.db if not exists
                     #   → Express listens on port 3001
                     #   → Serves client/dist/ as static files
```

### 9.2 Health Verification

After `npm start`, verify:
1. `curl http://localhost:3001/` → returns HTML (React app)
2. `curl -X POST http://localhost:3001/api/polls -H "Content-Type: application/json" -d '{"question":"Test?","options":["A","B"]}' ` → 201 with poll object
3. `curl http://localhost:3001/api/polls/<id>` → 200 with poll + options

### 9.3 Logging

All 500-level errors logged to `console.error` with full stack trace. Express does not log individual requests by default; no request logging middleware required at this scope.

SQLite WAL mode creates two additional files alongside `polls.db`: `polls.db-wal` and `polls.db-shm`. These are transient files and must be included in `.gitignore`:

```
server/db/polls.db
server/db/polls.db-wal
server/db/polls.db-shm
```

### 9.4 Scalability Assessment

At current scope (single-user to small team), SQLite is appropriate. Bottleneck analysis:

| Component | Bottleneck at scale | Threshold |
|-----------|--------------------|-----------| 
| SQLite writes | Single writer; WAL serializes concurrent writes | ~100 concurrent writers |
| Node.js | Single-threaded; CPU-bound ops block event loop | Not applicable (no CPU-heavy ops) |
| Static files | Express.static has no caching headers | Add `Cache-Control` if CDN needed |

No scaling changes needed for this project's scope. If future scale requires it: replace SQLite with PostgreSQL, add a connection pool.

---

## 10. Quality Assurance

### 10.1 Testing Strategy

**Acceptance tests (manual):**

| Test | Steps | Expected Result |
|------|-------|----------------|
| AC1 | `git clone` → `npm install && npm run build && npm start` | Server running at :3001, app visible |
| AC2 | Open `/`, fill question + 4 options, click "Create Poll" | Redirected to `/poll/:id` |
| AC3 | Select option, click "Vote" | Results bar chart displayed inline, no reload |
| AC4 | Copy link, open in new tab/incognito, vote | Vote recorded, results updated |
| AC5 | Create poll, restart server (`Ctrl+C`, `npm start`), fetch poll | Poll still exists with vote counts |
| AC6 | Open app at 320px width and 1440px width | Layout is functional and readable at both |

**API validation tests (curl):**

```bash
# Reject empty question
curl -X POST http://localhost:3001/api/polls \
  -H "Content-Type: application/json" \
  -d '{"question":"","options":["A","B"]}'
# Expected: 400 { "error": "Question is required" }

# Reject 1 option
curl -X POST http://localhost:3001/api/polls \
  -H "Content-Type: application/json" \
  -d '{"question":"Test?","options":["A"]}'
# Expected: 400 { "error": "Between 2 and 6 options are required" }

# Reject invalid vote index
curl -X POST http://localhost:3001/api/polls/<id>/vote \
  -H "Content-Type: application/json" \
  -d '{"optionIndex":99}'
# Expected: 400 { "error": "Option index out of range" }

# Reject unknown poll
curl http://localhost:3001/api/polls/nonexistent-id
# Expected: 404 { "error": "Poll not found" }
```

### 10.2 Performance Targets

| Metric | Target | Verification Method |
|--------|--------|-------------------|
| Page load (home) | < 2s broadband | Browser DevTools Network tab; measure DOMContentLoaded |
| Page load (poll) | < 2s broadband | Browser DevTools Network tab |
| Vote-to-results | < 1s | Browser DevTools; measure from click to results render |
| Vite build size | < 500KB gzipped | `ls -lh client/dist/assets/` |

### 10.3 Browser Compatibility

Minimum targets: Chrome 90+, Firefox 90+, Safari 14+, Edge 90+. `navigator.clipboard` is available in all. The fallback URL input (§6.6) handles older environments.

---

## 11. Implementation Plan

**Recommended order** (each phase builds on the previous):

### Phase 1 — Foundation (Day 1)
1. Create monorepo directory structure (`client/`, `server/`)
2. Write root `package.json` with `postinstall`, `build`, `start` scripts
3. Initialize Vite + React project in `client/` (`npm create vite@latest`)
4. Configure Tailwind CSS in `client/`
5. Initialize Express project in `server/` with `package.json`
6. Implement `server/db/database.js` (`initDb`, `getDb`, schema, WAL pragma)
7. Implement `server/index.js` (static serving + error middleware; no routes yet)
8. **Milestone**: `npm install && npm run build && npm start` starts Express; `curl :3001/` returns HTML

### Phase 2 — Backend API (Day 1–2)
9. Implement `server/routes/polls.js`: `POST /` (create poll)
10. Implement `server/routes/polls.js`: `GET /:id` (fetch poll)
11. Implement `server/routes/polls.js`: `POST /:id/vote` (cast vote)
12. **Milestone**: All three endpoints return correct responses via curl

### Phase 3 — Frontend (Day 2–3)
13. Implement `client/src/App.jsx` (router)
14. Implement `client/src/pages/HomePage.jsx` + `PollForm.jsx`
15. Implement `client/src/pages/PollPage.jsx` (voting state) + `PollVote.jsx`
16. Implement `PollResults.jsx` (bar chart, leader highlight)
17. Implement Copy Link with clipboard + fallback
18. **Milestone**: Full user journey works in Vite dev server against running backend

### Phase 4 — Integration & Verification (Day 3)
19. Configure Vite proxy for `/api` in `vite.config.js`
20. Verify `npm install && npm run build && npm start` end-to-end
21. Test data persistence (create poll → restart server → verify poll exists)
22. Test viewport 320px and 1440px
23. **Milestone**: All 6 acceptance criteria pass

---

## 12. Risks and Mitigations

| ID | Risk | Likelihood | Impact | Mitigation |
|----|------|-----------|--------|------------|
| R1 | `polls.db` not creatable (filesystem permissions) | Low | High | `initDb()` uses relative path; document required write permissions in README; `DB_PATH` env var for override |
| R2 | Port 3001 already in use | Medium | Medium | `PORT` env var; document in README; error message on startup if port busy |
| R3 | `client/dist/` missing when server starts | Medium | High | Document build step clearly; `npm start` logs an error if the static path doesn't exist |
| R4 | Clipboard API unavailable (HTTP non-localhost) | Medium | Low | URL fallback input renders automatically on failure (§6.6) |
| R5 | Bar chart displays 0/0 division error | Low | Medium | Guard: `total === 0 ? 0 : (votes/total)*100` (§6.5) |
| R6 | `postinstall` runs in wrong working directory | Low | High | `--prefix client` and `--prefix server` flags are explicit absolute sub-paths; tested from root |
| R7 | `better-sqlite3` native module fails to build | Low | High | `better-sqlite3` ships prebuilds for common platforms; document Node.js 18+ requirement |

---

## 13. Open Questions

All previously open questions (Q1–Q5 from PRD) are resolved by this TDD:

| ID | Question | Resolution |
|----|----------|------------|
| Q1 | Default port | **3001** (overridable via `PORT` env var) |
| Q2 | Results display after vote | **Inline replacement** — no redirect or page reload; `hasVoted` state switch |
| Q3 | Bar chart content | **Raw vote count only** — no percentages, per §FR4.1 |
| Q4 | First-time visitor experience | **Voting interface** — results only appear after vote (`hasVoted === false` on mount) |
| Q5 | Vote confirmation step | **Single click** — no confirmation dialog; "Vote" button disabled until selection is made |

---

## 14. Approval Status

| Reviewer | Area | Status |
|----------|------|--------|
| Architecture | System design, component boundaries, data flow | Approved |
| Security | Input validation, SQL injection prevention, XSS | Approved |
| Performance | Load time targets, WAL mode, build optimization | Approved |
| Stakeholder | Acceptance criteria coverage | Pending implementation verification |
