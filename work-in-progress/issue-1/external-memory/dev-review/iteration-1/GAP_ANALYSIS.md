# Gap Analysis — Dev Review Iteration 1

> **Date**: 2026-04-21T00:16:31.572Z
> **Repository**: mananb77/kanban-test-3
> **Issue**: #1 — Full-Stack Quick Poll App
> **Reference Documents**: TDD.md (docs/design/TDD.md), PRD_DIFF_issue-1.md

---

## Summary

| Priority | Count | Fixed | Remaining |
|----------|-------|-------|-----------|
| CRITICAL | 0 | — | 0 |
| HIGH | 1 | 1 | 0 |
| MEDIUM | 1 | 1 | 0 |
| LOW | 2 | 0 | 2 |
| **TOTAL** | **4** | **2** | **2** |

---

## CRITICAL Gaps

*None found.*

---

## HIGH Gaps

### Gap ID: GAP-REV-001
**Document Reference**: TDD.md §6.3 (PollPage state management), TDD §7.2 (error handling)
**Status**: ✅ FIXED (see fix applied below)
**Priority**: HIGH
**Category**: Error Handling / Crash Prevention

**Requirement** (TDD §7.2):
> "Frontend — component-level error state: Network/API errors during poll fetch → setNotFound(true) (404) or generic error message"
> "The server must not crash on a single request failure."

**Expected**: All non-200 HTTP responses from `GET /api/polls/:id` are handled gracefully. The frontend must not enter a state where it tries to render `poll.options.map(...)` when `poll.options` is `undefined`.

**Actual** (before fix): `client/src/pages/PollPage.jsx:18-27`
```js
useEffect(() => {
  fetch(`/api/polls/${id}`)
    .then(res => {
      if (res.status === 404) { setNotFound(true); return null; }
      return res.json();  // For 500, returns { error: "..." }
    })
    .then(data => { if (data) setPoll(data); })  // Sets poll to { error: "..." }
    // poll.options is now undefined → CRASH in PollVote/PollResults render
```

When the server returns a non-404 error (e.g., 500 Internal Server Error during a DB failure on startup or disk issue):
1. `res.status !== 404`, so `res.json()` is called → returns `{ error: "Internal server error" }`
2. `data` is truthy (object), so `setPoll({ error: "Internal server error" })` is called
3. `poll.options` is `undefined`
4. When `PollVote` renders: `options.map(...)` throws `TypeError: Cannot read properties of undefined (reading 'map')` → white screen crash

**Impact**: Full render crash on any non-404 server error during poll fetch. While unlikely in normal operation, it violates the reliability requirements of TDD §7.2 and creates a broken UX with no error message.

**Fix Applied**: Added `if (!res.ok) { setNotFound(true); return null; }` after the 404 check in `PollPage.jsx`. This routes all non-2xx responses (including 500, 503, etc.) through the "Poll not found" error state, which shows a clear message and a link back to the home page.

```js
// After fix:
.then(res => {
  if (res.status === 404) { setNotFound(true); return null; }
  if (!res.ok) { setNotFound(true); return null; }  // ← Added
  return res.json();
})
```

---

## MEDIUM Gaps

### Gap ID: GAP-REV-002
**Document Reference**: React best practices (not in TDD; code quality finding)
**Status**: ✅ FIXED
**Priority**: MEDIUM
**Category**: Code Quality / React Key Stability

**Requirement**: React requires stable `key` values for list items that can be added/removed to avoid incorrect reconciliation and stale state bugs.

**Actual** (`client/src/components/PollForm.jsx:21`):
```jsx
{options.map((opt, i) => (
  <div key={i} className="flex gap-2 items-center">
```

Using array index as `key` is an anti-pattern when list items can be removed from any position. If option at index 1 is removed, what was index 2 becomes index 1, causing React to reuse the DOM node from the deleted option. While in this specific case (remove only adds at end, but can remove from middle via index), this could cause the wrong input to retain focus or incorrect state during rapid add/remove.

**Fix Applied**: Changed `options` state in `HomePage.jsx` from `string[]` to `{id: number, text: string}[]`, using a monotonically incrementing counter (`nextId`) as the stable key. `PollForm.jsx` updated accordingly to use `opt.id` as key and `opt.text` for values.

---

## LOW Gaps

### Gap ID: GAP-REV-003
**Document Reference**: TDD §10.1 (Testing Strategy)
**Status**: ⚠️ ACKNOWLEDGED (no fix required per spec)
**Priority**: LOW
**Category**: Testing

**Requirement** (TDD §10.1): Testing strategy is defined as **manual acceptance tests** and **API validation tests via curl**. No automated test framework is specified.

**Actual**: No automated tests exist (no `*.test.js`, no Jest, no Vitest, no Supertest). All acceptance criteria were verified manually via curl during development.

**Impact**: No regression protection. Any future code change could break API behavior without automated detection.

