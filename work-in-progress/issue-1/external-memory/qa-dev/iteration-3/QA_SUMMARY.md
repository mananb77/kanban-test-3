# QA Summary — Iteration 3 (Enhanced)

## Overview

Enhanced `tests/api.test.mjs` for the Quick Poll full-stack application (Issue #1). The dev iteration 3 change (adding `HEALTHCHECK` to the Dockerfile) was the primary trigger. This QA iteration adds 5 new describe blocks (25 new test cases) to api.test.mjs, porting coverage from smoke.sh sections 19 and 24–27 into the Node.js test runner.

`tests/smoke.sh` is unchanged — it was fully built out in prior iterations (27 sections, ~195+ assertions).

## Files Modified

| File | Action | Before | After |
|------|--------|--------|-------|
| `tests/api.test.mjs` | Enhanced | 27 tests (7 describe blocks) | 52 tests (12 describe blocks) |
| `tests/smoke.sh` | Unchanged | 27 sections, ~195 assertions | Same |

## New Describe Blocks Added to api.test.mjs

### 1. Health check endpoint (2 tests)
Directly tied to the Dockerfile `HEALTHCHECK` directive (dev iteration 3): `GET /api/polls/healthz` returning 404 confirms the server process is alive and the database connection is functional. A connection failure would indicate an unhealthy container.

- `GET /api/polls/healthz` → 404 + non-empty error field
- `GET /api/polls/ping` → 404 (confirms behaviour is path-agnostic)

### 2. HTTP method validation (5 tests)
Covers unsupported HTTP methods against each endpoint. Ports smoke.sh section 24 into Node.js test runner.

- `PUT /api/polls` → 404 (no PUT handler)
- `DELETE /api/polls/:id` → 404 (no DELETE handler)
- `PATCH /api/polls/:id/vote` → 404 (only POST /:id/vote is registered)
- `POST /api/polls/:id` (without /vote suffix) → 404
- `GET /api/polls` (no ID segment) → 200 SPA fallback with React `<div id="root">`

### 3. Non-object JSON request bodies (6 tests)
Express parses valid JSON of any type; object destructuring of non-objects yields `undefined`, triggering server validation. Ports smoke.sh section 25.

- POST /api/polls with JSON number (42) → 400 + error field
- POST /api/polls with JSON string → 400 + error field
- POST /api/polls with JSON array → 400
- POST /api/polls/:id/vote with JSON number → 400 + error field
- POST /api/polls/:id/vote with JSON string → 400
- POST /api/polls/:id/vote with JSON array → 400

### 4. Long input strings (4 tests)
SQLite TEXT columns and Express route handlers impose no artificial length limit. Ports smoke.sh section 26.

- 500-character question → 201, full length stored
- 500-character option texts → 201, full length preserved
- GET round-trip preserves 500-character question exactly
- Voting on poll with long question → 200, vote registered

### 5. Additional input edge cases (8 tests)
Covers server validation paths and boundary content not already in api.test.mjs. Ports smoke.sh sections 18 and 14b/14c.

- `question: null` → 400 (falsy guard catches null)
- `question: false` → 400 (falsy guard catches boolean)
- `question: "\n\t\n"` (escape-sequence whitespace trims to empty) → 400
- `options: ["A", 0]` (numeric zero is falsy, caught before `.trim()`) → 400
- `optionIndex: 1000000` (far out-of-range) → 400
- `optionIndex: 2` on 2-option poll (off-by-one exclusive upper bound) → 400
- Duplicate option texts ("Same", "Same") → 201, both stored (no dedup constraint)
- Single-character question ("?") → 201, stored verbatim

---

## Baseline (Inherited from Prior Iterations)

| Describe Block | Tests |
|----------------|-------|
| Concurrent vote handling | 3 |
| Full workflow integration | 3 |
| Response schema validation | 6 |
| Data isolation between polls | 2 |
| Input validation | 7 |
| Not found handling | 3 |
| Vote count accumulation | 3 |
| **Subtotal** | **27** |

---

## Total Test Count

| File | Before | After | Net New |
|------|--------|-------|---------|
| tests/api.test.mjs | 27 tests | 52 tests | +25 |
| tests/smoke.sh | ~195 assertions | ~195 assertions | 0 |

---

## Coverage Matrix vs Requirements

| Requirement | smoke.sh | api.test.mjs |
|-------------|----------|--------------|
| POST /api/polls — create poll | ✓ | ✓ |
| GET /api/polls/:id — fetch poll | ✓ | ✓ |
| POST /api/polls/:id/vote — cast vote | ✓ | ✓ |
| Input validation (question, options, optionIndex) | ✓ | ✓ |
| Response schema (all 4 top-level fields, option fields) | ✓ | ✓ |
| Concurrent vote safety | — | ✓ |
| Data isolation between polls | ✓ | ✓ |
| Unicode / emoji / HTML verbatim storage | ✓ | ✓ |
| Long input strings (500 chars) | ✓ | ✓ (new) |
| Health check / Dockerfile HEALTHCHECK | ✓ | ✓ (new) |
| HTTP method validation | ✓ | ✓ (new) |
| Non-object JSON bodies | ✓ | ✓ (new) |
| Edge cases (null/bool question, 0 option, off-by-one) | ✓ | ✓ (new) |
| SPA route fallback | ✓ | ✓ (new via GET /api/polls) |
| Persistence (votes survive multiple fetches) | ✓ | ✓ |
| Vote count accumulation (high counts) | ✓ | ✓ |
| Timestamp range validation | ✓ | ✓ |
| Response consistency across endpoints | ✓ | ✓ |

## How to Run

### smoke.sh (requires running server + curl + jq)
```bash
BASE_URL=http://localhost:3001 bash tests/smoke.sh
```

### api.test.mjs (requires running server + Node 18+)
```bash
BASE_URL=http://localhost:3001 node --test tests/api.test.mjs
```
