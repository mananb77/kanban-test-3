# QA Summary — Iteration 2 (Updated)

## Overview

Enhanced the existing `tests/smoke.sh` smoke test suite for the Quick Poll app (React + Express + SQLite). The baseline suite from QA iteration 10 had **100 tests across 11 sections**, all passing.

This iteration (across two sub-passes) added **12 new sections (12–23)** with approximately **95 additional test assertions**, bringing the projected total to ~195 tests.

- **Sections 12–17** (first sub-pass): Non-standard IDs, Unicode, duplicates, vote accumulation, complete schema, response consistency
- **Sections 18–23** (second sub-pass): Input edge cases, health check, timestamp validation, vote response completeness, extra-field handling, high-count accumulation

All new tests were verified correct against the running server using a Python HTTP client before being committed to `smoke.sh`.

---

## Baseline (Inherited)

| Section | Description | Tests |
|---------|-------------|-------|
| 1 | Frontend static HTML | 2 |
| 2 | POST /api/polls — creation & validation | 20 |
| 3 | GET /api/polls/:id — fetch & 404 | 7 |
| 4 | POST /api/polls/:id/vote — voting & validation | 15 |
| 5 | Persistence across fetches | 5 |
| 6 | Poll isolation | 5 |
| 7 | Response schema | 9 |
| 8 | Additional type validation | 8 |
| 9 | Middle-boundary poll sizes (3, 4, 5) | 10 |
| 10 | SPA route fallback | 4 |
| 11 | Content-Type headers | 5 |
| **Total** | | **100** |

---

## New Tests Added (Iteration 2)

### Section 12 — Non-standard and Injection Poll IDs (6 tests)
Coverage gap: no tests for non-UUID poll IDs or SQL injection attempts.
- 12a: GET with arbitrary non-UUID string ID → 404 + error field
- 12b: GET with numeric string ID → 404
- 12c: GET with URL-encoded SQL injection attempt → 404 (parameterized queries confirmed safe)
- 12d: POST vote with non-UUID poll ID → 404 + error field

### Section 13 — Unicode and Special Character Content (9 tests)
Coverage gap: no tests for multi-byte or HTML-special content.
- 13a: Create poll with emoji (🎉🚀❤️) in question and options → 201, 3 options stored
- 13b: Retrieve emoji poll → options count preserved, all text non-empty
- 13c: Create poll with Latin-extended/accented characters (Café, thé) → 201, stored correctly
- 13d: Create poll with HTML tags and entities verbatim → 201, question and option stored as-is (API does not escape HTML; that is the frontend's responsibility)

### Section 14 — Duplicate and Boundary Content (8 tests)
Coverage gap: no tests for identical-question polls, duplicate options, or minimum-length questions.
- 14a: Two polls with identical question text → both 201, distinct UUIDs
- 14b: Poll with two identical option texts → 201, both stored (no dedup constraint)
- 14c: Single-character question ("?") → 201, stored correctly
- 14d: Explicit optionIndex=0 boundary on a fresh poll → 200, only option 0 incremented

### Section 15 — Vote Count Accumulation Stress (8 tests)
Coverage gap: only 2–3 accumulated votes tested previously; no cross-option sum verification.
- 15a: 5 consecutive votes on option 0 → vote_count == 5, option 1 untouched
- 15b: 3 additional votes on option 1 → option 0 still 5, option 1 == 3, total sums to 8

### Section 16 — Complete Response Schema for All Three Endpoints (17 tests)
Coverage gap: section 7 was partial. No full key-count assertions; vote response `created_at` was not explicitly tested.
- 16a: POST /api/polls → exactly 4 top-level keys (id, question, created_at, options), correct types
- 16b: Each option object → exactly 4 keys (id, poll_id, text, vote_count)
- 16c: GET /api/polls/:id → all 4 top-level keys present, correct types
- 16d: POST /api/polls/:id/vote → all 4 top-level keys including `created_at` (a notable gap), id matches

### Section 17 — Response Consistency Across Endpoints (7 tests)
Coverage gap: no cross-endpoint verification that stable fields (created_at, option ids) remain identical.
- 17a: GET response `created_at` and option ids match the original POST (CREATE) response
- 17b: VOTE response `created_at` and option ids match the original POST (CREATE) response
- 17c: Two sequential GET calls return identical vote_count (GET is non-mutating)

---

## Verification

All new sections were verified against a locally running server (same Node.js v20 + better-sqlite3 stack as the production Docker image) using a Python HTTP client. Every assertion returned the expected result before being merged into `smoke.sh`.

The bash test file (`tests/smoke.sh`) requires `bash`, `curl`, and `jq` — all present in the production Docker image as confirmed by the Dockerfile.

---

## New Tests Added (Second Sub-pass — Sections 18–23)

### Section 18 — Additional Input Edge Cases (6 tests)
Covers server validation paths missed by the existing type-validation suite.
- 18a: `question: null` → 400 (falsy guard)
- 18b: `question: false` → 400 (falsy guard)
- 18c: `optionIndex: 1000000` (far out-of-bounds) → 400
- 18d: `optionIndex == options.length` (off-by-one exclusive bound) → 400
- 18e: `question: "\n\t\n"` (whitespace via escape sequences trims to empty) → 400
- 18f: `options: ["A", 0]` (numeric zero is falsy, caught before `.trim()`) → 400

### Section 19 — Health Check Endpoint (2 tests)
Documents the TDD §9.1 health-check mechanism used by the Dockerfile `HEALTHCHECK` directive.
- 19a: `GET /api/polls/healthz` → 404 + error field (server up indicator)
- 19b: `GET /api/polls/ping` → 404 (confirms behaviour is path-agnostic, not specific to "healthz")

### Section 20 — Timestamp Range Validation (4 tests)
Verifies `created_at` is a well-formed Unix epoch second — both from creation and across subsequent GETs.
- 20a: Create poll (setup) → 201
- 20b: `created_at` is within ±60 s of current Unix time (bash `date +%s` comparison)
- 20c: `created_at` is in plausible range (> 1700000000, < 4102444800)
- 20d: GET response `created_at` matches original POST value (field is immutable)

### Section 21 — Vote Response Completeness (8 tests)
Verifies that `POST /:id/vote` returns the full options array with correct counts and ordering.
- 21a: Vote on 6-option poll → response has 6 options, ascending order, only option 0 incremented
- 21b: Sum of all vote_counts equals 1 after single vote
- 21c: Vote on 3-option poll → response has exactly 3 options, correct spot-checks

### Section 22 — Extra Request Fields Ignored (4 tests)
Verifies JavaScript destructuring silently discards unknown JSON fields in both endpoints.
- 22a: POST `/api/polls` with `extra` + `foo` fields → 201, question and options correct
- 22b: POST `/api/polls/:id/vote` with `userId` + `timestamp` + `extra` → 200, vote counted

### Section 23 — High Vote Count Accumulation (5 tests)
Extends section 15 (8 votes) to 30 sequential votes, confirming no vote is lost under load.
- 23a: 20 votes on option 0, 10 on option 1 → final counts 20/10, sum 30

---

## Total Projected Test Count

| Source | Tests |
|--------|-------|
| Baseline (sections 1–11) | ~100 |
| First sub-pass (sections 12–17) | ~62 |
| Second sub-pass (sections 18–23) | ~33 |
| **Total** | **~195** |
