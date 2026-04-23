# Test Quality Report — QA Review Iteration 2

**Project**: Quick Poll (mananb77/kanban-test-3)
**Issue**: #1
**Review Date**: 2026-04-23
**Reviewer**: QA Review Agent

---

## Overall Test Suite Health

| Metric | Value |
|--------|-------|
| Total test files | 2 |
| Total test cases (api.test.mjs) | 52 |
| Total assertions (smoke.sh) | ~240+ across 27 sections |
| Last run pass rate | 98.4% (242/246 passing) |
| Active failing tests | 4 |
| Test framework (api.test.mjs) | Node.js built-in `node:test` |
| Test framework (smoke.sh) | Bash + curl + jq |

---

## File-by-File Quality Scores

---

### `tests/api.test.mjs` — Score: 83/100

**Framework**: Node.js `node:test` + `assert/strict`
**Test count**: 52 tests across 12 `describe` blocks
**Lines**: 720

#### Dimension Scores

| Dimension | Score | Notes |
|-----------|-------|-------|
| Assertion quality | 87/100 | Uses strict assertions with descriptive error messages; `assert.equal`, `assert.ok`, `assert.notEqual` well-applied |
| Test independence | 85/100 | Nearly all tests create their own poll via `createPoll()`; shared helpers are stateless |
| Setup / teardown | 65/100 | No teardown; DB state accumulates across tests — acceptable for integration suite but adds noise |
| Coverage breadth | 82/100 | 12 logical groups covering core happy paths, error cases, schema, concurrency, edge cases |
| Naming clarity | 90/100 | Test descriptions precisely name what is being verified and expected outcome |
| Error message quality | 88/100 | Assertion failure messages include actual vs. expected context; interpolation used well |
| Maintainability | 80/100 | Helper functions (`createPoll`, `castVote`, `apiPost`, `apiGet`) reduce duplication |
| Flakiness risk | 70/100 | Concurrent tests assume ordering-independent DB; no retry logic; timestamp tolerance is 60s |

#### Strengths
- **12 logical describe blocks** with clear responsibility separation
- **Strict schema assertion** in `Response schema validation` block: checks exact key count (`Object.keys(body).sort().join(',')`)
- **Concurrent test coverage** in `Concurrent vote handling` block (10 simultaneous votes, split concurrent votes, 5 concurrent poll creates)
- **Full workflow integration** test exercises create → GET → vote → re-GET in sequence, verifying persistence
- **Parameterized invalid input** cases (e.g., 8 `optionIndex` cases in a loop)
- **Unicode, emoji, HTML entities** verified via `assert.equal` for exact round-trip fidelity
- **`castVote` helper asserts 200** on every helper invocation, surfacing cascading failures early

#### Weaknesses

| ID | Severity | Description |
|----|----------|-------------|
| AQ-001 | HIGH | 4 tests actively failing: `25a`, `25b`, `25d`, `25e` return HTTP 500 instead of 400 — root cause is server-side bug (see below) |
| AQ-002 | MEDIUM | No test for `POST /api/polls` with `question` as a number type (e.g., `{ question: 42, options: ["A","B"] }`) |
| AQ-003 | MEDIUM | No test for `POST /api/polls` with missing `question` key (`{}` body with only `options`) — covered in smoke.sh (2e) but absent here |
| AQ-004 | MEDIUM | No test for `POST /api/polls` with missing `options` key — covered in smoke.sh (2k) but absent here |
| AQ-005 | MEDIUM | No test for `options` as a non-array type (string `"A,B"`, or object `{0:"A",1:"B"}`) — covered in smoke.sh (8d, 8g) |
| AQ-006 | LOW | `createPoll` helper's `assert.equal(status, 201)` causes test failure with a misleading message if poll creation is broken; consider better setup isolation |
| AQ-007 | LOW | `Long input strings` block checks `body.options[0].text.length > 400` instead of `=== 500` — weaker assertion than smoke.sh section 26 |
| AQ-008 | LOW | No test for `GET /api/polls` list endpoint (confirmed to fall through to SPA; tested in HTTP method block but assertion only checks 200 and HTML root, not JSON absence) |

---

### `tests/smoke.sh` — Score: 86/100

**Framework**: Bash + curl + jq
**Section count**: 27 sections
**Assertions**: ~240+ (`pass()`/`fail()` calls)
**Lines**: 933

#### Dimension Scores

