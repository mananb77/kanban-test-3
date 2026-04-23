# Edge Case Review — QA Review Iteration 2

**Project**: Quick Poll (mananb77/kanban-test-3)
**Issue**: #1
**Review Date**: 2026-04-23

---

## Legend
- ✅ Covered — test exists and passes
- ⚠️ Covered — test exists but currently FAILING
- ❌ Not covered — no test exists

---

## POST /api/polls — Edge Cases

### Question field

| Case | Value | Expected | api.test.mjs | smoke.sh | Status |
|------|-------|----------|-------------|---------|--------|
| Whitespace only (spaces) | `"   "` | 400 | ✅ (whitespace-only question variants) | ✅ 2f | ✅ |
| Whitespace only (tabs) | `"\t"` | 400 | ✅ | ✅ 18e | ✅ |
| Whitespace only (mixed) | `"\n\t\n"` | 400 | ✅ | ✅ 18e | ✅ |
| null | `null` | 400 | ✅ (null question) | ✅ 18a | ✅ |
| boolean false | `false` | 400 | ✅ (boolean false question) | ✅ 18b | ✅ |
| Empty string | `""` | 400 | ❌ | ❌ | **MISSING** |
| Missing key | `{options:...}` | 400 | ❌ | ✅ 2e | **api.test.mjs gap** |
| Integer | `42` | 400 | ❌ | ❌ | **MISSING** |
| Object | `{text:"Q"}` | 400 | ❌ | ❌ | **MISSING** |
| Single char | `"?"` | 201 | ✅ (single-character question) | ✅ 14c | ✅ |
| 500 chars | `"a".repeat(500)` | 201 | ✅ | ✅ 26a | ✅ |
| Unicode / emoji | `"Favourite? 🎉"` | 201 | ✅ | ✅ 13a | ✅ |
| HTML tags | `"<b>Bold</b>"` | 201 (verbatim) | ✅ | ✅ 13d | ✅ |
| Newline within text | `"Line1\nLine2"` | 201 | ❌ | ❌ | **MISSING** (not required by spec) |

### Options field

| Case | Value | Expected | api.test.mjs | smoke.sh | Status |
|------|-------|----------|-------------|---------|--------|
| 0 options | `[]` | 400 | ✅ (invalid option counts) | ✅ 8f | ✅ |
| 1 option | `["A"]` | 400 | ✅ | ✅ 2g | ✅ |
| 2 options (min) | `["A","B"]` | 201 | ✅ | ✅ 2a | ✅ |
| 3 options | `["A","B","C"]` | 201 | ✅ (full workflow) | ✅ 9a | ✅ |
| 4 options | `["A","B","C","D"]` | 201 | ✅ | ✅ 9g | ✅ |
| 5 options | `["A","B","C","D","E"]` | 201 | ✅ | ✅ 9d | ✅ |
| 6 options (max) | `["A","B","C","D","E","F"]` | 201 | ✅ (schema test) | ✅ 2b | ✅ |
| 7 options (over) | `["A"..."G"]` | 400 | ✅ | ✅ 2h | ✅ |
| Missing key | `{question:"Q?"}` | 400 | ❌ | ✅ 2k | **api.test.mjs gap** |
| null | `null` | 400 | ❌ | ❌ | **MISSING** |
| String (not array) | `"A,B"` | 400 | ❌ | ✅ 8d | **api.test.mjs gap** |
| Object (not array) | `{0:"A",1:"B"}` | 400 | ❌ | ✅ 8g | **api.test.mjs gap** |
| Duplicate options | `["Same","Same"]` | 201 | ✅ | ✅ 14b | ✅ |
| Empty string option | `["A",""]` | 400 | ❌ (covered by whitespace variants) | ✅ 2i | **api.test.mjs gap** |
| Whitespace-only option | `["A","  "]` | 400 | ❌ | ✅ 2j | **api.test.mjs gap** |
| null element | `["A", null]` | 400 | ✅ (options containing numeric zero → catches falsy) | ✅ 8e | ✅ (partial — null check in smoke) |
| numeric element | `["A", 0]` | 400 | ✅ (numeric zero) | ✅ 18f | ✅ |
| Option 500 chars | `["a".repeat(500), "B"]` | 201 | ✅ | ✅ 26b | ✅ |

