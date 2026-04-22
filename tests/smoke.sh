#!/usr/bin/env bash
# tests/smoke.sh
# Comprehensive API + integration smoke tests for Quick Poll.
# Requires: bash, curl, jq  (all present in the production Docker image).
# Usage inside container:  BASE_URL=http://localhost:3001 bash /app/tests/smoke.sh

set -uo pipefail

BASE_URL="${BASE_URL:-http://localhost:3001}"
PASS=0
FAIL=0
TMPFILE=$(mktemp)
trap 'rm -f "$TMPFILE"' EXIT

pass() { echo "  ✓ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

# Writes response body to $TMPFILE; prints HTTP status code on stdout.
http_get() {
  local url="$1"; shift
  curl -s -o "$TMPFILE" -w "%{http_code}" "$@" "$url"
}

# Writes response body to $TMPFILE; prints HTTP status code on stdout.
http_post() {
  local url="$1" body="$2"; shift 2
  curl -s -o "$TMPFILE" -w "%{http_code}" \
    -X POST -H 'Content-Type: application/json' \
    -d "$body" "$@" "$url"
}

assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$actual" = "$expected" ]; then
    pass "$desc"
  else
    fail "$desc  (expected=$expected  actual=$actual)"
  fi
}

# Evaluates a jq expression against $TMPFILE; passes if it returns truthy.
assert_json() {
  local desc="$1" expr="$2"
  if jq -e "$expr" "$TMPFILE" > /dev/null 2>&1; then
    pass "$desc"
  else
    fail "$desc  [expr: $expr]  [body: $(cat "$TMPFILE")]"
  fi
}

# Passes if haystack contains needle.
assert_contains() {
  local desc="$1" needle="$2" haystack="$3"
  if [[ "$haystack" == *"$needle"* ]]; then
    pass "$desc"
  else
    fail "$desc  (expected to contain='$needle'  actual='$haystack')"
  fi
}

# Like http_get but returns Content-Type header value; body still in $TMPFILE.
http_get_type() {
  local url="$1"; shift
  curl -s -o "$TMPFILE" -w "%{content_type}" "$@" "$url"
}

# Like http_post but returns Content-Type header value; body still in $TMPFILE.
http_post_type() {
  local url="$1" body="$2"; shift 2
  curl -s -o "$TMPFILE" -w "%{content_type}" \
    -X POST -H 'Content-Type: application/json' \
    -d "$body" "$@" "$url"
}

echo ""
echo "=== Quick Poll — Comprehensive Smoke & API Tests ==="
echo ""

# ────────────────────────────────────────────────────────────────
# 1. FRONTEND — static HTML served by Express
# ────────────────────────────────────────────────────────────────
echo "── 1. Frontend ──────────────────────────────────────────────"

STATUS=$(http_get "$BASE_URL/")
assert_eq "GET / returns 200" "200" "$STATUS"
if grep -q '<div id="root">' "$TMPFILE" 2>/dev/null; then
  pass "GET / body contains React root element"
else
  fail "GET / body missing <div id=\"root\">"
fi

# ────────────────────────────────────────────────────────────────
# 2. CREATE POLL  —  POST /api/polls
# ────────────────────────────────────────────────────────────────
echo "── 2. POST /api/polls ───────────────────────────────────────"

# 2a. Happy path — minimum 2 options
STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"Best pizza topping?","options":["Pepperoni","Mushrooms"]}')
assert_eq    "2a: 201 on valid 2-option poll"              "201" "$STATUS"
assert_json  "2a: response.id is a string"                 '.id | type == "string"'
assert_json  "2a: response.question matches input"         '.question == "Best pizza topping?"'
assert_json  "2a: response.options has 2 entries"          '.options | length == 2'
assert_json  "2a: options[0].vote_count starts at 0"       '.options[0].vote_count == 0'
assert_json  "2a: options[1].vote_count starts at 0"       '.options[1].vote_count == 0'
assert_json  "2a: created_at is a numeric timestamp"       '.created_at | type == "number"'
POLL_ID=$(jq -r .id "$TMPFILE")

# 2b. Happy path — maximum 6 options
STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"Favourite day?","options":["Mon","Tue","Wed","Thu","Fri","Sat"]}')
assert_eq    "2b: 201 on valid 6-option poll"              "201" "$STATUS"
assert_json  "2b: response.options has 6 entries"          '.options | length == 6'