| Dimension | Score | Notes |
|-----------|-------|-------|
| Assertion quality | 88/100 | `assert_eq`, `assert_json`, `assert_contains` cover status codes AND body fields |
| Section independence | 60/100 | `POLL_ID` from section 2 is reused in sections 3, 4, 7, 8, 24, 25 — section 2 failure cascades |
| Coverage breadth | 92/100 | Covers content-type headers (sec 11), SQL injection (sec 12c), timestamp range (sec 20), incremental totals (sec 27) |
| Helper quality | 85/100 | `http_get`, `http_post`, `http_get_type`, `http_post_type` cleanly wrap curl; `TMPFILE` pattern is clear |
| Exit behavior | 78/100 | `set -uo pipefail` without `set -e`; failures don't abort script — intentional for full reporting |
| Error message quality | 82/100 | `fail()` messages include expected/actual values; `assert_json` prints the body on failure |
| Maintainability | 75/100 | Sequential curl calls for high-count tests (sec 23: 30 sequential votes) make it slow |
| Completeness | 90/100 | All 3 API endpoints fully covered; SPA fallback, CORS-equivalent, and health check included |

#### Strengths
- **Content-Type header validation** (section 11) not present in api.test.mjs; verified for all endpoints including error responses
- **SQL injection in poll ID** (section 12c): `1%27%20OR%20%271%27%3D%271` verifies parameterized queries prevent injection
- **Incremental running-total assertions** in section 27: verifies vote sums increase by exactly 1 at each step
- **Timestamp range** validation (section 20): ±60s tolerance, post-2024 and pre-2100 bounds
- **Non-standard poll IDs** (section 12): arbitrary string, numeric string, injection string — all return 404
- **Both duplicate UUIDs and duplicate question** scenarios (section 14)
- **Middle-boundary poll sizes** (section 9): explicitly tests 3, 4, 5-option polls in addition to 2 and 6

#### Weaknesses

| ID | Severity | Description |
|----|----------|-------------|
| SQ-001 | HIGH | `POLL_ID` set in section 2a is used in 7+ later sections; if section 2 fails, later tests have undefined or wrong `POLL_ID` causing cascades |
| SQ-002 | MEDIUM | Sequential vote loops (sections 15, 23) make the test suite slow for CI; 30 sequential curl requests |
| SQ-003 | MEDIUM | `http_get` / `http_post` write to global `$TMPFILE` — not parallelism-safe; fine for sequential execution |
| SQ-004 | LOW | Section 20 computes `TS_DIFF` but the arithmetic doesn't handle negative diff correctly (bash arithmetic with negatives can be tricky) |
| SQ-005 | LOW | No assertion that poll creation returns `HTTP/1.1 201 Created` with a Location header (RFC-compliant POST responses) — not required by spec but common REST practice |
| SQ-006 | LOW | Section 25 comments mention `express.json() strict mode` but test file does not document the server-side fix needed — clarification would aid maintainers |

---

## Root Cause Analysis: 4 Failing Tests

**Failing tests**: `25a`, `25b`, `25d`, `25e` in both `api.test.mjs` and `smoke.sh`

**Root cause**: `express.json()` middleware uses `strict: true` by default (inherited from `body-parser`). When the request body is a JSON primitive (number or string — NOT array or object), body-parser calls `next(err)` with an error that has `err.status = 400`. The error-handling middleware in `server/index.js` ignores `err.status` and unconditionally returns `500`:

```js
// server/index.js — current broken code
app.use((err, _req, res, _next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });  // always 500!
});
```

**Why JSON arrays pass** (tests 25c, 25f): `express.json()` strict mode accepts arrays as valid top-level JSON. The array body `[{...}]` is parsed to `req.body = [{...}]`. Then `const { question } = [{...}]` gives `question = undefined`, and the application-level validation returns 400 correctly.

**Fix required** in `server/index.js`:
```js
app.use((err, _req, res, _next) => {
  console.error(err.stack);
  const status = err.status || err.statusCode || 500;
  res.status(status).json({ error: err.message || 'Internal server error' });
});
```

---

## Test Execution Environment

- **Runner**: `node --test tests/api.test.mjs` (requires Node >= 18)
- **Smoke**: `bash tests/smoke.sh` (requires curl, jq — present in Docker image)
- **Server required**: Both suites require a running server at `BASE_URL`
- **No package.json test script**: `npm test` will fail; must run directly
- **No CI pipeline**: No `.github/workflows/` found

---

## Summary Table

| File | Score | Failing | Critical Issues |
|------|-------|---------|-----------------|
| tests/api.test.mjs | 83/100 | 4 tests | Server bug causes 500 for primitive JSON bodies |
| tests/smoke.sh | 86/100 | 4 assertions | Same server bug + cascading POLL_ID dependency |
| server/routes/polls.js | N/A (source) | — | Validation logic is correct; bug is in error handler |
| server/index.js | N/A (source) | — | Error handler ignores `err.status` → fix needed |
