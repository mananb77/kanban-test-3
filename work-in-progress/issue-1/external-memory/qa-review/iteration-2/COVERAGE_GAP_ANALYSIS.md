# Coverage Gap Analysis — QA Review Iteration 2

**Project**: Quick Poll (mananb77/kanban-test-3)
**Issue**: #1
**Review Date**: 2026-04-23

> Note: No automated coverage tooling (Istanbul/c8/nyc) is configured for this project.
> Coverage analysis is based on manual code inspection mapping source files to test assertions.

---

## Source File Coverage Overview

| File | Type | Estimated Coverage | Notes |
|------|------|--------------------|-------|
| `server/index.js` | Server entry | ~60% | Error handler path untested by passing tests; SPA fallback tested |
| `server/routes/polls.js` | API routes | ~95% | All endpoints, all validation branches covered |
| `server/db/database.js` | DB layer | ~40% | `initDb` runs once at startup; `getDb` called indirectly; error path untested |
| `client/src/App.jsx` | Frontend | 0% | No frontend tests |
| `client/src/main.jsx` | Frontend | 0% | No frontend tests |
| `client/src/index.css` | Frontend | N/A | CSS, not testable |
| `client/src/components/PollForm.jsx` | Frontend | 0% | No frontend tests |
| `client/src/components/PollResults.jsx` | Frontend | 0% | No frontend tests |
| `client/src/components/PollVote.jsx` | Frontend | 0% | No frontend tests |
| `client/src/pages/HomePage.jsx` | Frontend | 0% | No frontend tests |
| `client/src/pages/PollPage.jsx` | Frontend | 0% | No frontend tests |

---

## Server-Side Coverage Details

### `server/routes/polls.js` — ~95% estimated coverage

All three route handlers have broad integration test coverage.

#### Covered branches:
- `POST /` happy path (201 response) ✅
- `POST /` — `!question` falsy check ✅
- `POST /` — `question.trim()` empty check ✅
- `POST /` — `!Array.isArray(options)` check ✅
- `POST /` — `options.length < 2` check ✅
- `POST /` — `options.length > 6` check ✅
- `POST /` — `options.some(o => !o || !o.trim())` — empty/whitespace option ✅
- `POST /` — DB transaction (insertPoll + insertOption) ✅
- `GET /:id` happy path (200 response) ✅
- `GET /:id` — `!poll` 404 branch ✅
- `POST /:id/vote` happy path (200 response) ✅
- `POST /:id/vote` — `!Number.isInteger(optionIndex)` check ✅
- `POST /:id/vote` — `optionIndex < 0` check ✅
- `POST /:id/vote` — `optionIndex >= opts.length` check ✅
- `POST /:id/vote` — `!poll` 404 branch ✅

#### Uncovered branches:
- `catch (err)` → `res.status(500)` paths in all three handlers — never triggered by current passing tests
  - These would require the DB to throw (e.g., corrupted DB, disk full, connection failure)
  - **Priority**: LOW (hard to test without mock; DB mock excluded per dev-review)

---

### `server/index.js` — ~60% estimated coverage

#### Covered:
- `app.use(express.json())` — tested by all API requests ✅
- `app.use('/api/polls', pollsRouter)` — all API tests ✅
- `app.use(express.static(CLIENT_BUILD))` — GET / returns 200 with HTML ✅
- `app.get('*', ...)` SPA fallback — tested via `/poll/:id`, unknown paths ✅
- Server `listen()` — called at startup ✅

#### NOT covered / partially covered:
- `app.use((err, _req, res, _next) => ...)` error handler:
  - **Untested successfully** (the 4 failing tests SHOULD trigger it with 400, but bug makes it return 500)
  - After fix, tests 25a/25b/25d/25e will exercise this path and expect 400
  - The `err.stack` log path is covered on failure, but correct response is not
- No test for what happens when `CLIENT_BUILD` directory is missing (startup error)

---

### `server/db/database.js` — ~40% estimated coverage

#### Covered:
- `initDb()` called on startup — implicit via server initialization ✅
- `getDb()` called on every API request — implicit coverage ✅
- `db.pragma('journal_mode = WAL')` — executes on startup ✅
- `CREATE TABLE IF NOT EXISTS` DDL — executes on startup ✅

#### NOT covered:
- `if (!db) throw new Error('Database not initialized')` — error path in `getDb()`
  - Would require calling `getDb()` before `initDb()`; not possible via integration tests
  - **Priority**: LOW

---

## Frontend Coverage Details

All frontend files have **0% automated test coverage**.

Per TDD §14 ("Testing Strategy"), the testing approach for this project is:
> "Manual acceptance testing: The team will manually verify all acceptance criteria AC1–AC6."

The PRD and architecture do not specify automated frontend tests. Therefore:
- **0% frontend coverage is by design, not a gap.**
- Frontend components should be verified manually per acceptance criteria.

### Frontend Files at 0% Coverage (by design)

| File | Component | Manual AC |
|------|-----------|-----------|
| `client/src/App.jsx` | Router setup | AC5 (SPA routing) |
| `client/src/main.jsx` | React DOM root | — |
| `client/src/components/PollForm.jsx` | Poll creation form | AC1 |
| `client/src/components/PollResults.jsx` | Vote bar chart | AC2 |
| `client/src/components/PollVote.jsx` | Vote radio interface | AC2 |
| `client/src/pages/HomePage.jsx` | Home page | AC1 |
| `client/src/pages/PollPage.jsx` | Poll page (vote + results) | AC2, AC3 |

---

## Files With Critical Coverage Gaps (Server-Side)

### Priority 1: `server/index.js` — Error Handler

**Gap**: The 4-argument error handler is invoked for non-object JSON bodies but returns 500 instead of forwarding the correct 400 from body-parser.

**Lines 19–22** (current broken state):
```js
app.use((err, _req, res, _next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});
```

**After fix**, this branch will be properly exercised by tests 25a/25b/25d/25e and will return 400.

**Priority**: CRITICAL — fix before iteration 3 test run.

---

## Coverage Improvement Plan

### Must Fix (before next test run)
1. Fix `server/index.js` error handler to forward `err.status` → enables 4 currently failing tests to pass

### Should Add (medium priority)
2. Add 3 test cases to `api.test.mjs` (missing key variants; see TEST_GAP_ANALYSIS.md GAP-FR5-001 through GAP-FR5-003)

### Optional (low priority)
3. Configure `c8` or `nyc` for automated coverage reporting on `server/` directory
4. Add timing assertion for NFR1 (performance)
5. DB error path testing (requires mocking — excluded per design)

---

## No Coverage Tool Output Available

Coverage metrics above are estimated via manual inspection. To generate actual coverage data:

```bash
# Install c8 (V8 coverage, no instrumentation needed)
cd server && npm install --save-dev c8

# Run api.test.mjs with coverage
BASE_URL=http://localhost:3001 npx c8 --include='**/*.js' --reporter=text node --test ../tests/api.test.mjs
```

This would provide line-level coverage for all server-side JS files.