# 2c. Question whitespace trimmed in response
STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"  Trim me?  ","options":["Yes","No"]}')
assert_eq    "2c: 201 on question with surrounding spaces" "201" "$STATUS"
assert_json  "2c: question is trimmed in response"         '.question == "Trim me?"'

# 2d. Option text trimmed in response
STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"Trim opts?","options":["  Opt A  ","  Opt B  "]}')
assert_eq    "2d: 201 on options with surrounding spaces"  "201" "$STATUS"
assert_json  "2d: options[0].text is trimmed"              '.options[0].text == "Opt A"'
assert_json  "2d: options[1].text is trimmed"              '.options[1].text == "Opt B"'

# 2e. Validation — missing question key
STATUS=$(http_post "$BASE_URL/api/polls" '{"options":["A","B"]}')
assert_eq    "2e: 400 on missing question key"             "400" "$STATUS"
assert_json  "2e: error body has error field"              '.error | type == "string"'

# 2f. Validation — whitespace-only question
STATUS=$(http_post "$BASE_URL/api/polls" '{"question":"   ","options":["A","B"]}')
assert_eq    "2f: 400 on whitespace-only question"         "400" "$STATUS"

# 2g. Validation — only 1 option (below minimum)
STATUS=$(http_post "$BASE_URL/api/polls" '{"question":"Q?","options":["A"]}')
assert_eq    "2g: 400 on 1 option (min is 2)"             "400" "$STATUS"

# 2h. Validation — 7 options (above maximum)
STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"Q?","options":["A","B","C","D","E","F","G"]}')
assert_eq    "2h: 400 on 7 options (max is 6)"            "400" "$STATUS"

# 2i. Validation — empty string option
STATUS=$(http_post "$BASE_URL/api/polls" '{"question":"Q?","options":["A",""]}')
assert_eq    "2i: 400 on empty string option"             "400" "$STATUS"

# 2j. Validation — whitespace-only option
STATUS=$(http_post "$BASE_URL/api/polls" '{"question":"Q?","options":["A","   "]}')
assert_eq    "2j: 400 on whitespace-only option"          "400" "$STATUS"

# 2k. Validation — options key missing entirely
STATUS=$(http_post "$BASE_URL/api/polls" '{"question":"Q?"}')
assert_eq    "2k: 400 on missing options key"             "400" "$STATUS"

# ────────────────────────────────────────────────────────────────
# 3. FETCH POLL  —  GET /api/polls/:id
# ────────────────────────────────────────────────────────────────
echo "── 3. GET /api/polls/:id ────────────────────────────────────"

# 3a. Fetch the poll created in 2a
STATUS=$(http_get "$BASE_URL/api/polls/$POLL_ID")
assert_eq    "3a: 200 on valid poll id"                   "200" "$STATUS"
assert_json  "3a: response.id matches requested id"       ".id == \"$POLL_ID\""
assert_json  "3a: response.question correct"              '.question == "Best pizza topping?"'
assert_json  "3a: 2 options returned"                     '.options | length == 2'
assert_json  "3a: options[0].text in creation order"      '.options[0].text == "Pepperoni"'
assert_json  "3a: options[1].text in creation order"      '.options[1].text == "Mushrooms"'

# 3b. 404 on nonexistent poll id
STATUS=$(http_get "$BASE_URL/api/polls/00000000-0000-0000-0000-000000000000")
assert_eq    "3b: 404 on nonexistent poll id"             "404" "$STATUS"
assert_json  "3b: 404 body contains error field"          '.error | type == "string"'

# ────────────────────────────────────────────────────────────────
# 4. VOTE  —  POST /api/polls/:id/vote
# ────────────────────────────────────────────────────────────────
echo "── 4. POST /api/polls/:id/vote ──────────────────────────────"

# 4a. Valid vote — option index 0
STATUS=$(http_post "$BASE_URL/api/polls/$POLL_ID/vote" '{"optionIndex":0}')
assert_eq    "4a: 200 on valid vote (optionIndex 0)"      "200" "$STATUS"
assert_json  "4a: returns updated poll id"                ".id == \"$POLL_ID\""
assert_json  "4a: options[0].vote_count incremented to 1" '.options[0].vote_count == 1'
assert_json  "4a: options[1].vote_count unchanged at 0"   '.options[1].vote_count == 0'

