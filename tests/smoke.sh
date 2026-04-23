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
# 12. NON-STANDARD AND INJECTION POLL IDs
# ────────────────────────────────────────────────────────────────
echo "── 12. Non-standard Poll IDs ────────────────────────────────"

# 12a. Arbitrary non-UUID alphanumeric string → 404
STATUS=$(http_get "$BASE_URL/api/polls/not-a-uuid-at-all")
assert_eq    "12a: 404 for arbitrary non-UUID poll id"        "404" "$STATUS"
assert_json  "12a: 404 body has error field"                  '.error | type == "string"'

# 12b. Numeric string as poll id → 404
STATUS=$(http_get "$BASE_URL/api/polls/12345")
assert_eq    "12b: 404 for numeric string poll id"            "404" "$STATUS"

# 12c. URL-encoded SQL injection attempt in poll id → 404 (parameterized query prevents injection)
STATUS=$(http_get "$BASE_URL/api/polls/1%27%20OR%20%271%27%3D%271")
assert_eq    "12c: 404 for URL-encoded SQL injection poll id" "404" "$STATUS"

# 12d. Vote on non-existent non-UUID poll id → 404
STATUS=$(http_post "$BASE_URL/api/polls/definitely-not-a-poll/vote" '{"optionIndex":0}')
assert_eq    "12d: 404 on vote for non-UUID poll id"          "404" "$STATUS"
assert_json  "12d: 404 vote response has error field"         '.error | type == "string"'

# ────────────────────────────────────────────────────────────────
# 13. UNICODE AND SPECIAL CHARACTER CONTENT
# ────────────────────────────────────────────────────────────────
echo "── 13. Unicode and Special Characters ───────────────────────"

# 13a. Create poll with emoji in question and options
STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"Favourite emoji? 🎉","options":["🎉 Party","🚀 Rocket","❤️ Heart"]}')
assert_eq    "13a: 201 on unicode/emoji question and options" "201" "$STATUS"
assert_json  "13a: 3 options stored for emoji poll"           '.options | length == 3'
EMOJI_POLL_ID=$(jq -r .id "$TMPFILE")

# 13b. Retrieve unicode poll — content preserved faithfully
STATUS=$(http_get "$BASE_URL/api/polls/$EMOJI_POLL_ID")
assert_eq    "13b: 200 on fetch of unicode poll"              "200" "$STATUS"
assert_json  "13b: options count preserved"                   '.options | length == 3'
assert_json  "13b: options have non-empty text"               '.options | map(.text | length > 0) | all'

# 13c. Unicode Latin-extended and accented characters
STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"Café or thé?","options":["café","thé"]}')
assert_eq    "13c: 201 on accented-character question"        "201" "$STATUS"
assert_json  "13c: question stored with unicode chars"        '.question | length > 0'
assert_json  "13c: 2 options with unicode text"               '.options | length == 2'

# 13d. HTML special characters stored verbatim (not escaped by the API)
STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"<b>Bold</b> or plain?","options":["<b>Bold</b>","Plain &amp; simple"]}')
assert_eq    "13d: 201 on HTML-tagged question"               "201" "$STATUS"
assert_json  "13d: question stored verbatim with HTML tags"   '.question == "<b>Bold</b> or plain?"'
assert_json  "13d: option stored verbatim with HTML entity"   '.options[1].text == "Plain &amp; simple"'

# ────────────────────────────────────────────────────────────────
# 14. DUPLICATE AND BOUNDARY CONTENT
# ────────────────────────────────────────────────────────────────
echo "── 14. Duplicate and Boundary Content ───────────────────────"

# 14a. Two polls with identical question text → both succeed with different UUIDs
STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"Same question?","options":["A","B"]}')
assert_eq    "14a: 201 creating first poll (same question)"   "201" "$STATUS"
DUP_ID_1=$(jq -r .id "$TMPFILE")

STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"Same question?","options":["A","B"]}')
assert_eq    "14a: 201 creating second poll (same question)"  "201" "$STATUS"
DUP_ID_2=$(jq -r .id "$TMPFILE")

if [ "$DUP_ID_1" != "$DUP_ID_2" ]; then
  pass "14a: duplicate-question polls have distinct UUIDs"
else
  fail "14a: polls with same question got identical IDs"
fi

# 14b. Poll with two identical option texts → 201 (no dedup constraint)
STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"Duplicates ok?","options":["Same","Same"]}')
assert_eq    "14b: 201 on poll with duplicate option texts"   "201" "$STATUS"
assert_json  "14b: both duplicate options stored"             '.options | length == 2'
assert_json  "14b: duplicate option texts equal"              '.options[0].text == .options[1].text'

# 14c. Minimum-length (1 character) question → 201
STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"?","options":["Y","N"]}')
assert_eq    "14c: 201 on single-character question"          "201" "$STATUS"
assert_json  "14c: single-char question preserved"            '.question == "?"'

# 14d. Exactly 0 optionIndex on a fresh 2-option poll → boundary 200
STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"Boundary?","options":["Zero","One"]}')
assert_eq    "14d setup: create boundary poll"                "201" "$STATUS"
BOUND_ID=$(jq -r .id "$TMPFILE")
STATUS=$(http_post "$BASE_URL/api/polls/$BOUND_ID/vote" '{"optionIndex":0}')
assert_eq    "14d: 200 on optionIndex exactly 0"              "200" "$STATUS"
assert_json  "14d: options[0].vote_count == 1 (boundary vote)" '.options[0].vote_count == 1'
assert_json  "14d: options[1].vote_count == 0 (untouched)"   '.options[1].vote_count == 0'

# ────────────────────────────────────────────────────────────────
# 15. VOTE COUNT ACCUMULATION STRESS
# ────────────────────────────────────────────────────────────────
echo "── 15. Vote Count Accumulation ──────────────────────────────"

STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"High count?","options":["Alpha","Beta"]}')
assert_eq    "15 setup: create accumulation poll"             "201" "$STATUS"
ACCUM_ID=$(jq -r .id "$TMPFILE")

# Cast 5 votes on option 0
for _i in 1 2 3 4 5; do
  http_post "$BASE_URL/api/polls/$ACCUM_ID/vote" '{"optionIndex":0}' > /dev/null
done

STATUS=$(http_get "$BASE_URL/api/polls/$ACCUM_ID")
assert_eq    "15a: 200 fetching after 5 votes on option 0"   "200" "$STATUS"
assert_json  "15a: options[0].vote_count == 5"               '.options[0].vote_count == 5'
assert_json  "15a: options[1].vote_count == 0 (untouched)"   '.options[1].vote_count == 0'

# Cast 3 more votes on option 1
for _i in 1 2 3; do
  http_post "$BASE_URL/api/polls/$ACCUM_ID/vote" '{"optionIndex":1}' > /dev/null
done

STATUS=$(http_get "$BASE_URL/api/polls/$ACCUM_ID")
assert_eq    "15b: 200 fetching after 3 votes on option 1"   "200" "$STATUS"
assert_json  "15b: options[0].vote_count still 5"            '.options[0].vote_count == 5'
assert_json  "15b: options[1].vote_count == 3"               '.options[1].vote_count == 3'
assert_json  "15b: total votes across options sums to 8"     '(.options[0].vote_count + .options[1].vote_count) == 8'

# ────────────────────────────────────────────────────────────────
# 16. COMPLETE RESPONSE SCHEMA — ALL THREE ENDPOINTS
# ────────────────────────────────────────────────────────────────
echo "── 16. Complete Response Schema (All Endpoints) ─────────────"