### Request body type

| Case | Body type | Expected | api.test.mjs | smoke.sh | Status |
|------|-----------|----------|-------------|---------|--------|
| Valid object | `{question:...,options:...}` | 201 | ✅ | ✅ | ✅ |
| JSON number | `42` | 400 | ⚠️ 25a (FAILING — gets 500) | ⚠️ 25a (FAILING) | **BUG** |
| JSON string | `"text"` | 400 | ⚠️ 25b (FAILING — gets 500) | ⚠️ 25b (FAILING) | **BUG** |
| JSON array | `[{...}]` | 400 | ✅ 25c | ✅ 25c | ✅ |
| Extra fields | `{...extra:true}` | 201 (ignored) | ✅ | ✅ 22a | ✅ |

---

## POST /api/polls/:id/vote — Edge Cases

### optionIndex field

| Case | Value | Expected | api.test.mjs | smoke.sh | Status |
|------|-------|----------|-------------|---------|--------|
| 0 (first, valid) | `0` | 200 | ✅ (full workflow) | ✅ 4a, 14d | ✅ |
| N-1 (last, valid) | `options.length - 1` | 200 | ✅ (cycling test) | ✅ 4d, 9b, 9e | ✅ |
| N (off-by-one) | `options.length` | 400 | ✅ (off-by-one) | ✅ 18d, 9c, 9f | ✅ |
| -1 (negative) | `-1` | 400 | ✅ (invalid types) | ✅ 4e | ✅ |
| 99 (large OOB) | `99` | 400 | ✅ | ✅ 4f | ✅ |
| 1000000 (very large) | `1000000` | 400 | ✅ | ✅ 18c | ✅ |
| 0.5 (float) | `0.5` | 400 | ✅ | ✅ 4g | ✅ |
| "0" (string) | `"0"` | 400 | ✅ | ✅ 8a | ✅ |
| null | `null` | 400 | ✅ | ✅ 8b | ✅ |
| true (boolean) | `true` | 400 | ✅ | ✅ 8c | ✅ |
| false (boolean) | `false` | 400 | ✅ | — | ✅ |
| Missing key | `{}` | 400 | — | ✅ 4h | Smoke only |
| MAX_SAFE_INTEGER | `9007199254740991` | 400 | ❌ | ❌ | **MISSING** (not specified) |

### Poll ID

| Case | ID | Expected | api.test.mjs | smoke.sh | Status |
|------|-----|----------|-------------|---------|--------|
| Valid UUID, existing | proper UUID | 200 | ✅ | ✅ | ✅ |
| Valid UUID, nonexistent | `00000000-0000-0000-0000-000000000000` | 404 | ✅ | ✅ 4i | ✅ |
| Non-UUID string | `"not-a-uuid"` | 404 | ✅ (not found handling) | ✅ 12d | ✅ |
| SQL injection | `1%27%20OR...` | 404 | — | ✅ 12c | Smoke only |
| Numeric string | `"12345"` | 404 | ✅ (non-UUID shaped) | ✅ 12b | ✅ |

### Request body type (vote endpoint)

| Case | Body type | Expected | api.test.mjs | smoke.sh | Status |
|------|-----------|----------|-------------|---------|--------|
| Valid object | `{optionIndex:0}` | 200 | ✅ | ✅ | ✅ |
| JSON number | `42` | 400 | ⚠️ 25d (FAILING — gets 500) | ⚠️ 25d | **BUG** |
| JSON string | `"text"` | 400 | ⚠️ 25e (FAILING — gets 500) | ⚠️ 25e | **BUG** |
| JSON array | `[{optionIndex:0}]` | 400 | ✅ 25f | ✅ 25f | ✅ |
| Extra fields | `{optionIndex:0,extra:true}` | 200 (ignored) | ✅ | ✅ 22b | ✅ |

---

## GET /api/polls/:id — Edge Cases

