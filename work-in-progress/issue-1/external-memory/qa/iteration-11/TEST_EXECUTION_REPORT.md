# QA Test Execution Report — Iteration 11

**Sandbox:** `issue-1`
**Repository:** mananb77/kanban-test-3
**Branch:** feature/issue-1
**Duration:** 11.3s
**Exit code:** 1
**Status:** failed

## stdout (tail)

```

=== Quick Poll — Comprehensive Smoke & API Tests ===

── 1. Frontend ──────────────────────────────────────────────
  ✓ GET / returns 200
  ✓ GET / body contains React root element
── 2. POST /api/polls ───────────────────────────────────────
  ✓ 2a: 201 on valid 2-option poll
  ✓ 2a: response.id is a string
  ✓ 2a: response.question matches input
  ✓ 2a: response.options has 2 entries
  ✓ 2a: options[0].vote_count starts at 0
  ✓ 2a: options[1].vote_count starts at 0
  ✓ 2a: created_at is a numeric timestamp
  ✓ 2b: 201 on valid 6-option poll
  ✓ 2b: response.options has 6 entries
  ✓ 2c: 201 on question with surrounding spaces
  ✓ 2c: question is trimmed in response
  ✓ 2d: 201 on options with surrounding spaces
  ✓ 2d: options[0].text is trimmed
  ✓ 2d: options[1].text is trimmed
  ✓ 2e: 400 on missing question key
  ✓ 2e: error body has error field
  ✓ 2f: 400 on whitespace-only question
  ✓ 2g: 400 on 1 option (min is 2)
  ✓ 2h: 400 on 7 options (max is 6)
  ✓ 2i: 400 on empty string option
  ✓ 2j: 400 on whitespace-only option
  ✓ 2k: 400 on missing options key
── 3. GET /api/polls/:id ────────────────────────────────────
  ✓ 3a: 200 on valid poll id
  ✓ 3a: response.id matches requested id
  ✓ 3a: response.question correct
  ✓ 3a: 2 options returned
  ✓ 3a: options[0].text in creation order
  ✓ 3a: options[1].text in creation order
  ✓ 3b: 404 on nonexistent poll id
  ✓ 3b: 404 body contains error field
── 4. POST /api/polls/:id/vote ──────────────────────────────
  ✓ 4a: 200 on valid vote (optionIndex 0)
  ✓ 4a: returns updated poll id
  ✓ 4a: options[0].vote_count incremented to 1
  ✓ 4a: options[1].vote_count unchanged at 0
  ✓ 4b: 200 on valid vote (optionIndex 1)
  ✓ 4b: options[1].vote_count incremented to 1
  ✓ 4b: options[0].vote_count unchanged at 1
  ✓ 4c: 200 on second vote for option 0
  ✓ 4c: options[0].vote_count is 2 after 2 votes
  ✓ 4d setup: create 6-option poll
  ✓ 4d: 200 on vote for last option (index 5)
  ✓ 4d: options[5].vote_count incremented
  ✓ 4e: 400 on negative optionIndex
  ✓ 4f: 400 on out-of-range optionIndex
  ✓ 4g: 400 on float optionIndex
  ✓ 4h: 400 on missing optionIndex
  ✓ 4i: 404 on vote for nonexistent poll
── 5. Persistence ───────────────────────────────────────────
  ✓ 5a: create persistence-check poll
  ✓ 5b: re-fetch after votes returns 200
  ✓ 5b: options[0] has 2 accumulated votes
  ✓ 5b: options[1] has 1 accumulated vote
  ✓ 5b: total options still 2
── 6. Poll isolation ────────────────────────────────────────
  ✓ 6 setup: create poll A
  ✓ 6 setup: create poll B
  ✓ 6: poll B fetch returns 200
  ✓ 6: poll B options unaffected by vote on A
  ✓ 6: poll B options[1] unaffected
── 7. Response Schema ───────────────────────────────────────
  ✓ 7a: re-fetch for schema check returns 200
  ✓ 7a: options[0].id is a number
  ✓ 7b: options[0].poll_id equals poll id
  ✓ 7c: options[0] has text field
  ✓ 7c: options[0] has vote_count field
  ✓ 7d: created_at is a positive integer
  ✓ 7e: option ids ordered ascending
  ✓ 7f: vote response returns 200
  ✓ 7f: vote response options[0].id is a number
  ✓ 7f: vote response options[0].poll_id matches
  ✓ 7f: vote response has question field
── 8. Additional Type Validation ────────────────────────────
  ✓ 8a: 400 when optionIndex is a string
  ✓ 8a: error body has error field
  ✓ 8b: 400 when optionIndex is null
  ✓ 8c: 400 when optionIndex is boolean
  ✓ 8d: 400 when options is a string not array
  ✓ 8e: 400 when options contains null element
  ✓ 8f: 400 when options is empty array
  ✓ 8g: 400 when options is an object not array
── 9. Middle-Boundary Poll Sizes ────────────────────────────
  ✓ 9a: 201 on 3-option poll
  ✓ 9a: 3 options returned
  ✓ 9b: 200 voting last option (index 2) of 3
  ✓ 9b: options[2].vote_count incremented to 1
  ✓ 9b: options[0].vote_count unchanged at 0
  ✓ 9c: 400 on index 3 for 3-option poll
  ✓ 9d: 201 on 5-option poll
  ✓ 9d: 5 options returned
  ✓ 9e: 200 voting last option (index 4) of 5
  ✓ 9e: options[4].vote_count incremented to 1
  ✓ 9f: 400 on index 5 for 5-option poll
  ✓ 9g: 201 on 4-option poll
  ✓ 9g: 4 options returned
── 10. SPA Route Fallback ───────────────────────────────────
  ✓ 10a: GET /poll/:id returns 200 (SPA fallback)
  ✓ 10a: SPA fallback serves React root element
  ✓ 10b: GET unknown path returns 200 (SPA fallback)
  ✓ 10b: Unknown path serves React root element
── 11. Content-Type Headers ─────────────────────────────────
  ✓ 11a: POST /api/polls returns application/json
  ✓ 11b: GET /api/polls/:id returns application/json
  ✓ 11c: POST /api/polls/:id/vote returns application/json
  ✓ 11d: 400 error response returns application/json
  ✓ 11e: 404 error response returns application/json
── 12. Non-standard Poll IDs ────────────────────────────────
  ✓ 12a: 404 for arbitrary non-UUID poll id
  ✓ 12a: 404 body has error field
  ✓ 12b: 404 for numeric string poll id
  ✓ 12c: 404 for URL-encoded SQL injection poll id
  ✓ 12d: 404 on vote for non-UUID poll id
  ✓ 12d: 404 vote response has error field
── 13. Unicode and Special Characters ───────────────────────
  ✓ 13a: 201 on unicode/emoji question and options
  ✓ 13a: 3 options stored for emoji poll
  ✓ 13b: 200 on fetch of unicode poll
  ✓ 13b: options count preserved
  ✓ 13b: options have non-empty text
  ✓ 13c: 201 on accented-character question
  ✓ 13c: question stored with unicode chars
  ✓ 13c: 2 options with unicode text
  ✓ 13d: 201 on HTML-tagged question
  ✓ 13d: question stored verbatim with HTML tags
  ✓ 13d: option stored verbatim with HTML entity
── 14. Duplicate and Boundary Content ───────────────────────
  ✓ 14a: 201 creating first poll (same question)
  ✓ 14a: 201 creating second poll (same question)
  ✓ 14a: duplicate-question polls have distinct UUIDs
  ✓ 14b: 201 on poll with duplicate option texts
  ✓ 14b: both duplicate options stored
  ✓ 14b: duplicate option texts equal
  ✓ 14c: 201 on single-character question
  ✓ 14c: single-char question preserved
  ✓ 14d setup: create boundary poll
  ✓ 14d: 200 on optionIndex exactly 0
  ✓ 14d: options[0].vote_count == 1 (boundary vote)
  ✓ 14d: options[1].vote_count == 0 (untouched)
── 15. Vote Count Accumulation ──────────────────────────────
  ✓ 15 setup: create accumulation poll
  ✓ 15a: 200 fetching after 5 votes on option 0
  ✓ 15a: options[0].vote_count == 5
  ✓ 15a: options[1].vote_count == 0 (untouched)
  ✓ 15b: 200 fetching after 3 votes on option 1
  ✓ 15b: options[0].vote_count still 5
  ✓ 15b: options[1].vote_count == 3
  ✓ 15b: total votes across options sums to 8
── 16. Complete Response Schema (All Endpoints) ─────────────
  ✓ 16a: 201 on schema-check poll
  ✓ 16a: POST response id is string
  ✓ 16a: POST response question is string
  ✓ 16a: POST response created_at is number
  ✓ 16a: POST response options is array
  ✓ 16a: POST response has exactly 4 top-level keys
  ✓ 16b: option has id field
  ✓ 16b: option has poll_id field
  ✓ 16b: option has text field
  ✓ 16b: option has vote_count field
  ✓ 16b: option object has exactly 4 fields
  ✓ 16c: GET returns 200 for schema poll
  ✓ 16c: GET response id is string
  ✓ 16c: GET response question is string
  ✓ 16c: GET response created_at is number
  ✓ 16c: GET response options is array
  ✓ 16d: vote returns 200
  ✓ 16d: vote response id is string
  ✓ 16d: vote response question is string
  ✓ 16d: vote response created_at is number
  ✓ 16d: vote response options is array
  ✓ 16d: vote response id matches poll id
── 17. Response Consistency ─────────────────────────────────
  ✓ 17 setup: create consistency poll
  ✓ 17a: GET returns 200
  ✓ 17a: GET created_at matches original create
  ✓ 17a: GET options[0].id matches create
  ✓ 17a: GET options[1].id matches create
  ✓ 17b: vote returns 200
  ✓ 17b: vote response created_at matches original
  ✓ 17b: vote response options[0].id matches
  ✓ 17c: repeated GET returns same vote_count
── 18. Additional Input Edge Cases ──────────────────────────
  ✓ 18a: 400 when question is null
  ✓ 18a: error body has error field
  ✓ 18b: 400 when question is boolean false
  ✓ 18c setup: create poll for large index test
  ✓ 18c: 400 on very large out-of-range optionIndex
  ✓ 18d: 400 on optionIndex == options.length (exclusive upper bound)
  ✓ 18e: 400 on newline/tab-only question
  ✓ 18f: 400 when options array contains numeric zero
── 19. Health Check Endpoint ────────────────────────────────
  ✓ 19a: GET /api/polls/healthz returns 404 (server up indicator)
  ✓ 19a: healthz 404 response has error field
  ✓ 19b: GET /api/polls/ping returns 404 (not a poll)
── 20. Timestamp Range Validation ───────────────────────────
  ✓ 20a: create poll for timestamp validation
  ✓ 20b: created_at is within 60s of current Unix time
  ✓ 20c: created_at is a plausible Unix epoch timestamp
  ✓ 20d: GET returns 200 for timestamp poll
  ✓ 20d: GET created_at matches POST created_at
── 21. Vote Response Completeness ───────────────────────────
  ✓ 21a setup: create 6-option poll
  ✓ 21a: vote on 6-option poll returns 200
  ✓ 21a: vote response includes all 6 options
  ✓ 21a: options ordered by id ascending
  ✓ 21a: only voted option (0) has vote_count > 0
  ✓ 21a: unvoted options still have vote_count == 0
  ✓ 21b: sum of all vote_counts equals 1 after one vote
  ✓ 21c setup: create 3-option poll
  ✓ 21c: vote returns 200
  ✓ 21c: vote response for 3-option poll has 3 options
  ✓ 21c: voted option (1) has vote_count == 1
  ✓ 21c: unvoted options (0, 2) have vote_count == 0
── 22. Extra Request Fields Ignored ─────────────────────────
  ✓ 22a: 201 on poll creation with extra fields
  ✓ 22a: question preserved correctly
  ✓ 22a: 2 options created
  ✓ 22b: 200 on vote with extra fields
  ✓ 22b: options[0].vote_count incremented correctly
── 23. High Vote Count Accumulation ─────────────────────────
  ✓ 23 setup: create scale-test poll
  ✓ 23a: 200 fetching after 30 total votes
  ✓ 23a: options[0].vote_count == 20
  ✓ 23a: options[1].vote_count == 10
  ✓ 23a: total votes sum to 30
── 24. HTTP Method Validation ───────────────────────────────
  ✓ 24a: PUT /api/polls returns 404 (method not allowed)
  ✓ 24b: DELETE /api/polls/:id returns 404
  ✓ 24c: PATCH /api/polls/:id/vote returns 404
  ✓ 24d: GET /api/polls returns 200 (SPA fallback, no list endpoint)
  ✓ 24d: GET /api/polls fallback body contains React root element
  ✓ 24e: POST /api/polls/:id (no /vote) returns 404
── 25. Non-object JSON Request Bodies ───────────────────────
  ✗ 25a: 400 when POST /api/polls body is a JSON number  (expected=400  actual=500)
  ✓ 25a: error field present in response
  ✗ 25b: 400 when POST /api/polls body is a JSON string  (expected=400  actual=500)
  ✓ 25c: 400 when POST /api/polls body is a JSON array
  ✗ 25d: 400 when vote body is a JSON number  (expected=400  actual=500)
  ✓ 25d: error field present in vote error response
  ✗ 25e: 400 when vote body is a JSON string  (expected=400  actual=500)
  ✓ 25f: 400 when vote body is a JSON array
── 26. Long Input Strings ────────────────────────────────────
  ✓ 26a: 201 on poll with 500-char question
  ✓ 26a: long question stored (non-empty)
  ✓ 26b: 201 on poll with 500-char option texts
  ✓ 26b: 2 options stored
  ✓ 26b: options[0].text length is preserved
  ✓ 26c: 200 fetching poll with long question
  ✓ 26c: question length is 500 chars after round-trip
  ✓ 26d: 200 voting on poll with long question
  ✓ 26d: vote registered correctly
── 27. Complete Voting Cycle ─────────────────────────────────
  ✓ 27 setup: create 4-option poll
  ✓ 27a: 200 on vote for option 0
  ✓ 27a: options[0].vote_count == 1
  ✓ 27a: running total == 1
  ✓ 27b: 200 on vote for option 1
  ✓ 27b: options[1].vote_count == 1
  ✓ 27b: running total == 2
  ✓ 27c: 200 on vote for option 2
  ✓ 27c: options[2].vote_count == 1
  ✓ 27c: running total == 3
  ✓ 27d: 200 on vote for option 3 (last)
  ✓ 27d: options[3].vote_count == 1
  ✓ 27d: final total == 4 (one per option)
  ✓ 27d: every option has exactly 1 vote
  ✓ 27e: 200 fetching after full cycle
  ✓ 27e: GET total votes == 4
  ✓ 27e: all 4 options have exactly 1 vote each via GET

═══════════════════════════════════════════════════
Results: 242 passed, 4 failed
═══════════════════════════════════════════════════

✗ 4 test(s) failed

```

## stderr (tail)

```
(empty)
```

## Report Files

(none collected)
