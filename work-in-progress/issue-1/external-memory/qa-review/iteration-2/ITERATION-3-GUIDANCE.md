# Iteration 3 Guidance — QA Review Iteration 2

**Project**: Quick Poll (mananb77/kanban-test-3)
**Issue**: #1
**For**: qa-dev agent, iteration 3
**Review Date**: 2026-04-23

---

## Executive Summary

The test suite is in excellent shape overall (242/246 passing, 98.4%). There is exactly **one server bug** causing 4 test failures that must be fixed before all tests can pass. After that fix, a small set of additional tests can be added to close remaining gaps in `api.test.mjs`.

**Do this in order:**
1. Fix the server bug in `server/index.js` (HIGH priority — 4 tests depend on this)
2. Add 3–5 missing test cases to `api.test.mjs` (MEDIUM priority)
3. Verify all tests pass (246/246 target)

---

## Task 1: Fix Server Bug — `server/index.js`

### Root Cause

`express.json()` uses `strict: true` by default (from `body-parser`). When the POST body is a JSON primitive (number or string — not array or object), body-parser calls `next(err)` where `err.status = 400`. The current error handler in `server/index.js` ignores `err.status` and always returns `500`.

### Exact Fix

**File**: `server/index.js`
**Lines 19–22** — replace the existing 4-argument error handler:

```js
// CURRENT (broken):
app.use((err, _req, res, _next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});
```

```js
// FIXED:
app.use((err, _req, res, _next) => {
  console.error(err.stack);
  const status = err.status || err.statusCode || 500;
  res.status(status).json({ error: err.message || 'Internal server error' });
});
```

### Why This Works

- For JSON number/string bodies: body-parser sets `err.status = 400` and `err.message = "invalid json"` or similar → handler returns 400 ✅
- For all other errors (DB crash, etc.): `err.status` is undefined → falls back to 500 ✅
- For JSON arrays/objects: body-parser accepts them → error handler never called ✅

### Failing Tests Fixed by This Change

After applying the fix, these 4 tests will pass (currently returning 500 instead of 400):

| Test | Location | Body sent | Expected |
|------|----------|-----------|---------|
| 25a | api.test.mjs + smoke.sh | `42` (JSON number) | 400 |
| 25b | api.test.mjs + smoke.sh | `"just a string"` | 400 |
| 25d | api.test.mjs + smoke.sh | `42` (vote endpoint) | 400 |
| 25e | api.test.mjs + smoke.sh | `"string"` (vote endpoint) | 400 |

---

## Task 2: Add Missing Tests to `api.test.mjs`

Add the following tests to the existing `Input validation` describe block in `tests/api.test.mjs`. Insert after the existing `unicode and emoji` test (line 419) or as a new grouped set.

### 2a. Missing question key (GAP-FR5-001)

```js
test('missing question key returns 400', async () => {
  const { status, body } = await apiPost('/api/polls', { options: ['A', 'B'] });
  assert.equal(status, 400, `Expected 400 for missing question key, got ${status}`);
  assert.equal(typeof body.error, 'string', 'Error response must have error field');
});
```

### 2b. Missing options key (GAP-FR5-002)

```js
test('missing options key returns 400', async () => {
  const { status, body } = await apiPost('/api/polls', { question: 'Q?' });
  assert.equal(status, 400, `Expected 400 for missing options key, got ${status}`);
  assert.equal(typeof body.error, 'string', 'Error response must have error field');
});
```

### 2c. Options as non-array types (GAP-FR5-003)

```js
test('options as non-array types return 400', async () => {
  const cases = [
    { options: 'A,B',              desc: 'string "A,B"' },
    { options: { 0: 'A', 1: 'B' }, desc: 'object {0:"A",1:"B"}' },
    { options: null,               desc: 'null' },
  ];
  for (const { options, desc } of cases) {
    const { status } = await apiPost('/api/polls', { question: 'Q?', options });
    assert.equal(status, 400, `Expected 400 for options as ${desc}, got ${status}`);
  }
});
```

### 2d. Empty string question (GAP-FR5-005) — optional

```js
test('empty string question returns 400', async () => {
  const { status, body } = await apiPost('/api/polls', { question: '', options: ['A', 'B'] });
  assert.equal(status, 400, 'Empty string question should be rejected (trims to empty)');
  assert.equal(typeof body.error, 'string');
});
```

### 2e. Empty string and whitespace-only options (closes gap in api.test.mjs)

```js
test('empty string and whitespace-only options return 400', async () => {
  const cases = [
    { options: ['A', ''],     desc: 'empty string option' },
    { options: ['A', '   '],  desc: 'whitespace-only option' },
    { options: ['A', '\t\n'], desc: 'tab+newline option' },
  ];
  for (const { options, desc } of cases) {
    const { status } = await apiPost('/api/polls', { question: 'Q?', options });
    assert.equal(status, 400, `Expected 400 for ${desc}, got ${status}`);
  }
});
```

---

## Task 3: Verify Test Run

After applying both changes, run the full test suite and confirm all tests pass:

```bash
# Run Node.js integration tests
BASE_URL=http://localhost:3001 node --test tests/api.test.mjs

# Run smoke tests
BASE_URL=http://localhost:3001 bash tests/smoke.sh
```

**Expected result**:
- `api.test.mjs`: 57 tests pass (52 existing + 5 new), 0 fail
- `smoke.sh`: 246 assertions pass (242 existing + 4 now-fixed), 0 fail

---

## Task 4: Optional — Add Content-Type Header Tests to `api.test.mjs`

The `Content-Type: application/json` verification exists in `smoke.sh` (section 11) but not in `api.test.mjs`. This is already tested; adding it to api.test.mjs is optional for completeness:

```js
// Already covered in existing 'Response schema validation' describe block — no action needed.
// The existing test 'Content-Type is application/json on all API endpoints' covers this.
```

**No action needed** — already covered at line 262 in api.test.mjs.

---

## What NOT to Change

- **Do not** add frontend/React component tests — TDD §14 specifies manual-only
- **Do not** add performance timing tests — excluded from scope
- **Do not** change `smoke.sh` for the failing tests — the server fix will automatically make them pass
- **Do not** add a `npm test` script unless explicitly requested — current setup uses direct node/bash invocation
- **Do not** modify test framework — `node:test` built-in is correct for Node >= 18

---

## Verification Checklist

After iteration 3 implementation:

- [ ] `server/index.js` error handler checks `err.status` before defaulting to 500
- [ ] `tests/api.test.mjs` has at least 3 new tests (missing key variants)
- [ ] `node --test tests/api.test.mjs` exits 0
- [ ] `bash tests/smoke.sh` exits 0
- [ ] No regressions in sections 1–24, 26, 27 of smoke.sh
- [ ] Git commit created with all changes

---

## Expected Final State After Iteration 3

| Metric | Before | After |
|--------|--------|-------|
| api.test.mjs tests | 52 | 57 |
| api.test.mjs passing | 48 (4 failing) | 57 (0 failing) |
| smoke.sh passing | 242 (4 failing) | 246 (0 failing) |
| Server bug | Present | Fixed |
| Overall pass rate | 98.4% | 100% |
