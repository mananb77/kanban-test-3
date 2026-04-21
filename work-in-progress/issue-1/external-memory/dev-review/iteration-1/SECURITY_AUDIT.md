# Security Audit — Dev Review Iteration 1

> **Date**: 2026-04-21T00:16:31.572Z
> **Repository**: mananb77/kanban-test-3
> **Reference**: TDD §7.1 (Security), TDD §2.3 (Architectural Constraints)

---

## Overall Assessment: ✅ PASS

All security requirements from TDD §7.1 are satisfied. The application is appropriately secured for its scope (no auth, HTTP-only, single-user to small-team use).

---

## SQL Injection Prevention ✅

**All SQL queries use parameterized statements via `better-sqlite3` `.prepare()`.**

Verified in `server/routes/polls.js`:
- Line 23: `db.prepare('INSERT INTO polls (id, question, created_at) VALUES (?, ?, ?)')`
- Line 24: `db.prepare('INSERT INTO options (poll_id, text) VALUES (?, ?)')`
- Line 32: `db.prepare('SELECT * FROM options WHERE poll_id = ? ORDER BY id ASC')`
- Line 44: `db.prepare('SELECT * FROM polls WHERE id = ?')`
- Line 47: `db.prepare('SELECT * FROM options WHERE poll_id = ? ORDER BY id ASC')`
- Line 64: `db.prepare('SELECT * FROM polls WHERE id = ?')`
- Line 67: `db.prepare('SELECT * FROM options WHERE poll_id = ? ORDER BY id ASC')`
- Line 71: `db.prepare('UPDATE options SET vote_count = vote_count + 1 WHERE id = ?')`
- Line 73: `db.prepare('SELECT * FROM options WHERE poll_id = ? ORDER BY id ASC')`

No string interpolation in any SQL query. ✅

---

## XSS Prevention ✅

React JSX escapes all interpolated values by default. Verified absence of `dangerouslySetInnerHTML` across all component files:
- `App.jsx` — none
- `HomePage.jsx` — none
- `PollPage.jsx` — none
- `PollForm.jsx` — none
- `PollVote.jsx` — none
- `PollResults.jsx` — none

Poll question and option text are rendered as React text nodes, never as HTML. ✅

---

## Input Validation (Server-Side) ✅

Per TDD §7.1: "All user inputs must be validated server-side before storage."

**POST /api/polls** (`server/routes/polls.js:12-17`):
- `!question || !question.trim()` → 400 "Question is required"
- `!Array.isArray(options) || options.length < 2 || options.length > 6` → 400
- `options.some(o => !o || !o.trim())` → 400 "All options must be non-empty"
- Validation occurs before any `getDb()` call ✅

**POST /api/polls/:id/vote** (`server/routes/polls.js:60-68`):
- `!Number.isInteger(optionIndex) || optionIndex < 0` → 400
- `optionIndex >= opts.length` → 400 "Option index out of range"
- Validation occurs before DB write ✅

---

## Request Body Size Limit ✅

Express `json()` middleware (server/index.js:9) uses the default 100kb request body limit. The maximum possible poll creation request (6 options × max reasonable option length) is well under 100kb. ✅

---

## Path Traversal ✅

Static file serving is handled by `express.static(CLIENT_BUILD)` which sanitizes paths internally. No custom file serving logic. ✅

---

## Out of Scope (Intentionally Not Implemented) ✅

Per TDD §2.3 Architectural Constraints and PRD Out of Scope:

| Item | Scope Decision |
|------|---------------|
| HTTPS / SSL | Not required per scope (HTTP only) |
| Authentication | Explicitly excluded |
| CSRF protection | Not required (no session state, no mutations requiring auth) |
| Rate limiting | Explicitly excluded per PRD |
| Duplicate vote prevention | Explicitly excluded per PRD |
| HTTP security headers (helmet) | Not mentioned in TDD — out of scope |

These are **not security gaps** — they are explicit scope constraints.

---

## Clipboard API Note

TDD §7.1 notes the clipboard API may require HTTPS in some browsers. The fallback URL input (`PollPage.jsx:96-104`) renders a `<input readOnly>` with `onFocus={e => e.target.select()}` when `navigator.clipboard` fails. This correctly handles the HTTPS constraint. ✅