# 16a. POST /api/polls — all top-level fields and their types
STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"Schema check?","options":["X","Y","Z"]}')
assert_eq    "16a: 201 on schema-check poll"                  "201" "$STATUS"
SCHEMA_ID=$(jq -r .id "$TMPFILE")
assert_json  "16a: POST response id is string"                '.id | type == "string"'
assert_json  "16a: POST response question is string"          '.question | type == "string"'
assert_json  "16a: POST response created_at is number"        '.created_at | type == "number"'
assert_json  "16a: POST response options is array"            '.options | type == "array"'
assert_json  "16a: POST response has exactly 4 top-level keys" '. | keys | length == 4'

# 16b. Each option object has all 4 required fields
assert_json  "16b: option has id field"                       '.options[0] | has("id")'
assert_json  "16b: option has poll_id field"                  '.options[0] | has("poll_id")'
assert_json  "16b: option has text field"                     '.options[0] | has("text")'
assert_json  "16b: option has vote_count field"               '.options[0] | has("vote_count")'
assert_json  "16b: option object has exactly 4 fields"        '.options[0] | keys | length == 4'

# 16c. GET /api/polls/:id — all top-level fields present
STATUS=$(http_get "$BASE_URL/api/polls/$SCHEMA_ID")
assert_eq    "16c: GET returns 200 for schema poll"           "200" "$STATUS"
assert_json  "16c: GET response id is string"                 '.id | type == "string"'
assert_json  "16c: GET response question is string"           '.question | type == "string"'
assert_json  "16c: GET response created_at is number"         '.created_at | type == "number"'
assert_json  "16c: GET response options is array"             '.options | type == "array"'

# 16d. POST /api/polls/:id/vote — all fields including created_at (often missed)
STATUS=$(http_post "$BASE_URL/api/polls/$SCHEMA_ID/vote" '{"optionIndex":0}')
assert_eq    "16d: vote returns 200"                          "200" "$STATUS"
assert_json  "16d: vote response id is string"                '.id | type == "string"'
assert_json  "16d: vote response question is string"          '.question | type == "string"'
assert_json  "16d: vote response created_at is number"        '.created_at | type == "number"'
assert_json  "16d: vote response options is array"            '.options | type == "array"'
assert_json  "16d: vote response id matches poll id"          ".id == \"$SCHEMA_ID\""

# ────────────────────────────────────────────────────────────────
# 17. RESPONSE CONSISTENCY — GET vs CREATE vs VOTE agreement
# ────────────────────────────────────────────────────────────────
echo "── 17. Response Consistency ─────────────────────────────────"

STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"Consistency?","options":["P","Q"]}')
assert_eq    "17 setup: create consistency poll"              "201" "$STATUS"
CONS_ID=$(jq -r .id "$TMPFILE")
CONS_CREATED_AT=$(jq -r .created_at "$TMPFILE")
CONS_OPT0_ID=$(jq -r '.options[0].id' "$TMPFILE")
CONS_OPT1_ID=$(jq -r '.options[1].id' "$TMPFILE")

# 17a. GET response agrees with CREATE response on stable fields
STATUS=$(http_get "$BASE_URL/api/polls/$CONS_ID")
assert_eq    "17a: GET returns 200"                           "200" "$STATUS"
assert_json  "17a: GET created_at matches original create"    ".created_at == $CONS_CREATED_AT"
assert_json  "17a: GET options[0].id matches create"          ".options[0].id == $CONS_OPT0_ID"
assert_json  "17a: GET options[1].id matches create"          ".options[1].id == $CONS_OPT1_ID"

# 17b. VOTE response agrees with CREATE response on stable fields
STATUS=$(http_post "$BASE_URL/api/polls/$CONS_ID/vote" '{"optionIndex":0}')
assert_eq    "17b: vote returns 200"                          "200" "$STATUS"
assert_json  "17b: vote response created_at matches original" ".created_at == $CONS_CREATED_AT"
assert_json  "17b: vote response options[0].id matches"       ".options[0].id == $CONS_OPT0_ID"