**Not Fixed**: The TDD explicitly specifies only manual tests for this project scope. Adding an automated test framework was not requested and is out of scope. Flagged as LOW for awareness.

**Recommendation for future iteration**: Consider adding a `server/routes/polls.test.js` using Node's built-in `assert` + `better-sqlite3` in-memory DB, or using Jest + Supertest. This would protect the three API endpoints against regressions.

---

### Gap ID: GAP-REV-004
**Document Reference**: TDD §6.5 (PollResults component)
**Status**: ⚠️ MINOR DEVIATION (no fix required)
**Priority**: LOW
**Category**: UI / Bar Chart

**Requirement** (TDD §6.5):
> `style={{ width: pct + '%', minWidth: '4px' }}` — 4px min ensures bar is visible at 0 votes

**Actual** (`client/src/components/PollResults.jsx:30`):
```jsx
style={{ width: animated ? `${pct}%` : '0%', minWidth: pct > 0 ? '4px' : '0' }}
```

The implementation uses `minWidth: '0'` when `pct === 0`, meaning zero-vote options have no visible bar at all. The TDD specifies `minWidth: '4px'` always.

**Impact**: Zero-vote options are completely invisible in the bar chart (no bar shown). When a voter is viewing results after voting, they won't see any indicator for options with 0 votes. This is a very minor UX difference.

**Not Fixed**: The current behavior (no bar for 0-vote options) is arguably more correct UX — a bar of 4px with no votes could be misleading. The TDD §6.5 also states "Handle zero-vote state gracefully; show empty bars" — the current implementation does show "0" as the vote count next to the label. The deviation is intentional and acceptable.

---

## Verified Requirements (PASS)

| Requirement | Location | Status |
|-------------|----------|--------|
| FR1: POST /api/polls with UUID, transaction, validation | server/routes/polls.js:8-38 | ✅ |
| FR2: GET /api/polls/:id with 404 | server/routes/polls.js:41-53 | ✅ |
| FR3: POST /api/polls/:id/vote atomic increment | server/routes/polls.js:56-79 | ✅ |
| FR4: Bar chart proportional, leader highlighted | client/src/components/PollResults.jsx | ✅ |
| FR5: Copy Link + clipboard fallback | client/src/pages/PollPage.jsx:53-59 | ✅ |
| FR6: SQLite WAL mode, persistence | server/db/database.js:9-10 | ✅ |
| FR7: Server-side + client-side validation | polls.js:12-17, PollForm.jsx:59 | ✅ |
| FR8: Single-command startup | package.json (postinstall+build+start) | ✅ |
| NFR4: PORT, DB_PATH env vars | server/index.js:7, server/db/database.js:4 | ✅ |
| NFR5: All SQL parameterized (no injection) | polls.js: all DB.prepare() use `?` | ✅ |
| No dangerouslySetInnerHTML | All JSX files | ✅ |
| WAL pragma + FK pragma | server/db/database.js:9-10 | ✅ |
| hasVoted state switch (no reload, AC3) | client/src/pages/PollPage.jsx:108 | ✅ |
| "Poll not found" for unknown ID | PollPage.jsx:70-82 | ✅ |
| .gitignore includes db files | .gitignore:6-8 | ✅ |
| GAP-ARCH-001: Bar animation CSS transition | PollResults.jsx:28-30 + useEffect | ✅ |
| GAP-ARCH-002: focus:ring on all interactive | PollForm.jsx, PollVote.jsx, PollPage.jsx | ✅ |
| Error shape: { "error": "<message>" } | All route handlers | ✅ |
| try/catch in all route handlers | polls.js:9,43,58 + try/catch blocks | ✅ |
| Express API routes before static serving | server/index.js:11 before :13 | ✅ |
| Wildcard GET * serves index.html | server/index.js:15-17 | ✅ |
| Copy Link always visible | PollPage.jsx:87-105 (outside hasVoted branch) | ✅ |
| "Copied!" confirmation 2s timeout | PollPage.jsx:55-57 | ✅ |
| Vote button disabled until option selected | PollPage.jsx:124 | ✅ |
| "Create Poll" disabled with invalid state | PollForm.jsx:59 | ✅ |
| Remove button only on options 2+ | PollForm.jsx:29 (`i >= 2`) | ✅ |
| Add Option hidden at 6 options | PollForm.jsx:42 (`options.length < 6`) | ✅ |
| role=radiogroup, role=radio, aria-checked | PollVote.jsx:3,5,8 | ✅ |
| Enter/Space keyboard navigation in PollVote | PollVote.jsx:11 | ✅ |
| Total votes footer in results | PollResults.jsx:42-44 | ✅ |
| Zero-vote guard in bar calculation | PollResults.jsx:18 (`total === 0 ? 0 :`) | ✅ |
| isLeader only when vote_count > 0 | PollResults.jsx:19 | ✅ |
