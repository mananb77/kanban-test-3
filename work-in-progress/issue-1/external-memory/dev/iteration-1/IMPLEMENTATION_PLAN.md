# Implementation Plan — Issue #1: Full-Stack Quick Poll App

> **Iteration**: 1 | **Date**: 2026-04-20 | **Status**: In Progress

## Stack
- Frontend: React 18 + Vite 5 + Tailwind CSS 3 (`client/`)
- Backend: Node.js 18+ + Express 4 + better-sqlite3 (`server/`)
- Database: SQLite with WAL mode, schema at `server/db/database.js`
- Single port: 3001 via `npm install && npm run build && npm start`

## Non-Blocking Gaps to Address
- **GAP-ARCH-001** (MEDIUM): Bar chart CSS transition on mount (`transition-all duration-500 ease-out`, start 0% → pct%)
- **GAP-ARCH-002** (LOW): Focus states on all interactive elements (`focus:ring-2 focus:ring-blue-500`)

## Implementation Checklist

### Phase 1 — Foundation
- [ ] Root `package.json` (`postinstall`, `build`, `start` scripts)
- [ ] `.gitignore` (node_modules, dist, polls.db, polls.db-wal, polls.db-shm)
- [ ] `server/package.json` (express, better-sqlite3)
- [ ] `server/db/database.js` (initDb, getDb, schema, WAL + FK pragmas)
- [ ] `server/index.js` (express, json, polls router, static serving, error middleware, initDb)
- [ ] `client/package.json` (react, react-dom, react-router-dom, vite, tailwind, postcss, autoprefixer)
- [ ] `client/vite.config.js` (proxy /api → localhost:3001)
- [ ] `client/tailwind.config.js`
- [ ] `client/postcss.config.js`
- [ ] `client/index.html`
- [ ] `client/src/index.css` (Tailwind directives)

### Phase 2 — Backend API
- [ ] `POST /api/polls` — create poll with transaction
- [ ] `GET /api/polls/:id` — fetch poll with vote counts
- [ ] `POST /api/polls/:id/vote` — atomic increment

### Phase 3 — Frontend
- [ ] `client/src/main.jsx` — React entry point
- [ ] `client/src/App.jsx` — Router
- [ ] `client/src/pages/HomePage.jsx` — creation form + validation
- [ ] `client/src/components/PollForm.jsx` — dynamic option inputs
- [ ] `client/src/pages/PollPage.jsx` — voting + results view
- [ ] `client/src/components/PollVote.jsx` — selectable option cards (focus:ring)
- [ ] `client/src/components/PollResults.jsx` — bar chart + animation (GAP-ARCH-001)
- [ ] Copy Link + fallback URL input

### Phase 4 — Integration
- [ ] `npm install` from root
- [ ] `npm run build` from root
- [ ] `npm start` from root
- [ ] Verify all 6 ACs
