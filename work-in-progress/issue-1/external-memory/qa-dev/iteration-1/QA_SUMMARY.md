# QA Summary — Dev Iteration 1 (updated by qa-dev iteration 1)

**Date**: 2026-04-22  
**Phase**: qa-dev  
**Iteration**: 1  
**Branch**: main  
**Repository**: mananb77/kanban-test-3

---

## What Was Done

Extended the existing `tests/smoke.sh` (sections 1–6, ~56 assertions) with five new sections (7–11) covering coverage gaps identified against the TDD, PRD, dev-review gap analysis, and implementation code.

Three new bash helper functions were added to support the extended sections:
- `assert_contains` — substring match for header value assertions
- `http_get_type` — curl GET returning `%{content_type}` write-out
- `http_post_type` — curl POST returning `%{content_type}` write-out

---

## Files Created / Modified

| File | Action | Description |
|------|--------|-------------|
| `tests/smoke.sh` | Modified | Added helpers + sections 7–11 (41 new assertions) |

---

## Test Coverage Summary

### 1. Frontend (2 assertions) — *unchanged*
- `GET /` returns HTTP 200 with `<div id="root">` React mount point

### 2. POST /api/polls — Create Poll (21 assertions) — *unchanged*
- Happy path 2-option and 6-option polls
- Whitespace trimming for question and option text
- Validation errors: missing keys, whitespace-only, 1 option, 7 options, empty/whitespace options

### 3. GET /api/polls/:id — Fetch Poll (8 assertions) — *unchanged*
- Valid fetch → 200 with correct structure
- Nonexistent id → 404 with error field

### 4. POST /api/polls/:id/vote — Cast Vote (17 assertions) — *unchanged*
- Valid votes (indices 0, 1, last of 6), accumulation, all validation errors, 404 on bad poll

### 5. Persistence (4 assertions) — *unchanged*
- 3 votes across 2 options survive re-fetch

### 6. Poll Isolation (4 assertions) — *unchanged*
- Votes on one poll don't affect another

### 7. Response Schema Completeness (11 assertions) — **NEW**
**Gap addressed:** Options object shape (`id`, `poll_id` fields) was not verified; `created_at` integer range was unchecked; option ordering guarantee was untested.
- `options[0].id` is a number (autoincrement integer)
- `options[0].poll_id` equals the parent poll UUID
- `options[0]` has `text` and `vote_count` fields (`has()` checks)
- `created_at` is a positive integer > 1700000000 (valid Unix timestamp)
- Option IDs ordered ascending (insertion order preserved)
- Vote response carries same full schema (id, poll_id, question fields)

### 8. Additional Input Type Validation (8 assertions) — **NEW**
**Gap addressed:** JS type coercion traps were not covered — `Number.isInteger` behaviour with strings, null, booleans; `Array.isArray` behaviour with strings and plain objects.
- `optionIndex` as string `"0"` → 400 with error field
- `optionIndex` as `null` → 400
- `optionIndex` as `true` (boolean) → 400
- `options` as string `"A,B"` → 400
- `options` with `null` element → 400
- `options` as empty array `[]` → 400
- `options` as plain object `{"0":"A","1":"B"}` → 400

### 9. Middle-Boundary Poll Sizes (13 assertions) — **NEW**
**Gap addressed:** Only min (2) and max (6) option counts were tested; 3, 4, 5 were untested, including vote-index boundary rejection at `length` for each size.
- 3-option poll: create (201, 3 options), vote index 2 (last, 200), reject index 3 (400)
- 5-option poll: create (201, 5 options), vote index 4 (last, 200), reject index 5 (400)
- 4-option poll: create (201, 4 options)

### 10. SPA Route Fallback (4 assertions) — **NEW**
**Gap addressed:** The `app.get('*', ...)` catch-all that enables React Router client-side navigation was not exercised.
- `GET /poll/<uuid>` → 200 with React root element
- `GET /unknown-route-xyz` → 200 with React root element

### 11. Content-Type Headers (5 assertions) — **NEW**
**Gap addressed:** HTTP `Content-Type` response headers were never verified; all JSON endpoints (success and error) must return `application/json`.
- `POST /api/polls` 201 → `application/json`
- `GET /api/polls/:id` 200 → `application/json`
- `POST /api/polls/:id/vote` 200 → `application/json`
- `POST /api/polls` 400 → `application/json`
- `GET /api/polls/:id` 404 → `application/json`

---

## Total Assertions

| Sections | Assertions |
|----------|-----------|
| Original (1–6) | 56 |
| New (7–11) | 41 |
| **Grand total** | **97** |

---

## Acceptance Criteria Coverage

| AC | Description | Covered by |
|----|-------------|------------|
| AC1 | Single-command startup, single port | Dockerfile + docker-compose (infrastructure) |
| AC2 | Create poll with 2–6 options | §2a, §2b, §2g, §2h, §9 (all sizes 2–6) |
| AC3 | Vote and see updated results | §4a–4c, §5, §7f, §9b, §9e |
| AC4 | Share link, others can vote | §6 (isolation), §10 (SPA fallback) |
| AC5 | Data persists across requests | §5 |
| AC6 | Responsive / clean UI | §1 (static serving), §10 (SPA routing) |

---

## Remaining Known Gaps

- **No DOM/browser-level UI tests**: React component rendering and interactive flows (PollForm, PollVote, PollResults, copy-link) cannot be exercised at the HTTP level.
- **No server-restart persistence test**: §5 verifies in-process SQLite writes; testing across a container restart requires Docker orchestration.
- **No concurrency tests**: SQLite WAL mode is configured but not exercised under parallel writes.