# 17c. Repeated GET requests return identical, non-mutating data
STATUS=$(http_get "$BASE_URL/api/polls/$CONS_ID")
FETCH1_COUNT=$(jq -r '.options[0].vote_count' "$TMPFILE")
STATUS=$(http_get "$BASE_URL/api/polls/$CONS_ID")
FETCH2_COUNT=$(jq -r '.options[0].vote_count' "$TMPFILE")
assert_eq    "17c: repeated GET returns same vote_count"      "$FETCH1_COUNT" "$FETCH2_COUNT"

# ────────────────────────────────────────────────────────────────
# 18. ADDITIONAL INPUT EDGE CASES
# ────────────────────────────────────────────────────────────────
echo "── 18. Additional Input Edge Cases ──────────────────────────"

# 18a. null question → 400 (falsy check: !null is true)
STATUS=$(http_post "$BASE_URL/api/polls" '{"question":null,"options":["A","B"]}')
assert_eq    "18a: 400 when question is null"                  "400" "$STATUS"
assert_json  "18a: error body has error field"                 '.error | type == "string"'

# 18b. boolean false question → 400 (falsy check: !false is true)
STATUS=$(http_post "$BASE_URL/api/polls" '{"question":false,"options":["A","B"]}')
assert_eq    "18b: 400 when question is boolean false"         "400" "$STATUS"

# 18c. Very large out-of-range optionIndex → 400
STATUS=$(http_post "$BASE_URL/api/polls" '{"question":"Big index?","options":["A","B"]}')
assert_eq    "18c setup: create poll for large index test"     "201" "$STATUS"
BIG_IDX_ID=$(jq -r .id "$TMPFILE")
STATUS=$(http_post "$BASE_URL/api/polls/$BIG_IDX_ID/vote" '{"optionIndex":1000000}')
assert_eq    "18c: 400 on very large out-of-range optionIndex" "400" "$STATUS"

# 18d. optionIndex exactly equal to options.length (off-by-one) → 400
STATUS=$(http_post "$BASE_URL/api/polls/$BIG_IDX_ID/vote" '{"optionIndex":2}')
assert_eq    "18d: 400 on optionIndex == options.length (exclusive upper bound)" "400" "$STATUS"

# 18e. Question containing only newlines and tabs → 400 (trims to empty string)
STATUS=$(http_post "$BASE_URL/api/polls" '{"question":"\n\t\n","options":["A","B"]}')
assert_eq    "18e: 400 on newline/tab-only question"           "400" "$STATUS"

# 18f. options array containing numeric zero (falsy) → 400
# !0 is truthy so the server's `!o` check catches it before calling .trim()
STATUS=$(http_post "$BASE_URL/api/polls" '{"question":"Zero opt?","options":["A",0]}')
assert_eq    "18f: 400 when options array contains numeric zero" "400" "$STATUS"

# ────────────────────────────────────────────────────────────────
# 19. HEALTH CHECK ENDPOINT
# ────────────────────────────────────────────────────────────────
echo "── 19. Health Check Endpoint ────────────────────────────────"

# Per TDD §9.1: GET /api/polls/healthz → 404 is the documented health-check
# mechanism. The string "healthz" is not a valid poll UUID so the server
# returns 404, which confirms the process is running and the DB is reachable.
STATUS=$(http_get "$BASE_URL/api/polls/healthz")
assert_eq    "19a: GET /api/polls/healthz returns 404 (server up indicator)" "404" "$STATUS"
assert_json  "19a: healthz 404 response has error field"       '.error | type == "string"'

# A second well-known sentinel confirms the same behaviour is not path-specific.
STATUS=$(http_get "$BASE_URL/api/polls/ping")
assert_eq    "19b: GET /api/polls/ping returns 404 (not a poll)" "404" "$STATUS"

# ────────────────────────────────────────────────────────────────
# 20. TIMESTAMP RANGE VALIDATION
# ────────────────────────────────────────────────────────────────
echo "── 20. Timestamp Range Validation ───────────────────────────"

