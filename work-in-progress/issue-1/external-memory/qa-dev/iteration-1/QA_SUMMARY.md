# QA Summary — Dev Iteration 1

**Date**: 2026-04-22
**Phase**: qa-dev
**Iteration**: 1
**Branch**: main
**Repository**: mananb77/kanban-test-3

---

## What Was Done

Created a comprehensive bash-based test suite in `tests/smoke.sh` covering all API endpoints, validation rules, and integration behaviour of the Quick Poll application. Updated the Dockerfile and manifest to use the new test script.

---

## Files Created / Modified

| File | Action | Description |
|------|--------|-------------|
| `tests/smoke.sh` | Created | 60+ assertion test script |
| `Dockerfile` | Modified | Added `COPY --from=builder /app/tests ./tests` to runtime stage |
| `.coweave/manifest.yml` | Modified | Changed `tests.command` from inline script to `bash /app/tests/smoke.sh` |

---

## Test Coverage Summary

### 1. Frontend (2 assertions)
- `GET /` returns HTTP 200
- Response body contains `<div id="root">` (React mount point)

### 2. POST /api/polls — Create Poll (21 assertions)
- **2a** Happy path: 2-option poll — status 201, response shape (id, question, options, vote_counts, created_at)
- **2b** Happy path: 6-option poll (maximum allowed)
- **2c** Question whitespace trimmed in response
- **2d** Option text whitespace trimmed in response
- **2e** Missing `question` key → 400 with error field
- **2f** Whitespace-only question → 400
- **2g** 1 option (below minimum of 2) → 400
- **2h** 7 options (above maximum of 6) → 400
- **2i** Empty string option → 400
- **2j** Whitespace-only option → 400
- **2k** Missing `options` key → 400

### 3. GET /api/polls/:id — Fetch Poll (8 assertions)
- **3a** Valid poll id → 200, correct id/question/options/ordering
- **3b** Nonexistent poll id → 404 with error field

### 4. POST /api/polls/:id/vote — Cast Vote (17 assertions)
- **4a** Vote on option 0 → 200, vote_count incremented, other options unchanged
- **4b** Vote on option 1 → 200, correct increments
- **4c** Second vote on same option accumulates (count = 2)
- **4d** Vote on last option of 6-option poll (index 5)
- **4e** Negative optionIndex → 400
- **4f** Out-of-range optionIndex → 400
- **4g** Float optionIndex (0.5) → 400
- **4h** Missing optionIndex → 400
- **4i** Vote on nonexistent poll → 404

### 5. Persistence (4 assertions)
- Create poll, cast 3 votes (2+1 split), re-fetch and verify counts are intact
- Confirms SQLite WAL writes survive the in-process request lifecycle

### 6. Poll Isolation (4 assertions)
- Two polls created independently; voting on poll A leaves poll B's counts at 0

---

## Total Assertions

**~56 assertions** across 6 test sections.

---

## Acceptance Criteria Coverage

| AC | Description | Covered by |
|----|-------------|------------|
| AC1 | Single-command startup, single port | Dockerfile + docker-compose (infrastructure) |
| AC2 | Create poll with 2–6 options | §2a, §2b, §2g, §2h |
| AC3 | Vote and see updated results | §4a–4c, §5 |
| AC4 | Share link, others can vote | §6 (multiple polls, isolation) |
| AC5 | Data persists across requests | §5 |
| AC6 | Responsive / clean UI | Frontend §1 (static asset serving verified) |

---

## Known Gaps

- **No UI/browser tests**: React component rendering and interactive flows (PollForm, PollVote, PollResults, copy-link) are not tested at the DOM level. A Playwright or Puppeteer suite would be needed for full UI coverage.
- **No server-restart persistence test**: §5 verifies in-process SQLite writes; testing that data survives a `kill/restart` would require Docker-level orchestration beyond the current `docker exec` approach.
- **No concurrency tests**: SQLite WAL mode is configured but not exercised under parallel writes.