# 4b. Valid vote — option index 1
STATUS=$(http_post "$BASE_URL/api/polls/$POLL_ID/vote" '{"optionIndex":1}')
assert_eq    "4b: 200 on valid vote (optionIndex 1)"      "200" "$STATUS"
assert_json  "4b: options[1].vote_count incremented to 1" '.options[1].vote_count == 1'
assert_json  "4b: options[0].vote_count unchanged at 1"   '.options[0].vote_count == 1'

# 4c. Multiple votes on same option accumulate
STATUS=$(http_post "$BASE_URL/api/polls/$POLL_ID/vote" '{"optionIndex":0}')
assert_eq    "4c: 200 on second vote for option 0"        "200" "$STATUS"
assert_json  "4c: options[0].vote_count is 2 after 2 votes" '.options[0].vote_count == 2'

# 4d. Vote on last option of a 6-option poll
STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"Six opts?","options":["A","B","C","D","E","F"]}')
assert_eq    "4d setup: create 6-option poll"             "201" "$STATUS"
SIX_ID=$(jq -r .id "$TMPFILE")
STATUS=$(http_post "$BASE_URL/api/polls/$SIX_ID/vote" '{"optionIndex":5}')
assert_eq    "4d: 200 on vote for last option (index 5)"  "200" "$STATUS"
assert_json  "4d: options[5].vote_count incremented"      '.options[5].vote_count == 1'

# 4e. Validation — negative optionIndex
STATUS=$(http_post "$BASE_URL/api/polls/$POLL_ID/vote" '{"optionIndex":-1}')
assert_eq    "4e: 400 on negative optionIndex"            "400" "$STATUS"

# 4f. Validation — out-of-range optionIndex
STATUS=$(http_post "$BASE_URL/api/polls/$POLL_ID/vote" '{"optionIndex":99}')
assert_eq    "4f: 400 on out-of-range optionIndex"        "400" "$STATUS"

# 4g. Validation — non-integer (float) optionIndex
STATUS=$(http_post "$BASE_URL/api/polls/$POLL_ID/vote" '{"optionIndex":0.5}')
assert_eq    "4g: 400 on float optionIndex"               "400" "$STATUS"

# 4h. Validation — missing optionIndex
STATUS=$(http_post "$BASE_URL/api/polls/$POLL_ID/vote" '{}')
assert_eq    "4h: 400 on missing optionIndex"             "400" "$STATUS"

# 4i. 404 vote on nonexistent poll
STATUS=$(http_post "$BASE_URL/api/polls/00000000-0000-0000-0000-000000000000/vote" \
  '{"optionIndex":0}')
assert_eq    "4i: 404 on vote for nonexistent poll"       "404" "$STATUS"

# ────────────────────────────────────────────────────────────────
# 5. PERSISTENCE — votes survive across multiple fetch calls
# ────────────────────────────────────────────────────────────────
echo "── 5. Persistence ───────────────────────────────────────────"

STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"Persist check?","options":["Stay","Go"]}')
assert_eq    "5a: create persistence-check poll"          "201" "$STATUS"
PERSIST_ID=$(jq -r .id "$TMPFILE")

# Cast 3 votes (2 on option 0, 1 on option 1)
http_post "$BASE_URL/api/polls/$PERSIST_ID/vote" '{"optionIndex":0}' > /dev/null
http_post "$BASE_URL/api/polls/$PERSIST_ID/vote" '{"optionIndex":0}' > /dev/null
http_post "$BASE_URL/api/polls/$PERSIST_ID/vote" '{"optionIndex":1}' > /dev/null

STATUS=$(http_get "$BASE_URL/api/polls/$PERSIST_ID")
assert_eq    "5b: re-fetch after votes returns 200"       "200" "$STATUS"
assert_json  "5b: options[0] has 2 accumulated votes"     '.options[0].vote_count == 2'
assert_json  "5b: options[1] has 1 accumulated vote"      '.options[1].vote_count == 1'
assert_json  "5b: total options still 2"                  '.options | length == 2'

# ────────────────────────────────────────────────────────────────
# 6. ISOLATION — votes on one poll do not affect another
# ────────────────────────────────────────────────────────────────
echo "── 6. Poll isolation ────────────────────────────────────────"

STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"Poll A?","options":["AX","AY"]}')
assert_eq    "6 setup: create poll A"                     "201" "$STATUS"
POLL_A=$(jq -r .id "$TMPFILE")

STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"Poll B?","options":["BX","BY"]}')
assert_eq    "6 setup: create poll B"                     "201" "$STATUS"
POLL_B=$(jq -r .id "$TMPFILE")

http_post "$BASE_URL/api/polls/$POLL_A/vote" '{"optionIndex":0}' > /dev/null

STATUS=$(http_get "$BASE_URL/api/polls/$POLL_B")
assert_eq    "6: poll B fetch returns 200"                "200" "$STATUS"
assert_json  "6: poll B options unaffected by vote on A"  '.options[0].vote_count == 0'
assert_json  "6: poll B options[1] unaffected"            '.options[1].vote_count == 0'

# ────────────────────────────────────────────────────────────────
# 7. RESPONSE SCHEMA — full field presence & types
# ────────────────────────────────────────────────────────────────
echo "── 7. Response Schema ───────────────────────────────────────"

STATUS=$(http_get "$BASE_URL/api/polls/$POLL_ID")
assert_eq    "7a: re-fetch for schema check returns 200"    "200" "$STATUS"
assert_json  "7a: options[0].id is a number"                '.options[0].id | type == "number"'
assert_json  "7b: options[0].poll_id equals poll id"        ".options[0].poll_id == \"$POLL_ID\""
assert_json  "7c: options[0] has text field"                '.options[0] | has("text")'
assert_json  "7c: options[0] has vote_count field"          '.options[0] | has("vote_count")'
assert_json  "7d: created_at is a positive integer"         '.created_at | (type == "number" and . > 1700000000)'
assert_json  "7e: option ids ordered ascending"             '.options[0].id < .options[1].id'

STATUS=$(http_post "$BASE_URL/api/polls/$POLL_ID/vote" '{"optionIndex":0}')
assert_eq    "7f: vote response returns 200"                "200" "$STATUS"
assert_json  "7f: vote response options[0].id is a number"  '.options[0].id | type == "number"'
assert_json  "7f: vote response options[0].poll_id matches" ".options[0].poll_id == \"$POLL_ID\""
assert_json  "7f: vote response has question field"         '.question | type == "string"'

# ────────────────────────────────────────────────────────────────
# 8. ADDITIONAL INPUT TYPE VALIDATION
# ────────────────────────────────────────────────────────────────
echo "── 8. Additional Type Validation ────────────────────────────"

STATUS=$(http_post "$BASE_URL/api/polls/$POLL_ID/vote" '{"optionIndex":"0"}')
assert_eq    "8a: 400 when optionIndex is a string"         "400" "$STATUS"
assert_json  "8a: error body has error field"               '.error | type == "string"'

STATUS=$(http_post "$BASE_URL/api/polls/$POLL_ID/vote" '{"optionIndex":null}')
assert_eq    "8b: 400 when optionIndex is null"             "400" "$STATUS"

STATUS=$(http_post "$BASE_URL/api/polls/$POLL_ID/vote" '{"optionIndex":true}')
assert_eq    "8c: 400 when optionIndex is boolean"          "400" "$STATUS"

STATUS=$(http_post "$BASE_URL/api/polls" '{"question":"Q?","options":"A,B"}')
assert_eq    "8d: 400 when options is a string not array"   "400" "$STATUS"

STATUS=$(http_post "$BASE_URL/api/polls" '{"question":"Q?","options":["A",null]}')
assert_eq    "8e: 400 when options contains null element"   "400" "$STATUS"

STATUS=$(http_post "$BASE_URL/api/polls" '{"question":"Q?","options":[]}')
assert_eq    "8f: 400 when options is empty array"          "400" "$STATUS"

STATUS=$(http_post "$BASE_URL/api/polls" '{"question":"Q?","options":{"0":"A","1":"B"}}')
assert_eq    "8g: 400 when options is an object not array"  "400" "$STATUS"

# ────────────────────────────────────────────────────────────────
# 9. MIDDLE-BOUNDARY POLL SIZES (3, 4, 5 options)
# ────────────────────────────────────────────────────────────────
echo "── 9. Middle-Boundary Poll Sizes ────────────────────────────"

# 3-option poll
STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"Three?","options":["Alpha","Beta","Gamma"]}')
assert_eq    "9a: 201 on 3-option poll"                     "201" "$STATUS"
assert_json  "9a: 3 options returned"                       '.options | length == 3'
THREE_ID=$(jq -r .id "$TMPFILE")