STATUS=$(http_post "$BASE_URL/api/polls" '{"question":"TS check?","options":["Now","Later"]}')
assert_eq    "20a: create poll for timestamp validation"        "201" "$STATUS"
CREATED_TS=$(jq -r .created_at "$TMPFILE")
NOW_TS=$(date +%s)

# Allow ±60 seconds to tolerate any minor clock skew between process and host
TS_DIFF=$(( NOW_TS - CREATED_TS ))
if [ "$TS_DIFF" -ge -60 ] && [ "$TS_DIFF" -le 60 ]; then
  pass "20b: created_at is within 60s of current Unix time"
else
  fail "20b: created_at not within 60s of now  (diff=${TS_DIFF}s, created=${CREATED_TS}, now=${NOW_TS})"
fi

# created_at must be a plausible Unix epoch second (post Jan-2024, pre year 2100)
if [ "$CREATED_TS" -gt 1700000000 ] && [ "$CREATED_TS" -lt 4102444800 ]; then
  pass "20c: created_at is a plausible Unix epoch timestamp"
else
  fail "20c: created_at outside plausible range  (value=${CREATED_TS})"
fi

# GET response preserves the original created_at — verify it is unchanged
TS_POLL_ID=$(jq -r .id "$TMPFILE")
STATUS=$(http_get "$BASE_URL/api/polls/$TS_POLL_ID")
assert_eq    "20d: GET returns 200 for timestamp poll"          "200" "$STATUS"
assert_json  "20d: GET created_at matches POST created_at"      ".created_at == $CREATED_TS"

# ────────────────────────────────────────────────────────────────
# 21. VOTE RESPONSE COMPLETENESS
# ────────────────────────────────────────────────────────────────
echo "── 21. Vote Response Completeness ───────────────────────────"

# 21a. Voting on a 6-option poll → response contains all 6 options
STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"All six?","options":["A","B","C","D","E","F"]}')
assert_eq    "21a setup: create 6-option poll"                  "201" "$STATUS"
VCOMP_ID=$(jq -r .id "$TMPFILE")

STATUS=$(http_post "$BASE_URL/api/polls/$VCOMP_ID/vote" '{"optionIndex":0}')
assert_eq    "21a: vote on 6-option poll returns 200"           "200" "$STATUS"
assert_json  "21a: vote response includes all 6 options"        '.options | length == 6'
assert_json  "21a: options ordered by id ascending"             '.options[0].id < .options[5].id'
assert_json  "21a: only voted option (0) has vote_count > 0"   '.options[0].vote_count == 1'
assert_json  "21a: unvoted options still have vote_count == 0"  '[.options[1:][].vote_count] | all(. == 0)'

# 21b. Total votes across all options equals 1 after a single vote
assert_json  "21b: sum of all vote_counts equals 1 after one vote" '[.options[].vote_count] | add == 1'

# 21c. Voting on a 3-option poll → response contains exactly 3 options
STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"Three resp?","options":["X","Y","Z"]}')
assert_eq    "21c setup: create 3-option poll"                  "201" "$STATUS"
VCOMP3_ID=$(jq -r .id "$TMPFILE")

STATUS=$(http_post "$BASE_URL/api/polls/$VCOMP3_ID/vote" '{"optionIndex":1}')
assert_eq    "21c: vote returns 200"                            "200" "$STATUS"
assert_json  "21c: vote response for 3-option poll has 3 options" '.options | length == 3'
assert_json  "21c: voted option (1) has vote_count == 1"        '.options[1].vote_count == 1'
assert_json  "21c: unvoted options (0, 2) have vote_count == 0" '(.options[0].vote_count == 0) and (.options[2].vote_count == 0)'

# ────────────────────────────────────────────────────────────────
# 22. EXTRA FIELDS IN REQUEST BODY IGNORED
# ────────────────────────────────────────────────────────────────
echo "── 22. Extra Request Fields Ignored ─────────────────────────"

