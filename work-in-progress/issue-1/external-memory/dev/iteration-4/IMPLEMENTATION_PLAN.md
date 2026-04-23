# Implementation Plan — Dev Iteration 4

**Issue**: #1 — Quick Poll App
**Date**: 2026-04-23

## Objective

Fix server bug causing 4 test failures + add 5 missing tests to reach 100% test pass rate.

## Tasks

- [x] **Task 1**: Fix `server/index.js` error handler to forward `err.status`
  - File: `server/index.js` lines 19–22
  - Change: `res.status(500)` → `res.status(err.status || err.statusCode || 500)`
  - Fixes tests: 25a, 25b, 25d, 25e (JSON number/string bodies returning 500 instead of 400)

- [x] **Task 2**: Add 5 missing tests to `tests/api.test.mjs`
  - `missing question key returns 400` (GAP-FR5-001)
  - `missing options key returns 400` (GAP-FR5-002)
  - `options as non-array types return 400` (GAP-FR5-003)
  - `empty string question returns 400` (GAP-FR5-005)
  - `empty and whitespace-only options return 400` (additional coverage)
  - All inserted into existing `Input validation` describe block after line 429

- [x] **Task 3**: Create WIP artifacts and commit

## Expected Final State

| Suite | Before | After |
|-------|--------|-------|
| api.test.mjs | 52 tests, 4 failing | 57 tests, 0 failing |
| smoke.sh assertions | 246, 4 failing | 246, 0 failing |
| Pass rate | 98.4% | 100% |