| Case | Input | Expected | api.test.mjs | smoke.sh | Status |
|------|-------|----------|-------------|---------|--------|
| Valid UUID, existing | proper UUID | 200 + poll data | ✅ | ✅ 3a | ✅ |
| Valid UUID, nonexistent | `00000000-...` | 404 | ✅ | ✅ 3b | ✅ |
| Non-UUID string | `"not-a-uuid"` | 404 | ✅ | ✅ 12a | ✅ |
| Numeric string | `"12345"` | 404 | ✅ | ✅ 12b | ✅ |
| `"healthz"` sentinel | `/api/polls/healthz` | 404 | ✅ | ✅ 19a | ✅ |
| `"ping"` sentinel | `/api/polls/ping` | 404 | ✅ | ✅ 19b | ✅ |
| SQL injection | `1' OR '1'='1` | 404 | — | ✅ 12c | Smoke only |
| Idempotent (multiple GETs) | same UUID | 200 same data | ✅ (idempotent GET) | ✅ 17c | ✅ |

---

## HTTP Method Edge Cases

| Method | Path | Expected | api.test.mjs | smoke.sh | Status |
|--------|------|----------|-------------|---------|--------|
| GET | `/` | 200 + HTML | — | ✅ 1 | ✅ |
| GET | `/api/polls/:id` | 200/404 | ✅ | ✅ | ✅ |
| GET | `/api/polls` (no ID) | 200 SPA | ✅ | ✅ 24d | ✅ |
| GET | `/poll/:id` | 200 SPA | ✅ | ✅ 10a | ✅ |
| GET | `/unknown-path` | 200 SPA | — | ✅ 10b | ✅ |
| POST | `/api/polls` | 201/400 | ✅ | ✅ | ✅ |
| POST | `/api/polls/:id/vote` | 200/400/404 | ✅ | ✅ | ✅ |
| POST | `/api/polls/:id` (no /vote) | 404 | ✅ | ✅ 24e | ✅ |
| PUT | `/api/polls` | 404 | ✅ | ✅ 24a | ✅ |
| DELETE | `/api/polls/:id` | 404 | ✅ | ✅ 24b | ✅ |
| PATCH | `/api/polls/:id/vote` | 404 | ✅ | ✅ 24c | ✅ |
| HEAD | `/api/polls/:id` | (not tested) | ❌ | ❌ | **MISSING** (not specified) |
| OPTIONS | `/api/polls` | (not tested) | ❌ | ❌ | **MISSING** (not specified) |

---

## Concurrency Edge Cases

| Case | Description | api.test.mjs | smoke.sh | Status |
|------|-------------|-------------|---------|--------|
| 10 concurrent votes same option | All counted | ✅ | ❌ | Partial |
| 5+5 concurrent votes split options | Each counted independently | ✅ | ❌ | Partial |
| 5 concurrent poll creates | All unique IDs | ✅ | ❌ | Partial |
| Concurrent + sequential mix | Not tested | ❌ | ❌ | **MISSING** |

---

## Data Integrity Edge Cases

| Case | Description | api.test.mjs | smoke.sh | Status |
|------|-------------|-------------|---------|--------|
| Votes persist across multiple GETs | ✅ | ✅ 5 | ✅ | ✅ |
| Poll isolation (cross-poll vote leakage) | ✅ | ✅ 6 | ✅ | ✅ |
| High vote count (30+) | ✅ | ✅ 23 | ✅ | ✅ |
| Duplicate question text → different IDs | ✅ | ✅ 14a | ✅ | ✅ |
| Vote on just-deleted poll | Not possible (no DELETE endpoint) | N/A | N/A | N/A |
| DB not initialized | Would return 500 | ❌ | ❌ | Untestable via integration |

---

## Summary: Edge Cases by Status

| Status | Count |
|--------|-------|
| ✅ Covered (passing) | 65 |
| ⚠️ Covered (failing — server bug) | 4 |
| ❌ Missing (required by spec) | 3 |
| ❌ Missing (not specified, low priority) | 6 |

### Required Missing Edge Cases (to add in iteration 3)
1. `POST /api/polls` with empty string `""` question
2. `POST /api/polls` with integer `42` as question
3. `POST /api/polls` with null options array

### Not Specified / Not Required
4. `HEAD` method behavior
5. `OPTIONS` method behavior
6. `MAX_SAFE_INTEGER` as optionIndex
7. Newline characters within question/option
8. Mixed concurrent+sequential vote scenario
