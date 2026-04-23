# Implementation Summary — Dev Iteration 4

**Issue**: #1 — Quick Poll App
**Date**: 2026-04-23

## Changes Made

### 1. Server Bug Fix — `server/index.js`

**Root cause**: `express.json()` with `strict: true` (default) calls `next(err)` with `err.status = 400` for non-object/non-array JSON bodies (numbers and strings). The existing error handler always returned 500 regardless of `err.status`.

**Fix** (lines 19–23):
```js
// Before:
app.use((err, _req, res, _next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

// After:
app.use((err, _req, res, _next) => {
  console.error(err.stack);
  const status = err.status || err.statusCode || 500;
  res.status(status).json({ error: err.message || 'Internal server error' });
});
```

**Tests fixed** (were returning 500, now return 400 correctly):
- `25a`: POST /api/polls with JSON number body
- `25b`: POST /api/polls with JSON string body
- `25d`: POST /api/polls/:id/vote with JSON number body
- `25e`: POST /api/polls/:id/vote with JSON string body

### 2. New Tests — `tests/api.test.mjs`

Added 5 tests to the `Input validation` describe block (after the HTML special characters test):

| Test | Gap ID | Validates |
|------|--------|-----------|
| `missing question key returns 400` | GAP-FR5-001 | `{ options: ['A','B'] }` → 400 |
| `missing options key returns 400` | GAP-FR5-002 | `{ question: 'Q?' }` → 400 |
| `options as non-array types return 400` | GAP-FR5-003 | string, object, null → 400 |
| `empty string question returns 400` | GAP-FR5-005 | `{ question: '' }` → 400 |
| `empty and whitespace-only options return 400` | additional | `['A','']`, `['A','   ']`, `['A','\t\n']` → 400 |

## Requirements Coverage

All 8 FRs and 5 NFRs remain fully covered. The new tests improve FR5 (input validation) coverage parity between `api.test.mjs` and `smoke.sh`.

## Files Modified

| File | Change |
|------|--------|
| `server/index.js` | Error handler forwards `err.status`; 1 line added, 1 line changed |
| `tests/api.test.mjs` | 5 new tests added to `Input validation` block; 42 lines added |