# 22a. POST /api/polls with unknown extra fields → 201 (fields silently ignored)
STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"Extra fields?","options":["Yes","No"],"extra":"ignored","foo":123}')
assert_eq    "22a: 201 on poll creation with extra fields"      "201" "$STATUS"
assert_json  "22a: question preserved correctly"                '.question == "Extra fields?"'
assert_json  "22a: 2 options created"                           '.options | length == 2'

# 22b. POST /api/polls/:id/vote with extra unknown fields → 200 (fields ignored)
EXTRA_POLL_ID=$(jq -r .id "$TMPFILE")
STATUS=$(http_post "$BASE_URL/api/polls/$EXTRA_POLL_ID/vote" \
  '{"optionIndex":0,"userId":"anon","timestamp":1234567,"extra":true}')
assert_eq    "22b: 200 on vote with extra fields"               "200" "$STATUS"
assert_json  "22b: options[0].vote_count incremented correctly" '.options[0].vote_count == 1'

# ────────────────────────────────────────────────────────────────
# 23. HIGH VOTE COUNT ACCUMULATION
# ────────────────────────────────────────────────────────────────
echo "── 23. High Vote Count Accumulation ─────────────────────────"

STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"Scale test?","options":["Alpha","Beta"]}')
assert_eq    "23 setup: create scale-test poll"                 "201" "$STATUS"
SCALE_ID=$(jq -r .id "$TMPFILE")

# 20 votes on option 0, 10 on option 1
for _i in $(seq 1 20); do
  http_post "$BASE_URL/api/polls/$SCALE_ID/vote" '{"optionIndex":0}' > /dev/null
done
for _i in $(seq 1 10); do
  http_post "$BASE_URL/api/polls/$SCALE_ID/vote" '{"optionIndex":1}' > /dev/null
done

STATUS=$(http_get "$BASE_URL/api/polls/$SCALE_ID")
assert_eq    "23a: 200 fetching after 30 total votes"           "200" "$STATUS"
assert_json  "23a: options[0].vote_count == 20"                 '.options[0].vote_count == 20'
assert_json  "23a: options[1].vote_count == 10"                 '.options[1].vote_count == 10'
assert_json  "23a: total votes sum to 30"                       '(.options[0].vote_count + .options[1].vote_count) == 30'

# ────────────────────────────────────────────────────────────────
# 24. HTTP METHOD VALIDATION
# ────────────────────────────────────────────────────────────────
echo "── 24. HTTP Method Validation ───────────────────────────────"

# 24a. PUT /api/polls → 404 (no PUT handler; not a supported method)
STATUS=$(curl -s -o "$TMPFILE" -w "%{http_code}" \
  -X PUT -H 'Content-Type: application/json' \
  -d '{"question":"Q?","options":["A","B"]}' \
  "$BASE_URL/api/polls")
assert_eq "24a: PUT /api/polls returns 404 (method not allowed)" "404" "$STATUS"

# 24b. DELETE /api/polls/:id → 404 (no DELETE handler)
STATUS=$(curl -s -o "$TMPFILE" -w "%{http_code}" \
  -X DELETE "$BASE_URL/api/polls/$POLL_ID")
assert_eq "24b: DELETE /api/polls/:id returns 404" "404" "$STATUS"

# 24c. PATCH /api/polls/:id/vote → 404 (only POST /:id/vote is registered)
STATUS=$(curl -s -o "$TMPFILE" -w "%{http_code}" \
  -X PATCH -H 'Content-Type: application/json' \
  -d '{"optionIndex":0}' \
  "$BASE_URL/api/polls/$POLL_ID/vote")
assert_eq "24c: PATCH /api/polls/:id/vote returns 404" "404" "$STATUS"

