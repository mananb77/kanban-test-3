# Test Gap Analysis — QA Review Iteration 2

**Project**: Quick Poll (mananb77/kanban-test-3)
**Issue**: #1
**Review Date**: 2026-04-23

This document maps each requirement from the PRD and TDD against the existing test coverage, identifying gaps.

---

## Requirement Traceability Matrix

### Functional Requirements (FR1–FR8)

| Req ID | Description | api.test.mjs | smoke.sh | Gap Level |
|--------|-------------|-------------|---------|-----------|
| FR1 | Create poll with question and 2–6 options | ✅ Full workflow, input validation | ✅ Sections 2, 9, 14 | NONE |
| FR2 | Generate unique shareable URL (UUID-based ID) | ✅ Concurrent creation (unique IDs), duplicate question test | ✅ Sections 2a, 14a | NONE |
| FR3 | Anonymous vote submission (no authentication) | ✅ Vote endpoint tested without auth headers | ✅ Section 4 | NONE |
| FR4 | Vote count persists in SQLite | ✅ Sections: persistence, accumulation | ✅ Sections 5, 15, 23 | NONE |
| FR5 | Input validation: question required, 2–6 options, non-empty | ✅ Whitespace, counts, types | ✅ Sections 2e–2k, 4e–4i, 8 | PARTIAL — see GAP-FR5-* below |
| FR6 | Fetch poll by ID returning question, options, vote counts | ✅ Schema validation, round-trip, consistency | ✅ Sections 3, 7, 16, 17 | NONE |
| FR7 | Serve production React SPA from Express (static files) | ✅ SPA fallback in HTTP method block | ✅ Sections 1, 10, 24d | NONE |
| FR8 | Dockerfile HEALTHCHECK using `/api/polls/healthz` | ✅ Health check block | ✅ Section 19 | NONE |

---

### FR5 Sub-requirement Gaps

#### GAP-FR5-001 — Missing question key
**Requirement**: POST /api/polls should return 400 if `question` key is absent from request body.
**Covered in**: smoke.sh section 2e (`{"options":["A","B"]}`)
**Missing in**: `api.test.mjs` — no test for missing `question` key
**Priority**: MEDIUM
**Test to add** (api.test.mjs `Input validation` block):
```js
test('missing question key returns 400', async () => {
  const { status, body } = await apiPost('/api/polls', { options: ['A', 'B'] });
  assert.equal(status, 400);
  assert.equal(typeof body.error, 'string');
});
```

#### GAP-FR5-002 — Missing options key
**Requirement**: POST /api/polls should return 400 if `options` key is absent.
**Covered in**: smoke.sh section 2k (`{"question":"Q?"}`)
**Missing in**: `api.test.mjs`
**Priority**: MEDIUM
**Test to add**:
```js
test('missing options key returns 400', async () => {
  const { status, body } = await apiPost('/api/polls', { question: 'Q?' });
  assert.equal(status, 400);
  assert.equal(typeof body.error, 'string');
});
```

#### GAP-FR5-003 — Options as non-array types (string, object)
**Requirement**: `options` must be an Array; other types should return 400.
**Covered in**: smoke.sh sections 8d (`"options":"A,B"`), 8g (`"options":{"0":"A","1":"B"}`)
**Missing in**: `api.test.mjs`
**Priority**: MEDIUM
**Test to add**:
```js
test('options as non-array types return 400', async () => {
  const cases = [
    { options: 'A,B',           desc: 'string' },
    { options: { 0: 'A', 1: 'B' }, desc: 'object' },
    { options: null,            desc: 'null' },
  ];
  for (const { options, desc } of cases) {
    const { status } = await apiPost('/api/polls', { question: 'Q?', options });
    assert.equal(status, 400, `Expected 400 for options as ${desc}`);
  }
});
```

#### GAP-FR5-004 — Question as numeric/object type
**Requirement**: `question` must be a string; numeric or object types should return 400.
**Covered in**: smoke.sh 18b covers `false`, api.test.mjs covers `null` and `false`
**Missing**: `question` as an integer (e.g., `42`) or object
**Priority**: LOW
**Test to add**:
```js
test('numeric question returns 400', async () => {
  const { status } = await apiPost('/api/polls', { question: 42, options: ['A', 'B'] });
  assert.equal(status, 400);
});
```

#### GAP-FR5-005 — Empty string question (not just whitespace)
**Requirement**: Empty string should return 400 (after trimming it becomes empty).
**Covered in**: smoke.sh section 2f covers whitespace-only; api.test.mjs covers whitespace variants
**Missing**: Explicit `""` empty string test
**Priority**: LOW
**Note**: `""` trims to `""`, which is falsy — current code `!question.trim()` covers it. Explicit test adds documentation value.
**Test to add**:
```js
test('empty string question returns 400', async () => {
  const { status } = await apiPost('/api/polls', { question: '', options: ['A', 'B'] });
  assert.equal(status, 400);
});
```

