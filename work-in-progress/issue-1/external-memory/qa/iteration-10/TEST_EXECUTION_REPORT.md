# QA Test Execution Report — Iteration 10

**Sandbox:** `issue-1`
**Repository:** mananb77/kanban-test-3
**Branch:** feature/issue-1
**Duration:** 4.8s
**Exit code:** 0
**Status:** completed

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

═══════════════════════════════════════════════════
Results: 100 passed, 0 failed
═══════════════════════════════════════════════════

✓ All 100 tests passed

```

## stderr (tail)

```
(empty)
```

## Report Files

(none collected)