STATUS=$(http_post "$BASE_URL/api/polls/$THREE_ID/vote" '{"optionIndex":2}')
assert_eq    "9b: 200 voting last option (index 2) of 3"    "200" "$STATUS"
assert_json  "9b: options[2].vote_count incremented to 1"   '.options[2].vote_count == 1'
assert_json  "9b: options[0].vote_count unchanged at 0"     '.options[0].vote_count == 0'

STATUS=$(http_post "$BASE_URL/api/polls/$THREE_ID/vote" '{"optionIndex":3}')
assert_eq    "9c: 400 on index 3 for 3-option poll"         "400" "$STATUS"

# 5-option poll
STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"Five?","options":["A","B","C","D","E"]}')
assert_eq    "9d: 201 on 5-option poll"                     "201" "$STATUS"
assert_json  "9d: 5 options returned"                       '.options | length == 5'
FIVE_ID=$(jq -r .id "$TMPFILE")

STATUS=$(http_post "$BASE_URL/api/polls/$FIVE_ID/vote" '{"optionIndex":4}')
assert_eq    "9e: 200 voting last option (index 4) of 5"    "200" "$STATUS"
assert_json  "9e: options[4].vote_count incremented to 1"   '.options[4].vote_count == 1'

STATUS=$(http_post "$BASE_URL/api/polls/$FIVE_ID/vote" '{"optionIndex":5}')
assert_eq    "9f: 400 on index 5 for 5-option poll"         "400" "$STATUS"

# 4-option poll
STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"Four?","options":["W","X","Y","Z"]}')
assert_eq    "9g: 201 on 4-option poll"                     "201" "$STATUS"
assert_json  "9g: 4 options returned"                       '.options | length == 4'

# ────────────────────────────────────────────────────────────────
# 10. SPA ROUTE FALLBACK
# ────────────────────────────────────────────────────────────────
echo "── 10. SPA Route Fallback ───────────────────────────────────"

STATUS=$(http_get "$BASE_URL/poll/00000000-0000-0000-0000-000000000000")
assert_eq    "10a: GET /poll/:id returns 200 (SPA fallback)" "200" "$STATUS"
if grep -q '<div id="root">' "$TMPFILE" 2>/dev/null; then
  pass "10a: SPA fallback serves React root element"
else
  fail "10a: SPA fallback missing <div id=\"root\">"
fi

STATUS=$(http_get "$BASE_URL/unknown-route-xyz")
assert_eq    "10b: GET unknown path returns 200 (SPA fallback)" "200" "$STATUS"
if grep -q '<div id="root">' "$TMPFILE" 2>/dev/null; then
  pass "10b: Unknown path serves React root element"
else
  fail "10b: Unknown path missing <div id=\"root\">"
fi

# ────────────────────────────────────────────────────────────────
# 11. CONTENT-TYPE HEADERS
# ────────────────────────────────────────────────────────────────
echo "── 11. Content-Type Headers ─────────────────────────────────"

CT=$(http_post_type "$BASE_URL/api/polls" \
  '{"question":"CT check?","options":["Yes","No"]}')
CT_POLL_ID=$(jq -r .id "$TMPFILE")
assert_contains "11a: POST /api/polls returns application/json" \
  "application/json" "$CT"

CT=$(http_get_type "$BASE_URL/api/polls/$CT_POLL_ID")
assert_contains "11b: GET /api/polls/:id returns application/json" \
  "application/json" "$CT"

CT=$(http_post_type "$BASE_URL/api/polls/$CT_POLL_ID/vote" '{"optionIndex":0}')
assert_contains "11c: POST /api/polls/:id/vote returns application/json" \
  "application/json" "$CT"

CT=$(http_post_type "$BASE_URL/api/polls" '{"question":"   ","options":["A","B"]}')
assert_contains "11d: 400 error response returns application/json" \
  "application/json" "$CT"

CT=$(http_get_type "$BASE_URL/api/polls/00000000-0000-0000-0000-000000000000")
assert_contains "11e: 404 error response returns application/json" \
  "application/json" "$CT"

# ────────────────────────────────────────────────────────────────
# Summary
# ────────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════"
printf "Results: %d passed, %d failed\n" "$PASS" "$FAIL"
echo "═══════════════════════════════════════════════════"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "✗ $FAIL test(s) failed"
  exit 1
fi
echo "✓ All $PASS tests passed"