# 24d. GET /api/polls (no ID segment) → 200 SPA fallback (no list endpoint exists)
# The router only handles GET /:id (requires a segment), so /api/polls with no
# segment falls through to the catch-all app.get('*') which serves the React SPA.
STATUS=$(http_get "$BASE_URL/api/polls")
assert_eq "24d: GET /api/polls returns 200 (SPA fallback, no list endpoint)" "200" "$STATUS"
if grep -q '<div id="root">' "$TMPFILE" 2>/dev/null; then
  pass "24d: GET /api/polls fallback body contains React root element"
else
  fail "24d: GET /api/polls fallback missing <div id=\"root\">"
fi

# 24e. POST /api/polls/:id without /vote suffix → 404
# router.post('/:id/vote') only matches the /vote sub-path; bare /:id has no POST handler.
STATUS=$(curl -s -o "$TMPFILE" -w "%{http_code}" \
  -X POST -H 'Content-Type: application/json' \
  -d '{"optionIndex":0}' \
  "$BASE_URL/api/polls/$POLL_ID")
assert_eq "24e: POST /api/polls/:id (no /vote) returns 404" "404" "$STATUS"

# ────────────────────────────────────────────────────────────────
# 25. NON-OBJECT JSON REQUEST BODIES
# ────────────────────────────────────────────────────────────────
echo "── 25. Non-object JSON Request Bodies ───────────────────────"

# Express parses valid JSON of any type; destructuring non-objects yields
# undefined for named keys, triggering the server's "Question is required" check.

# 25a. POST /api/polls with JSON number body → 400
STATUS=$(http_post "$BASE_URL/api/polls" '42')
assert_eq    "25a: 400 when POST /api/polls body is a JSON number" "400" "$STATUS"
assert_json  "25a: error field present in response"                '.error | type == "string"'

# 25b. POST /api/polls with JSON string body → 400
STATUS=$(http_post "$BASE_URL/api/polls" '"just a string"')
assert_eq    "25b: 400 when POST /api/polls body is a JSON string" "400" "$STATUS"

# 25c. POST /api/polls with JSON array body → 400
# Array destructuring by name yields undefined for missing keys.
STATUS=$(http_post "$BASE_URL/api/polls" '[{"question":"Q?","options":["A","B"]}]')
assert_eq    "25c: 400 when POST /api/polls body is a JSON array"  "400" "$STATUS"

# 25d. POST /api/polls/:id/vote with JSON number body → 400
# Number.isInteger(undefined) is false, triggering validation.
STATUS=$(http_post "$BASE_URL/api/polls/$POLL_ID/vote" '42')
assert_eq    "25d: 400 when vote body is a JSON number"            "400" "$STATUS"
assert_json  "25d: error field present in vote error response"     '.error | type == "string"'

# 25e. POST /api/polls/:id/vote with JSON string body → 400
STATUS=$(http_post "$BASE_URL/api/polls/$POLL_ID/vote" '"string"')
assert_eq    "25e: 400 when vote body is a JSON string"            "400" "$STATUS"

# 25f. POST /api/polls/:id/vote with JSON array body → 400
STATUS=$(http_post "$BASE_URL/api/polls/$POLL_ID/vote" '[{"optionIndex":0}]')
assert_eq    "25f: 400 when vote body is a JSON array"             "400" "$STATUS"

# ────────────────────────────────────────────────────────────────
# 26. LONG INPUT STRINGS
# ────────────────────────────────────────────────────────────────
echo "── 26. Long Input Strings ────────────────────────────────────"

# SQLite TEXT columns have no practical size limit; the server imposes none either.
LONGSTR=$(printf 'a%.0s' {1..500})

# 26a. 500-character question → 201
STATUS=$(http_post "$BASE_URL/api/polls" \
  "{\"question\":\"$LONGSTR\",\"options\":[\"Opt A\",\"Opt B\"]}")
assert_eq    "26a: 201 on poll with 500-char question"             "201" "$STATUS"
assert_json  "26a: long question stored (non-empty)"               '.question | length > 0'
LONG_POLL_ID=$(jq -r .id "$TMPFILE")