---

### Non-Functional Requirements (NFR1–NFR5)

| Req ID | Description | api.test.mjs | smoke.sh | Gap Level |
|--------|-------------|-------------|---------|-----------|
| NFR1 | Performance: poll creation < 500ms, load < 1000ms | ❌ No timing assertions | ❌ No timing | HIGH |
| NFR2 | Reliability: handles concurrent votes | ✅ Concurrent vote handling block | ❌ No concurrent curl | PARTIAL |
| NFR3 | Usability: responsive UI, mobile-friendly | ❌ No UI tests | ❌ No UI tests | N/A (manual per TDD) |
| NFR4 | Maintainability: clear code, documented | N/A | N/A | N/A |
| NFR5 | Security: SQL injection, XSS protection | ✅ Parameterized queries verified indirectly | ✅ Section 12c SQL injection | PARTIAL — see GAP-NFR5-* |

---

### NFR Gaps

#### GAP-NFR1-001 — No performance assertions
**Requirement**: Poll creation < 500ms (NFR1.1), poll load < 1000ms (NFR1.2).
**Missing**: Any timing-based test assertions.
**Priority**: LOW (no automated performance tests specified in TDD testing strategy)
**Note**: TDD §14 specifies "manual acceptance testing" only. However, a basic smoke assertion could be added.
**Suggested test** (smoke.sh or api.test.mjs):
```js
test('poll creation completes within 500ms', async () => {
  const start = Date.now();
  await createPoll('Perf test?', ['A', 'B']);
  const elapsed = Date.now() - start;
  assert.ok(elapsed < 500, `Creation took ${elapsed}ms, expected < 500ms`);
});
```

#### GAP-NFR2-001 — Concurrent tests only in api.test.mjs
**Requirement**: Server handles concurrent votes correctly (NFR2).
**Covered in**: api.test.mjs (10 concurrent votes, split concurrent votes)
**Missing in**: smoke.sh (all vote tests are sequential curl calls)
**Priority**: LOW (concurrent testing is hard in bash)

#### GAP-NFR5-001 — XSS in API responses not explicitly tested
**Requirement**: NFR5 specifies XSS protection.
**Covered in**: HTML entity test (api.test.mjs `HTML special characters` test, smoke.sh section 13d) — verifies raw storage
**Gap**: No test verifies Content-Security-Policy header or that HTML is escaped in a browser context
**Priority**: LOW (API-level XSS protection is out of scope; frontend rendering is untested per spec)

---

### Acceptance Criteria (AC1–AC6)

| AC ID | Description | Test Coverage | Status |
|-------|-------------|---------------|--------|
| AC1 | Poll creation form → unique URL on success | ✅ Full workflow integration | COVERED |
| AC2 | Poll page shows vote interface, counts update | ✅ Vote + GET response consistency | COVERED (API) |
| AC3 | Votes persist across browser sessions | ✅ Persistence sections | COVERED (API) |
| AC4 | Responsive UI: 320px to 1440px | ❌ No automated test | MANUAL ONLY |
| AC5 | SPA routing works for direct /poll/:id navigation | ✅ SPA fallback sections | COVERED |
| AC6 | Docker image production startup | ✅ Health check (indirect) | COVERED (indirect) |

---

## Summary of Gaps by Priority

### HIGH Priority (blocking release)
1. **GAP-SERVER-001**: 4 tests failing due to server error handler bug — fix `server/index.js` to forward `err.status`

### MEDIUM Priority (test coverage gaps)
2. **GAP-FR5-001**: Missing `question` key test in api.test.mjs
3. **GAP-FR5-002**: Missing `options` key test in api.test.mjs
4. **GAP-FR5-003**: Options as non-array types test in api.test.mjs

### LOW Priority (nice-to-have)
5. **GAP-FR5-004**: Numeric question type test
6. **GAP-FR5-005**: Explicit empty string question test
7. **GAP-NFR1-001**: Basic performance timing assertion
8. **GAP-NFR5-001**: XSS/CSP header verification

---

## Gaps NOT Present (Good Coverage)

The following areas are comprehensively covered and require no additional tests:
- Vote count accumulation (sequential and concurrent)
- Data isolation between polls
- UUID uniqueness on concurrent creation
- Timestamp validity range
- Response schema completeness (all 4 fields, exact key count)
- Content-Type headers
- SPA fallback routing
- SQL injection via poll ID
- Unicode/emoji/HTML round-trip fidelity
- All valid option count boundaries (2–6)
- All optionIndex boundary values (0, N-1, N, -1, large)
- Long string preservation (500 chars)
- Whitespace trimming behavior
