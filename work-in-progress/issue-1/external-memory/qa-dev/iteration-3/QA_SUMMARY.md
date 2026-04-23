# QA Summary — Iteration 3

## Overview

Enhanced the existing test suite for the Quick Poll full-stack application (Issue #1).
The application consists of a Node.js/Express REST API with SQLite storage and a React
frontend served via Express's static middleware.

## Files Modified / Created

| File | Action | Description |
|------|--------|-------------|
| `tests/smoke.sh` | Enhanced | Added 4 new sections (24–27), 32 new test assertions |
| `tests/api.test.mjs` | Created | New Node.js integration test file, 108 assertions |

## New Test Coverage — smoke.sh (Sections 24–27)

### Section 24: HTTP Method Validation (6 tests)
Tests that unsupported HTTP methods on API endpoints return 404, documenting the
routing behaviour precisely.

- `24a` — PUT /api/polls → 404
- `24b` — DELETE /api/polls/:id → 404
- `24c` — PATCH /api/polls/:id/vote → 404
- `24d` — GET /api/polls (no ID segment) → 200 with SPA HTML (no list endpoint; catch-all serves index.html)
- `24d` grep — React root element present in SPA fallback
- `24e` — POST /api/polls/:id (no /vote suffix) → 404

### Section 25: Non-object JSON Request Bodies (8 tests)
Express's JSON middleware accepts any valid JSON type. When a non-object body is
destructured, field lookups yield `undefined`, triggering existing input validation.

- `25a` — Body `42` (JSON number) → 400 + error field
- `25b` — Body `"just a string"` (JSON string) → 400
- `25c` — Body `[{...}]` (JSON array) → 400
- `25d` — Vote body `42` → 400 + error field
- `25e` — Vote body `"string"` → 400
- `25f` — Vote body `[{...}]` → 400

### Section 26: Long Input Strings (7 tests)
Verifies SQLite TEXT columns and the Express route handlers impose no artificial
length limits. Uses a 500-character string generated with `printf`.

- `26a` — 500-char question → 201; stored non-empty
- `26b` — 500-char option texts → 201; 2 options, length preserved (>400 chars)
- `26c` — GET of poll with long question → 200; round-trip length exactly 500
- `26d` — Vote on poll with long question → 200; vote registered correctly

### Section 27: Complete Voting Cycle (11 tests)
Creates a 4-option poll and votes on every option exactly once, verifying running
totals after each vote and confirming the final state via a separate GET.

- Setup — create 4-option poll
- `27a` — Vote option 0 → running total 1
- `27b` — Vote option 1 → running total 2
- `27c` — Vote option 2 → running total 3
- `27d` — Vote option 3 → total 4, every option has exactly 1 vote
- `27e` — GET confirms total 4, all options at 1 vote each

## New Test File — tests/api.test.mjs

Node.js integration tests using the built-in `node:test` framework (Node ≥ 18).
No additional dependencies required.

**Run command:**
```bash
BASE_URL=http://localhost:3001 node --test tests/api.test.mjs
```

### Test Suites and Coverage

| Suite | Tests | Key Scenarios |
|-------|-------|---------------|
| Concurrent vote handling | 3 | 10 simultaneous votes on same option; split concurrent votes; concurrent poll creation |
| Full workflow integration | 3 | End-to-end lifecycle; multi-voter accumulation; vote response vs GET consistency |
| Response schema validation | 6 | Exact field count/types; GET matches POST; vote schema; timestamp plausibility; option ordering; Content-Type on all endpoints |
| Data isolation between polls | 2 | Cross-poll vote isolation; duplicate-question polls get distinct IDs |
| Input validation | 6 | Whitespace question variants; invalid option counts; invalid optionIndex types; trimming; extra fields; unicode/emoji; HTML entities |
| Not found handling | 3 | 404 on GET, vote, various non-UUID IDs |
| Vote count accumulation | 3 | High-count sequential votes; GET idempotency; full voting cycle |

**Total assertions in api.test.mjs:** 108

## Test Coverage Summary

| Category | smoke.sh (pre) | smoke.sh (post) | api.test.mjs |
|----------|---------------|-----------------|--------------|
| API endpoint validation | ✓ | ✓ +32 tests | ✓ |
| HTTP method coverage | — | ✓ 5 tests | — |
| Non-object JSON bodies | — | ✓ 8 tests | — |
| Long input strings | — | ✓ 7 tests | — |
| Complete voting cycle | — | ✓ 11 tests | ✓ |
| Concurrent operations | — | — | ✓ 3 test cases |
| Full workflow | — | — | ✓ 3 test cases |
| Schema validation | ✓ | ✓ | ✓ 6 test cases |
| Data isolation | ✓ | ✓ | ✓ 2 test cases |
| Input validation | ✓ | ✓ | ✓ 6 test cases |
| Not found handling | ✓ | ✓ | ✓ 3 test cases |
| GET idempotency | — | — | ✓ |

## Test Count

| File | Before | After | Net New |
|------|--------|-------|---------|
| tests/smoke.sh | ~100 assertions | ~132 assertions | +32 |
| tests/api.test.mjs | (new) | 108 assertions | +108 |
| **Total** | ~100 | ~240 | **+140** |

## How to Run

### smoke.sh (requires running server + curl + jq)
```bash
BASE_URL=http://localhost:3001 bash tests/smoke.sh
```

### api.test.mjs (requires running server + Node 18+)
```bash
BASE_URL=http://localhost:3001 node --test tests/api.test.mjs
```