# 26b. 500-character option texts → 201
STATUS=$(http_post "$BASE_URL/api/polls" \
  "{\"question\":\"Short Q?\",\"options\":[\"$LONGSTR\",\"$LONGSTR\"]}")
assert_eq    "26b: 201 on poll with 500-char option texts"         "201" "$STATUS"
assert_json  "26b: 2 options stored"                               '.options | length == 2'
assert_json  "26b: options[0].text length is preserved"            '.options[0].text | length > 400'

# 26c. Fetch poll with long question → full content preserved
STATUS=$(http_get "$BASE_URL/api/polls/$LONG_POLL_ID")
assert_eq    "26c: 200 fetching poll with long question"            "200" "$STATUS"
assert_json  "26c: question length is 500 chars after round-trip"  '.question | length == 500'

# 26d. Vote on poll with long question → 200, vote registered
STATUS=$(http_post "$BASE_URL/api/polls/$LONG_POLL_ID/vote" '{"optionIndex":0}')
assert_eq    "26d: 200 voting on poll with long question"           "200" "$STATUS"
assert_json  "26d: vote registered correctly"                      '.options[0].vote_count == 1'

# ────────────────────────────────────────────────────────────────
# 27. COMPLETE VOTING CYCLE — every option voted once
# ────────────────────────────────────────────────────────────────
echo "── 27. Complete Voting Cycle ─────────────────────────────────"

# Create a 4-option poll, vote on each option exactly once, then verify
# the total equals the option count and each has exactly 1 vote.
STATUS=$(http_post "$BASE_URL/api/polls" \
  '{"question":"Full cycle?","options":["Alpha","Beta","Gamma","Delta"]}')
assert_eq    "27 setup: create 4-option poll"                      "201" "$STATUS"
CYCLE_ID=$(jq -r .id "$TMPFILE")

STATUS=$(http_post "$BASE_URL/api/polls/$CYCLE_ID/vote" '{"optionIndex":0}')
assert_eq    "27a: 200 on vote for option 0"                       "200" "$STATUS"
assert_json  "27a: options[0].vote_count == 1"                     '.options[0].vote_count == 1'
assert_json  "27a: running total == 1"                             '[.options[].vote_count] | add == 1'

STATUS=$(http_post "$BASE_URL/api/polls/$CYCLE_ID/vote" '{"optionIndex":1}')
assert_eq    "27b: 200 on vote for option 1"                       "200" "$STATUS"
assert_json  "27b: options[1].vote_count == 1"                     '.options[1].vote_count == 1'
assert_json  "27b: running total == 2"                             '[.options[].vote_count] | add == 2'

STATUS=$(http_post "$BASE_URL/api/polls/$CYCLE_ID/vote" '{"optionIndex":2}')
assert_eq    "27c: 200 on vote for option 2"                       "200" "$STATUS"
assert_json  "27c: options[2].vote_count == 1"                     '.options[2].vote_count == 1'
assert_json  "27c: running total == 3"                             '[.options[].vote_count] | add == 3'

STATUS=$(http_post "$BASE_URL/api/polls/$CYCLE_ID/vote" '{"optionIndex":3}')
assert_eq    "27d: 200 on vote for option 3 (last)"                "200" "$STATUS"
assert_json  "27d: options[3].vote_count == 1"                     '.options[3].vote_count == 1'
assert_json  "27d: final total == 4 (one per option)"              '[.options[].vote_count] | add == 4'
assert_json  "27d: every option has exactly 1 vote"                '[.options[].vote_count] | all(. == 1)'

# Verify final state via GET matches vote response
STATUS=$(http_get "$BASE_URL/api/polls/$CYCLE_ID")
assert_eq    "27e: 200 fetching after full cycle"                  "200" "$STATUS"
assert_json  "27e: GET total votes == 4"                           '[.options[].vote_count] | add == 4'
assert_json  "27e: all 4 options have exactly 1 vote each via GET" '[.options[].vote_count] | all(. == 1)'

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
