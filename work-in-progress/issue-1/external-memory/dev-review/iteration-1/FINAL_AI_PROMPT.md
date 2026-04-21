# DEBUG: Final AI Prompt

> **Generated**: 2026-04-21T00:16:31.691Z
> **Role**: reviewer-ai
> **Iteration**: 1
> **Total Characters**: 67431

---


## WIP EXTERNAL MEMORY SYSTEM (REVIEWER)

This is review iteration 1 of issue #1.
You MUST use the generic WIP directory structure for external memory:

**WIP Directory Structure:**
`/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/`
  |- documents/                 # Input documents (created by developer)
  +- external-memory/           # AI artifacts

**CRITICAL - WORKING DIRECTORY VERIFICATION**:
Before creating ANY files, you MUST use ABSOLUTE paths.
The WIP directory is at this EXACT absolute path:
`/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/`

IMPORTANT RULES:
1. ✅ Use ABSOLUTE paths for ALL file writes (paths starting with `/`)
2. ❌ Do NOT use relative paths or assume any working directory
3. ✅ The path above is ABSOLUTE and COMPLETE - use it exactly as shown
4. ✅ If you need to verify: the absolute path starts with `/persistent/git-workspaces/`
5. ✅ Before writing files, verify you are using the FULL absolute path

Example of CORRECT directory creation:
- `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/...` (ABSOLUTE path)

Example of WRONG directory creation (DO NOT DO THIS):
- `work-in-progress/issue-1/external-memory/...` (relative path)
- Relative paths will create files at the WRONG location!

      |- dev/                    # Developer's artifacts
      |   +- iteration-1/   # ALREADY EXISTS
      |- dev-review/             # Your artifacts go here
      |   +- iteration-1/   # YOU WILL CREATE
      |- qa/                     # Test execution results (if exists)
      |   +- iteration-1/
      +- rca/                    # QA failure analysis (if exists)
          +- iteration-1/

**PHASE 0A: Load Developer's External Memory (DO FIRST)**
1. Navigate to: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev/iteration-1/`
2. Read ALL developer artifacts (they should already exist from developer workflow):
   - DATABASE_SCHEMA.md
   - API_CONTRACTS.md
   - IMPLEMENTATION_PLAN.md
   - IMPLEMENTATION_SUMMARY.md (READ THIS FIRST!)
   - ALGORITHMS.md
   - CACHING_STRATEGY.md
   - SECURITY_REQUIREMENTS.md
   - PERFORMANCE_BUDGET.md
   - CONTRADICTIONS.md
   - TERMINOLOGY.md
   - metadata.json
3. Read ALL input documents from: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/documents/`
4. Use these as reference during review (they are your "requirements specification")

**PHASE 0B: Create Reviewer External Memory Directory**
1. Create directory: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/`
2. ALL review artifacts MUST go in this directory:
   - GAP_ANALYSIS.md
   - REVIEW_SUMMARY.md
   - CODE_QUALITY_REPORT.md
   - SECURITY_AUDIT.md
   - PERFORMANCE_REVIEW.md
   - metadata.json
3. Create metadata.json with:
   - commit_hash: (after review)
   - timestamp: "2026-04-21T00:16:31.572Z"
   - iteration: 1
   - issues_reviewed: [1]
   - gap_counts: {critical: X, high: Y, medium: Z, low: W}
   - recommendation: "PASS" or "REVIEW_AGAIN"
   - files_created: [list of all .md files]
4. Commit all artifacts: `git add /persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/`

**PHASE 0C: Commit Review Artifacts to Git**
1. After creating ALL review artifacts, commit them to git
2. Use commit message:
   "Review iteration 1 for issue #1 - [PASS/REVIEW_AGAIN]"
3. This allows:
   - Humans to access via `git pull`
   - Iteration 2 developer to read reviewer findings
   - Version history of all review iterations

**CRITICAL RULES for Reviewer External Memory:**

**PHASE 0D: Create GITHUB_COMMENT.md for Workflow**

After completing all review artifacts, create a GitHub comment file that the workflow will post:

1. Create file: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GITHUB_COMMENT.md`

2. **Content Format** (use this template):
```markdown
## 🔍 Review Iteration 1 Complete - {PASS/REVIEW_AGAIN}

**Commit**: [`{commit_hash_short}`](https://github.com/{owner}/{repo}/commit/{commit_hash})
**Recommendation**: **{PASS/REVIEW_AGAIN}** - {brief_description}
**Completion**: {percentage}% (Implementation: {impl_pct}%, Testing: {test_pct}%)

---

### 📊 Gap Analysis Summary

**Gaps Fixed (Iteration 1)**:
- ✅ **GAP-XXX-XXX** (PRIORITY) - Description

**Remaining Gaps**:
- 🔴 **GAP-XXX-XXX** (CRITICAL) - Description
- 🟠 **GAP-XXX-XXX** (HIGH) - Description
- 🟡 **GAP-XXX-XXX** (MEDIUM) - Description

**Gap Counts**:
```
CRITICAL: {count}
HIGH:     {count}
MEDIUM:   {count}
LOW:      {count}
TOTAL:    {count}
```

---

### 🎯 Iteration Progress

| Iteration | Total Gaps | Status |
|-----------|-----------|--------|
| {iteration-history-table} |

**Trend**: {IMPROVING/STABLE/DEGRADING}

---

### 🔧 Files Modified

**Iteration 1 Changes**:
1. `{file_path}` - {summary}

---

### 🔒 Security Verification

**Code Review**: ✅ COMPLETE / ⏳ PENDING
**Build Status**: ✅ PASSING / ❌ FAILING

---

### 📝 Review Documents

- **Gap Analysis**: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`

---

### ✅ Ready For / ⏳ Next Steps

**Next Steps**: {action items}

---

*🤖 Review completed by CoWeave AI Reviewer Workflow | Iteration 1 | {timestamp}*
```

3. **Why This File?**
   - Workflow reads and posts this comment automatically
   - Context-aware (you have full implementation details)
   - Debuggable (human can review before posting)
   - Consistent format across all iterations
   - Rich formatting with emoji, tables, code blocks

4. **IMPORTANT**: Commit this file along with other review artifacts

5. **Fallback**: If you don't create this file, workflow will post a generic comment from metadata.json

1. ALWAYS read from /persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev/iteration-1/ FIRST
2. ALWAYS read from /persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/documents/ (input documents)
3. ALWAYS create /persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/
4. ALWAYS save ALL review artifacts there
5. ALWAYS commit review artifacts to git
6. NEVER skip reading developer's external memory
7. NEVER create review artifacts outside the external-memory/dev-review/iteration-1/ folder

**Why This Structure:**
- Humans can access via `git clone` / `git pull`
- Iteration 2 developer will read from `external-memory/dev-review/iteration-1/`
- All artifacts are versioned in Git
- Reviewer can reference developer's original design documents
- Full audit trail of developer → reviewer → developer iterations



## Upstream Design Documents (MUST READ)

The following documents were produced by upstream phases (PRD, Architecture, etc.).
You MUST read these documents to verify the implementation against requirements and design.

- **P3 - Dev** (Phase: dev, Iteration 1): `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev/iteration-1`
- **P1 - Reqmts** (Phase: prd, Iteration 7): `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/prd/iteration-7`
- **P2 - Arch** (Phase: arch, Iteration 1): `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/arch/iteration-1`
- **P1a - PRD Review** (Phase: prd-review, Iteration 3): `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/prd-review/iteration-3`
- **P2a - Arch Review** (Phase: arch-review, Iteration 2): `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/arch-review/iteration-2`

**Document Precedence:** TDD > PRD > Architecture > Other docs
**IMPORTANT:** Read these documents COMPLETELY to verify implementation coverage.


## Previous Iteration Summary

The following is a summary of what was accomplished in the previous iteration:

## Developer Iteration 1 Complete

**Objective**: Build the full-stack Quick Poll App from scratch — React + Vite + Tailwind frontend, Node.js/Express backend, SQLite database, single-command startup.

### Changes Made
- Root `package.json` with `postinstall` (cascades `npm install` to `client/` and `server/`), `build`, and `start` scripts
- `server/db/database.js` — SQLite init with WAL mode and FK constraints, `initDb`/`getDb` module
- `server/routes/polls.js` — All 3 API endpoints with full validation and error handling
- `server/index.js` — Express server with static serving of React build and error middleware
- `client/` — Complete Vite + React + Tailwind setup with Vite proxy for `/api` during dev
- `client/src/pages/HomePage.jsx` — Poll creation form with dynamic options (2–6) and client-side validation
- `client/src/pages/PollPage.jsx` — Voting view + results view (inline switch, no reload) + Copy Link with fallback
- `client/src/components/PollVote.jsx` — Keyboard-navigable option cards with focus rings (GAP-ARCH-002)
- `client/src/components/PollResults.jsx` — Bar chart with CSS transition animation on mount (GAP-ARCH-001)

### Files Created
- `package.json`, `.gitignore`
- `server/package.json`, `server/index.js`, `server/routes/polls.js`, `server/db/database.js`
- `client/package.json`, `client/vite.config.js`, `client/tailwind.config.js`, `client/postcss.config.js`, `client/index.html`
- `client/src/main.jsx`, `client/src/App.jsx`, `client/src/index.css`
- `client/src/pages/HomePage.jsx`, `client/src/pages/PollPage.jsx`
- `client/src/components/PollForm.jsx`, `client/src/components/PollVote.jsx`, `client/src/components/PollResults.jsx`

### Testing
- All 3 API endpoints verified via curl (create, fetch, vote)
- Validation error responses verified (empty question, too few options, out-of-range vote index, unknown poll ID)
- Data persistence verified (poll survives server kill + restart)
- Vite production build succeeds: 55KB gzipped

### Acceptance Criteria
- [x] AC1: `npm install && npm run build && npm start` starts the app
- [x] AC2: Create poll with question + 2–6 options
- [x] AC3: Vote and immediately see bar chart results (no page reload)
- [x] AC4: Copy Link button — share URL for another user to vote
- [x] AC5: Poll data persists across server restart (SQLite WAL mode)
- [x] AC6: Responsive layout (320px–1440px via Tailwind)

### Architecture Gaps Addressed
- **GAP-ARCH-001** (MEDIUM): Bar chart animates from 0% → target width using `transition-all duration-500 ease-out` on mount
- **GAP-ARCH-002** (LOW): All interactive elements have `focus:ring-2 focus:ring-blue-500` focus indicators


**Use this context to understand what has already been done and what remains.**


You are an expert code reviewer conducting a systematic verification of an AI-generated implementation against comprehensive documentation.

## Review Session Information

- **Repository**: mananb77/kanban-test-3
- **Primary Workspace**: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1`
- **Implementation Path**: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3`
- **Issues Implemented**: #1
- **Review Iteration**: 1
- **Review Focus**: comprehensive
- **Gap Analysis File**: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`
- **Review Summary File**: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/REVIEW_SUMMARY.md`

## Documents to Verify Against





## Repository Documentation

No specific documents were provided as input. Before starting, explore the repository documentation directory:

`/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/docs/`

Read any relevant design documents (TDD, PRD, architecture specs) found there to verify the implementation against. Follow precedence: TDD > PRD > other docs.


---


---

## 📚 AI Synthesis Documents (Developer's External Memory)

**Location**: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/docs/po-studio/ai-synthesis/`

The developer created synthesis documents during Phase 0 of implementation. These documents distilled 13 source documents (26K+ lines) into actionable specifications (8K lines).

**Purpose**: Use these as quick reference during review instead of re-reading all source documents.

### Available Synthesis Documents:

1. **TERMINOLOGY.md** - Domain glossary (50+ terms)
   - Use to verify: Consistent naming and terminology
   - Check: Component types, token limits, status values

2. **DATABASE_SCHEMA.md** - Complete PostgreSQL schema
   - Use to verify: All 11 tables with columns, data types
   - Check: UNIQUE constraints (uk_one_base_per_team, etc.)
   - Check: CHECK constraints (chk_min_tokens, chk_token_limit)
   - Check: Foreign keys with ON DELETE behavior
   - Check: Indexes for performance
   - Check: Triggers (check_personal_prompt_limit)

3. **API_CONTRACTS.md** - All REST endpoints (30+)
   - Use to verify: Request/response schemas
   - Check: HTTP status codes (200, 201, 400, 401, 403, 404, 409, 500)
   - Check: Standard error format
   - Check: Pagination format
   - Check: Rate limiting headers

4. **CACHING_STRATEGY.md** - Redis implementation
   - Use to verify: Cache key format matches specification
   - Check: Cache-first algorithm (check cache → load DB → cache result)
   - Check: TTL strategy (1 hour, refresh on hit)
   - Check: Invalidation triggers
   - Check: Graceful degradation on Redis failure

5. **SECURITY_REQUIREMENTS.md** - Auth, RBAC, encryption
   - Use to verify: JWT validation implementation
   - Check: RBAC permission matrix (Company Admin, Team Admin, Normal User)
   - Check: Rate limiting (100 req/min per user, 5 login/15min per IP)
   - Check: Audit logging (ALL mutations with old/new values)
   - Check: Credential encryption (AES-256-GCM)
   - Check: CSRF/XSS prevention

6. **PERFORMANCE_BUDGET.md** - Performance targets
   - Use to verify: Latency targets met
   - Check: <20ms p95 for cache hit
   - Check: <100ms p95 for cache miss
   - Check: <50ms p95 for DB queries
   - Check: Connection pools (20 DB, 50 Redis)

7. **ALGORITHMS.md** - Core algorithms
   - Use to verify: Assembly algorithm implementation
   - Check: Component loading order (Base → Role → Repo → Combined → Personal)
   - Check: Token counting using @anthropic-ai/tokenizer
   - Check: Credential substitution (server-side only, NOT cached)
   - Check: Optimistic locking (version_number check)

8. **CONTRADICTIONS.md** - Design decisions
   - Use to understand: Why certain choices were made
   - Check: Document precedence used (TDD-Clarifications > TDD > PRD)
   - Check: 7+ resolved contradictions

9. **IMPLEMENTATION_PLAN.md** - Work breakdown
   - Use to verify: All 80+ tasks completed
   - Check: 5-phase plan followed
   - Check: Success criteria met

10. **IMPLEMENTATION_SUMMARY.md** - Progress tracking
    - **READ THIS FIRST** - Shows what developer completed
    - Check: Phase 0 status (should be 100%)
    - Check: Phase 1+ status
    - Check: Files created and modified
    - Check: Key decisions documented

### How to Use Synthesis Documents in Review:

**CRITICAL**: Read IMPLEMENTATION_SUMMARY.md FIRST to understand what was completed.

Then during each review phase:

**Phase 2 (Database)**:
- Open DATABASE_SCHEMA.md
- For EACH table: Verify columns, constraints, indexes match specification
- For EACH gap found: Reference DATABASE_SCHEMA.md line number in GAP_ANALYSIS.md
- Example: "Expected (DATABASE_SCHEMA.md:45): uk_one_base_per_team constraint"

**Phase 3 (API)**:
- Open API_CONTRACTS.md
- For EACH endpoint: Verify request/response schema matches specification
- For EACH gap found: Reference API_CONTRACTS.md line number
- Example: "Expected (API_CONTRACTS.md:234): 429 status code with Retry-After header"

**Phase 4 (Algorithms)**:
- Open ALGORITHMS.md
- Verify assembly algorithm implementation matches pseudocode
- For EACH gap found: Reference ALGORITHMS.md line number
- Example: "Expected (ALGORITHMS.md:89): Base prompt is REQUIRED (fail if missing)"

**Phase 5 (Caching)**:
- Open CACHING_STRATEGY.md
- Verify cache key format matches specification
- For EACH gap found: Reference CACHING_STRATEGY.md line number
- Example: "Expected (CACHING_STRATEGY.md:56): coweave:po_studio:{team}:{role}:{repos}:{user}"

**Phase 6 (Security)**:
- Open SECURITY_REQUIREMENTS.md
- Verify RBAC matrix implementation
- For EACH gap found: Reference SECURITY_REQUIREMENTS.md line number
- Example: "Expected (SECURITY_REQUIREMENTS.md:123): Audit log for ALL mutations"

**Phase 7 (Edge Cases)**:
- Reference CONTRADICTIONS.md to understand design decisions
- Check: Why was a particular approach chosen?
- Example: "CONTRADICTIONS.md explains: Personal prompts in V1 (not V2)"

**Phase 8 (Performance)**:
- Open PERFORMANCE_BUDGET.md
- Verify latency targets
- For EACH gap found: Reference PERFORMANCE_BUDGET.md line number
- Example: "Expected (PERFORMANCE_BUDGET.md:78): <20ms p95 for cache hit"

### GAP_ANALYSIS.md Format with Synthesis References:

For EACH gap, reference the synthesis document:

```markdown
### Gap ID: GAP-DB-001
**Document Reference**: DATABASE_SCHEMA.md:45-52
**Requirement**: Unique constraint on base_prompts.team_id
**Expected**:
```sql
CONSTRAINT uk_one_base_per_team UNIQUE (team_id)
  WHERE deleted_on IS NULL
```
**Actual**: No unique constraint found in BasePrompt entity
**Status**: ❌ MISSING
**Priority**: CRITICAL
**Impact**: Multiple base prompts per team possible (data integrity violation)
**Fix Required**:
1. Add unique constraint to base_prompts table
2. Add unique index: CREATE UNIQUE INDEX idx_base_one_per_team ON base_prompts(team_id) WHERE deleted_on IS NULL
3. Update BasePrompt entity with @Index decorator
4. Test: Try creating 2 base prompts for same team, expect 409 Conflict
```

### Gap ID: GAP-API-003
**Document Reference**: API_CONTRACTS.md:234-245
**Requirement**: Rate limiting with 429 status code
**Expected**:
- Response: 429 Too Many Requests
- Headers: X-RateLimit-Limit, X-RateLimit-Remaining, Retry-After
**Actual**: No rate limiting middleware found
**Status**: ❌ MISSING
**Priority**: HIGH
**Impact**: Service vulnerable to abuse
**Fix Required**:
1. Implement rate limiting middleware using express-rate-limit
2. Add rate limit headers to all responses
3. Return 429 with Retry-After when limit exceeded
4. Test: Make 101 requests in 1 minute, expect 429 on request 101
```

---

### Benefits of Using Synthesis Documents:

1. **Faster Review**: 8K lines vs 26K lines (70% reduction)
2. **Consistent References**: All gaps reference same synthesis docs
3. **Clear Expectations**: Synthesis docs show EXACTLY what should exist
4. **Conflict Resolution**: CONTRADICTIONS.md explains design decisions
5. **Progress Tracking**: IMPLEMENTATION_SUMMARY.md shows what's done
6. **Human Readable**: Synthesis docs can be reviewed by human developers

---

## Review Process (SYSTEMATIC - DO NOT SKIP ANY PHASE)

### PHASE 1: Re-Read ALL Documents Completely

**CRITICAL**: You must read EVERY document line-by-line. Do NOT assume you know the requirements from previous implementation.

**For large documents (>1000 lines)**, use 3-pass reading strategy:
1. **Pass 1**: Structure scan (table of contents, section headers)
2. **Pass 2**: Section-by-section detailed read
3. **Pass 3**: Cross-reference and verify

**For EACH document**:
1. Read completely (use 3-pass strategy for large docs)
2. For EVERY requirement found, check implementation
3. Create `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md` with format:

```markdown
# Gap Analysis - Iteration 1
## Date: 2026-04-21T00:16:31.572Z

## Document: {document_name}

### Requirement: {requirement_text}
- **Location**: {document_section}, Line {line_number}
- **Expected**: {what_should_exist}
- **Actual**: {what_exists_or_missing}
- **Status**: ✅ IMPLEMENTED | ⚠️ PARTIAL | ❌ MISSING | 🐛 INCORRECT
- **Priority**: CRITICAL | HIGH | MEDIUM | LOW
- **Fix Required**: {detailed_description_of_fix}

### Requirement: ...
```

---

### PHASE 2: Database Verification (If Applicable)

If implementation includes database:

- [ ] Read `DATABASE_SCHEMA.md` or TDD database section
- [ ] Verify ALL tables exist with correct schema
- [ ] Verify ALL UNIQUE constraints (e.g., `uk_one_base_per_team`, `uk_role_per_team`)
- [ ] Verify ALL CHECK constraints (e.g., `chk_min_tokens`, `chk_token_limit`)
- [ ] Verify ALL triggers (e.g., `check_personal_prompt_limit()`)
- [ ] Verify ALL foreign keys with correct `ON DELETE` behavior
- [ ] Verify ALL indexes created
- [ ] Verify soft delete: `deleted_on` column in all tables
- [ ] Verify soft delete queries: `WHERE deleted_on IS NULL` in ALL queries
- [ ] Verify multi-tenancy: `company_id` in ALL tables and ALL queries filter by it
- [ ] Verify migrations follow "strictly additive" principle (no renames, no deletes)

**For EACH gap found**: Add to `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md` with:
- Exact requirement from document
- What's missing or incorrect
- Priority (CRITICAL for data integrity issues)
- Detailed fix

---

### PHASE 3: API Verification (If Applicable)

If implementation includes API:

- [ ] Read `API_CONTRACTS.md` or TDD API section
- [ ] Verify ALL endpoints implemented
- [ ] Verify standard error response format
- [ ] Verify ALL HTTP status codes correct (200, 201, 400, 401, 403, 404, 409, 500)
- [ ] Verify JWT validation on all protected endpoints
- [ ] Verify RBAC permission checks (Company Admin, Team Admin, Normal User)
- [ ] Verify rate limiting (e.g., 100 req/min per user, 5 login/15min per IP)
- [ ] Verify optimistic locking with `version_number` or `updated_at` check
- [ ] Verify activity logging: ALL mutations logged with (user_id, action, entity_type, entity_id, old_value, new_value)
- [ ] Verify pagination format
- [ ] Verify query parameter validation

**For EACH gap found**: Add to `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`

---

### PHASE 4: Core Algorithm Verification (If Applicable)

If implementation has core business logic algorithms:

- [ ] Read `ALGORITHMS.md` or TDD algorithm sections
- [ ] Verify algorithm implementation matches specification EXACTLY
- [ ] Verify order of operations (e.g., for PO Studio: Base → Role → Repo(s) → Combined → Personal)
- [ ] Verify required components (e.g., base prompt REQUIRED, fail if missing)
- [ ] Verify validation rules (e.g., minimum tokens, token limits)
- [ ] Verify token counting uses correct library (e.g., @anthropic-ai/tokenizer)
- [ ] Verify cache key format matches specification
- [ ] Verify cache key includes all necessary parameters

**For EACH gap found**: Add to `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`

---

### PHASE 5: Caching Verification (If Applicable)

If implementation includes caching:

- [ ] Read `CACHING_STRATEGY.md` or TDD caching section
- [ ] Verify cache key design matches specification
- [ ] Verify TTL strategy correct
- [ ] Verify invalidation rules implemented (delete on update, team changes)
- [ ] Verify cache-first algorithm with lazy loading
- [ ] Verify graceful degradation (works without cache)
- [ ] Verify cache namespace/keyspace correct (e.g., `coweave:po_studio:*`)

**For EACH gap found**: Add to `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`

---

### PHASE 6: Security Verification

- [ ] Read `SECURITY_REQUIREMENTS.md` or TDD security section
- [ ] Verify JWT validation with correct secret
- [ ] Verify RBAC enforced on all protected operations
- [ ] Verify rate limiting implemented
- [ ] Verify audit logging (ALL mutations)
- [ ] Verify CSRF protection (SameSite=Strict + CSRF tokens)
- [ ] Verify SQL injection prevention (parameterized queries, ORM)
- [ ] Verify credential encryption (e.g., AES-256-GCM)
- [ ] Verify secrets detection in user input
- [ ] Verify input validation (XSS, injection)

**For EACH gap found**: Add to `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`

---

### PHASE 7: Edge Cases Verification

- [ ] Read `EDGE_CASES.md` or edge cases document
- [ ] For EACH CRITICAL edge case: verify tested and handled
- [ ] For EACH HIGH edge case: verify tested and handled
- [ ] Verify recovery paths implemented
- [ ] Verify error messages match specifications
- [ ] Verify boundary conditions tested (min/max values, empty strings, null, undefined)
- [ ] Verify concurrent access scenarios tested

**For EACH gap found**: Add to `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`

---

### PHASE 8: Performance Verification (If Applicable)

If performance requirements specified:

- [ ] Read `PERFORMANCE_BUDGET.md` or TDD performance section
- [ ] Verify latency targets met (e.g., <100ms p95 for assembly, <50ms p95 for DB queries)
- [ ] Verify cache hit rate targets met (e.g., >80%)
- [ ] Verify load testing conducted with specified concurrent users (e.g., 25 concurrent users)
- [ ] Verify database connection pool sized correctly (e.g., 20 connections)
- [ ] Verify Redis connection pool sized correctly (e.g., 50 connections)

**For EACH gap found**: Add to `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`

---

### PHASE 9: Branding/Design Verification (If Applicable)

If UI/frontend implementation:

- [ ] Read `BRANDING_DESIGN_SYSTEM.md` or branding documents
- [ ] Verify colors match specification (hex codes exact)
- [ ] Verify typography (font family, weights, sizes)
- [ ] Verify spacing values (padding, margins, gutters)
- [ ] Verify border radius values
- [ ] Verify dark/light mode: same spacing, only colors change
- [ ] Verify zero layout shift on theme toggle
- [ ] Verify accessibility: WCAG compliance (contrast ratios, keyboard navigation, ARIA labels)

**For EACH gap found**: Add to `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`

---

### PHASE 10: Integration Atomicity Verification (If Applicable)

If implementation integrates with external systems:

- [ ] Read `INTEGRATION_ATOMICITY.md` or TDD integration section
- [ ] Verify atomic operations use database transactions
- [ ] Verify retry logic implemented (e.g., 3 retries with exponential backoff)
- [ ] Verify rollback logic on failure
- [ ] Verify auto-cleanup on permanent failure
- [ ] Verify integration tests cover failure scenarios

**For EACH gap found**: Add to `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`

---

### PHASE 11: Testing Verification

- [ ] Verify unit tests exist for all business logic
- [ ] Verify integration tests exist for database operations
- [ ] Verify integration tests exist for API endpoints
- [ ] Verify E2E tests exist for critical user flows
- [ ] Verify load tests exist (if performance requirements specified)
- [ ] Verify all tests are passing
- [ ] Verify test coverage meets requirements (e.g., >80%)

**For EACH gap found**: Add to `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`

---

### PHASE 12: Documentation Verification

- [ ] Verify `IMPLEMENTATION_PLAN.md` exists and complete
- [ ] Verify `IMPLEMENTATION_SUMMARY.md` exists and complete
- [ ] Verify API documentation exists (if API implemented)
- [ ] Verify README updated with new features
- [ ] Verify architecture diagrams updated (if applicable)

**For EACH gap found**: Add to `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`

---

### PHASE 13: Apply ALL Fixes

**For EACH gap in `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md` with status ❌ MISSING or 🐛 INCORRECT**:

1. **Prioritize**: Fix CRITICAL first, then HIGH, then MEDIUM, then LOW
2. **Apply fix**: Make code changes to address the gap
3. **Add/update tests**: If gap relates to untested behavior, add tests
4. **Mark as ✅ FIXED**: Update `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md` to show gap is fixed
5. **Use TodoWrite**: Track each fix as a separate todo item

**Important**:
- DO NOT skip CRITICAL or HIGH priority gaps
- ALWAYS add tests for new fixes
- ALWAYS verify fix works before marking as ✅ FIXED

---

### PHASE 14: Create Review Summary

Create `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/REVIEW_SUMMARY.md` with:

```markdown
# Review Summary - Iteration 1
## Date: 2026-04-21T00:16:31.572Z
## Repository: mananb77/kanban-test-3
## Issues Reviewed: #1

## Gaps Found: {total_gaps}

### By Priority:
- **CRITICAL**: {count} ({fixed} fixed, {remaining} remaining)
- **HIGH**: {count} ({fixed} fixed, {remaining} remaining)
- **MEDIUM**: {count} ({fixed} fixed, {remaining} remaining)
- **LOW**: {count} ({fixed} fixed, {remaining} remaining)

### By Category:
- **Database**: {count} gaps
- **API**: {count} gaps
- **Core Algorithm**: {count} gaps
- **Caching**: {count} gaps
- **Security**: {count} gaps
- **Edge Cases**: {count} gaps
- **Performance**: {count} gaps
- **Branding/UI**: {count} gaps
- **Integration**: {count} gaps
- **Testing**: {count} gaps
- **Documentation**: {count} gaps

## Files Modified

{List each file with summary of changes}

## Tests Added

{List test files with count of tests added}

## Recommendation for Next Iteration

- ✅ **PASS** - No critical or high gaps remaining. Implementation ready.
- ⚠️ **REVIEW AGAIN** - {count} critical/high gaps remain. Run iteration 2.

## Notes

{Any additional observations or recommendations}
```

---

## CRITICAL INSTRUCTIONS - READ CAREFULLY

1. ✅ **ALWAYS re-read ALL documents completely** (do NOT assume previous implementation read them)
2. ✅ **ALWAYS use 3-pass strategy for large documents** (>1000 lines)
3. ✅ **ALWAYS verify EVERY checklist item** in all applicable phases
4. ✅ **ALWAYS create `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md` before fixing**
5. ✅ **ALWAYS apply fixes for CRITICAL and HIGH gaps**
6. ✅ **ALWAYS add tests for new fixes**
7. ✅ **ALWAYS create `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/REVIEW_SUMMARY.md` at the end
8. ❌ **NEVER skip edge cases or error handling**
9. ❌ **NEVER assume implementation is correct without verification**
10. ❌ **NEVER skip phases** - follow the systematic process

---

## Success Criteria

This review iteration is successful when:

- ✅ All documents re-read completely
- ✅ `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md` created with all gaps found
- ✅ All CRITICAL gaps fixed
- ✅ All HIGH gaps fixed (or remaining ≤ 2)
- ✅ Tests added for all fixes
- ✅ All tests passing
- ✅ `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/REVIEW_SUMMARY.md` created with recommendations

---

## Start Review Now

Begin with PHASE 0A: Load Developer's External Memory.

Use the TodoWrite tool to track your progress through each phase.

Good luck! 🔍


---


## WIP EXTERNAL MEMORY SYSTEM (REVIEWER)

This is review iteration 1 of issue #1.
You MUST use the generic WIP directory structure for external memory:

**WIP Directory Structure:**
`/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/`
  |- documents/                 # Input documents (created by developer)
  +- external-memory/           # AI artifacts

**CRITICAL - WORKING DIRECTORY VERIFICATION**:
Before creating ANY files, you MUST use ABSOLUTE paths.
The WIP directory is at this EXACT absolute path:
`/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/`

IMPORTANT RULES:
1. ✅ Use ABSOLUTE paths for ALL file writes (paths starting with `/`)
2. ❌ Do NOT use relative paths or assume any working directory
3. ✅ The path above is ABSOLUTE and COMPLETE - use it exactly as shown
4. ✅ If you need to verify: the absolute path starts with `/persistent/git-workspaces/`
5. ✅ Before writing files, verify you are using the FULL absolute path

Example of CORRECT directory creation:
- `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/...` (ABSOLUTE path)

Example of WRONG directory creation (DO NOT DO THIS):
- `work-in-progress/issue-1/external-memory/...` (relative path)
- Relative paths will create files at the WRONG location!

      |- dev/                    # Developer's artifacts
      |   +- iteration-1/   # ALREADY EXISTS
      |- dev-review/             # Your artifacts go here
      |   +- iteration-1/   # YOU WILL CREATE
      |- qa/                     # Test execution results (if exists)
      |   +- iteration-1/
      +- rca/                    # QA failure analysis (if exists)
          +- iteration-1/

**PHASE 0A: Load Developer's External Memory (DO FIRST)**
1. Navigate to: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev/iteration-1/`
2. Read ALL developer artifacts (they should already exist from developer workflow):
   - DATABASE_SCHEMA.md
   - API_CONTRACTS.md
   - IMPLEMENTATION_PLAN.md
   - IMPLEMENTATION_SUMMARY.md (READ THIS FIRST!)
   - ALGORITHMS.md
   - CACHING_STRATEGY.md
   - SECURITY_REQUIREMENTS.md
   - PERFORMANCE_BUDGET.md
   - CONTRADICTIONS.md
   - TERMINOLOGY.md
   - metadata.json
3. Read ALL input documents from: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/documents/`
4. Use these as reference during review (they are your "requirements specification")

**PHASE 0B: Create Reviewer External Memory Directory**
1. Create directory: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/`
2. ALL review artifacts MUST go in this directory:
   - GAP_ANALYSIS.md
   - REVIEW_SUMMARY.md
   - CODE_QUALITY_REPORT.md
   - SECURITY_AUDIT.md
   - PERFORMANCE_REVIEW.md
   - metadata.json
3. Create metadata.json with:
   - commit_hash: (after review)
   - timestamp: "2026-04-21T00:16:31.572Z"
   - iteration: 1
   - issues_reviewed: [1]
   - gap_counts: {critical: X, high: Y, medium: Z, low: W}
   - recommendation: "PASS" or "REVIEW_AGAIN"
   - files_created: [list of all .md files]
4. Commit all artifacts: `git add /persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/`

**PHASE 0C: Commit Review Artifacts to Git**
1. After creating ALL review artifacts, commit them to git
2. Use commit message:
   "Review iteration 1 for issue #1 - [PASS/REVIEW_AGAIN]"
3. This allows:
   - Humans to access via `git pull`
   - Iteration 2 developer to read reviewer findings
   - Version history of all review iterations

**CRITICAL RULES for Reviewer External Memory:**

**PHASE 0D: Create GITHUB_COMMENT.md for Workflow**

After completing all review artifacts, create a GitHub comment file that the workflow will post:

1. Create file: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GITHUB_COMMENT.md`

2. **Content Format** (use this template):
```markdown
## 🔍 Review Iteration 1 Complete - {PASS/REVIEW_AGAIN}

**Commit**: [`{commit_hash_short}`](https://github.com/{owner}/{repo}/commit/{commit_hash})
**Recommendation**: **{PASS/REVIEW_AGAIN}** - {brief_description}
**Completion**: {percentage}% (Implementation: {impl_pct}%, Testing: {test_pct}%)

---

### 📊 Gap Analysis Summary

**Gaps Fixed (Iteration 1)**:
- ✅ **GAP-XXX-XXX** (PRIORITY) - Description

**Remaining Gaps**:
- 🔴 **GAP-XXX-XXX** (CRITICAL) - Description
- 🟠 **GAP-XXX-XXX** (HIGH) - Description
- 🟡 **GAP-XXX-XXX** (MEDIUM) - Description

**Gap Counts**:
```
CRITICAL: {count}
HIGH:     {count}
MEDIUM:   {count}
LOW:      {count}
TOTAL:    {count}
```

---

### 🎯 Iteration Progress

| Iteration | Total Gaps | Status |
|-----------|-----------|--------|
| {iteration-history-table} |

**Trend**: {IMPROVING/STABLE/DEGRADING}

---

### 🔧 Files Modified

**Iteration 1 Changes**:
1. `{file_path}` - {summary}

---

### 🔒 Security Verification

**Code Review**: ✅ COMPLETE / ⏳ PENDING
**Build Status**: ✅ PASSING / ❌ FAILING

---

### 📝 Review Documents

- **Gap Analysis**: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`

---

### ✅ Ready For / ⏳ Next Steps

**Next Steps**: {action items}

---

*🤖 Review completed by CoWeave AI Reviewer Workflow | Iteration 1 | {timestamp}*
```

3. **Why This File?**
   - Workflow reads and posts this comment automatically
   - Context-aware (you have full implementation details)
   - Debuggable (human can review before posting)
   - Consistent format across all iterations
   - Rich formatting with emoji, tables, code blocks

4. **IMPORTANT**: Commit this file along with other review artifacts

5. **Fallback**: If you don't create this file, workflow will post a generic comment from metadata.json

1. ALWAYS read from /persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev/iteration-1/ FIRST
2. ALWAYS read from /persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/documents/ (input documents)
3. ALWAYS create /persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/
4. ALWAYS save ALL review artifacts there
5. ALWAYS commit review artifacts to git
6. NEVER skip reading developer's external memory
7. NEVER create review artifacts outside the external-memory/dev-review/iteration-1/ folder

**Why This Structure:**
- Humans can access via `git clone` / `git pull`
- Iteration 2 developer will read from `external-memory/dev-review/iteration-1/`
- All artifacts are versioned in Git
- Reviewer can reference developer's original design documents
- Full audit trail of developer → reviewer → developer iterations



## Upstream Design Documents (MUST READ)

The following documents were produced by upstream phases (PRD, Architecture, etc.).
You MUST read these documents to verify the implementation against requirements and design.

- **P3 - Dev** (Phase: dev, Iteration 1): `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev/iteration-1`
- **P1 - Reqmts** (Phase: prd, Iteration 7): `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/prd/iteration-7`
- **P2 - Arch** (Phase: arch, Iteration 1): `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/arch/iteration-1`
- **P1a - PRD Review** (Phase: prd-review, Iteration 3): `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/prd-review/iteration-3`
- **P2a - Arch Review** (Phase: arch-review, Iteration 2): `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/arch-review/iteration-2`

**Document Precedence:** TDD > PRD > Architecture > Other docs
**IMPORTANT:** Read these documents COMPLETELY to verify implementation coverage.


## Previous Iteration Summary

The following is a summary of what was accomplished in the previous iteration:

## Developer Iteration 1 Complete

**Objective**: Build the full-stack Quick Poll App from scratch — React + Vite + Tailwind frontend, Node.js/Express backend, SQLite database, single-command startup.

### Changes Made
- Root `package.json` with `postinstall` (cascades `npm install` to `client/` and `server/`), `build`, and `start` scripts
- `server/db/database.js` — SQLite init with WAL mode and FK constraints, `initDb`/`getDb` module
- `server/routes/polls.js` — All 3 API endpoints with full validation and error handling
- `server/index.js` — Express server with static serving of React build and error middleware
- `client/` — Complete Vite + React + Tailwind setup with Vite proxy for `/api` during dev
- `client/src/pages/HomePage.jsx` — Poll creation form with dynamic options (2–6) and client-side validation
- `client/src/pages/PollPage.jsx` — Voting view + results view (inline switch, no reload) + Copy Link with fallback
- `client/src/components/PollVote.jsx` — Keyboard-navigable option cards with focus rings (GAP-ARCH-002)
- `client/src/components/PollResults.jsx` — Bar chart with CSS transition animation on mount (GAP-ARCH-001)

### Files Created
- `package.json`, `.gitignore`
- `server/package.json`, `server/index.js`, `server/routes/polls.js`, `server/db/database.js`
- `client/package.json`, `client/vite.config.js`, `client/tailwind.config.js`, `client/postcss.config.js`, `client/index.html`
- `client/src/main.jsx`, `client/src/App.jsx`, `client/src/index.css`
- `client/src/pages/HomePage.jsx`, `client/src/pages/PollPage.jsx`
- `client/src/components/PollForm.jsx`, `client/src/components/PollVote.jsx`, `client/src/components/PollResults.jsx`

### Testing
- All 3 API endpoints verified via curl (create, fetch, vote)
- Validation error responses verified (empty question, too few options, out-of-range vote index, unknown poll ID)
- Data persistence verified (poll survives server kill + restart)
- Vite production build succeeds: 55KB gzipped

### Acceptance Criteria
- [x] AC1: `npm install && npm run build && npm start` starts the app
- [x] AC2: Create poll with question + 2–6 options
- [x] AC3: Vote and immediately see bar chart results (no page reload)
- [x] AC4: Copy Link button — share URL for another user to vote
- [x] AC5: Poll data persists across server restart (SQLite WAL mode)
- [x] AC6: Responsive layout (320px–1440px via Tailwind)

### Architecture Gaps Addressed
- **GAP-ARCH-001** (MEDIUM): Bar chart animates from 0% → target width using `transition-all duration-500 ease-out` on mount
- **GAP-ARCH-002** (LOW): All interactive elements have `focus:ring-2 focus:ring-blue-500` focus indicators


**Use this context to understand what has already been done and what remains.**


You are an expert code reviewer conducting a systematic verification of an AI-generated implementation against comprehensive documentation.

## Review Session Information

- **Repository**: mananb77/kanban-test-3
- **Primary Workspace**: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1`
- **Implementation Path**: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3`
- **Issues Implemented**: #1
- **Review Iteration**: 1
- **Review Focus**: comprehensive
- **Gap Analysis File**: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`
- **Review Summary File**: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/REVIEW_SUMMARY.md`

## Documents to Verify Against





## Repository Documentation

No specific documents were provided as input. Before starting, explore the repository documentation directory:

`/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/docs/`

Read any relevant design documents (TDD, PRD, architecture specs) found there to verify the implementation against. Follow precedence: TDD > PRD > other docs.


---


---

## 📚 AI Synthesis Documents (Developer's External Memory)

**Location**: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/docs/po-studio/ai-synthesis/`

The developer created synthesis documents during Phase 0 of implementation. These documents distilled 13 source documents (26K+ lines) into actionable specifications (8K lines).

**Purpose**: Use these as quick reference during review instead of re-reading all source documents.

### Available Synthesis Documents:

1. **TERMINOLOGY.md** - Domain glossary (50+ terms)
   - Use to verify: Consistent naming and terminology
   - Check: Component types, token limits, status values

2. **DATABASE_SCHEMA.md** - Complete PostgreSQL schema
   - Use to verify: All 11 tables with columns, data types
   - Check: UNIQUE constraints (uk_one_base_per_team, etc.)
   - Check: CHECK constraints (chk_min_tokens, chk_token_limit)
   - Check: Foreign keys with ON DELETE behavior
   - Check: Indexes for performance
   - Check: Triggers (check_personal_prompt_limit)

3. **API_CONTRACTS.md** - All REST endpoints (30+)
   - Use to verify: Request/response schemas
   - Check: HTTP status codes (200, 201, 400, 401, 403, 404, 409, 500)
   - Check: Standard error format
   - Check: Pagination format
   - Check: Rate limiting headers

4. **CACHING_STRATEGY.md** - Redis implementation
   - Use to verify: Cache key format matches specification
   - Check: Cache-first algorithm (check cache → load DB → cache result)
   - Check: TTL strategy (1 hour, refresh on hit)
   - Check: Invalidation triggers
   - Check: Graceful degradation on Redis failure

5. **SECURITY_REQUIREMENTS.md** - Auth, RBAC, encryption
   - Use to verify: JWT validation implementation
   - Check: RBAC permission matrix (Company Admin, Team Admin, Normal User)
   - Check: Rate limiting (100 req/min per user, 5 login/15min per IP)
   - Check: Audit logging (ALL mutations with old/new values)
   - Check: Credential encryption (AES-256-GCM)
   - Check: CSRF/XSS prevention

6. **PERFORMANCE_BUDGET.md** - Performance targets
   - Use to verify: Latency targets met
   - Check: <20ms p95 for cache hit
   - Check: <100ms p95 for cache miss
   - Check: <50ms p95 for DB queries
   - Check: Connection pools (20 DB, 50 Redis)

7. **ALGORITHMS.md** - Core algorithms
   - Use to verify: Assembly algorithm implementation
   - Check: Component loading order (Base → Role → Repo → Combined → Personal)
   - Check: Token counting using @anthropic-ai/tokenizer
   - Check: Credential substitution (server-side only, NOT cached)
   - Check: Optimistic locking (version_number check)

8. **CONTRADICTIONS.md** - Design decisions
   - Use to understand: Why certain choices were made
   - Check: Document precedence used (TDD-Clarifications > TDD > PRD)
   - Check: 7+ resolved contradictions

9. **IMPLEMENTATION_PLAN.md** - Work breakdown
   - Use to verify: All 80+ tasks completed
   - Check: 5-phase plan followed
   - Check: Success criteria met

10. **IMPLEMENTATION_SUMMARY.md** - Progress tracking
    - **READ THIS FIRST** - Shows what developer completed
    - Check: Phase 0 status (should be 100%)
    - Check: Phase 1+ status
    - Check: Files created and modified
    - Check: Key decisions documented

### How to Use Synthesis Documents in Review:

**CRITICAL**: Read IMPLEMENTATION_SUMMARY.md FIRST to understand what was completed.

Then during each review phase:

**Phase 2 (Database)**:
- Open DATABASE_SCHEMA.md
- For EACH table: Verify columns, constraints, indexes match specification
- For EACH gap found: Reference DATABASE_SCHEMA.md line number in GAP_ANALYSIS.md
- Example: "Expected (DATABASE_SCHEMA.md:45): uk_one_base_per_team constraint"

**Phase 3 (API)**:
- Open API_CONTRACTS.md
- For EACH endpoint: Verify request/response schema matches specification
- For EACH gap found: Reference API_CONTRACTS.md line number
- Example: "Expected (API_CONTRACTS.md:234): 429 status code with Retry-After header"

**Phase 4 (Algorithms)**:
- Open ALGORITHMS.md
- Verify assembly algorithm implementation matches pseudocode
- For EACH gap found: Reference ALGORITHMS.md line number
- Example: "Expected (ALGORITHMS.md:89): Base prompt is REQUIRED (fail if missing)"

**Phase 5 (Caching)**:
- Open CACHING_STRATEGY.md
- Verify cache key format matches specification
- For EACH gap found: Reference CACHING_STRATEGY.md line number
- Example: "Expected (CACHING_STRATEGY.md:56): coweave:po_studio:{team}:{role}:{repos}:{user}"

**Phase 6 (Security)**:
- Open SECURITY_REQUIREMENTS.md
- Verify RBAC matrix implementation
- For EACH gap found: Reference SECURITY_REQUIREMENTS.md line number
- Example: "Expected (SECURITY_REQUIREMENTS.md:123): Audit log for ALL mutations"

**Phase 7 (Edge Cases)**:
- Reference CONTRADICTIONS.md to understand design decisions
- Check: Why was a particular approach chosen?
- Example: "CONTRADICTIONS.md explains: Personal prompts in V1 (not V2)"

**Phase 8 (Performance)**:
- Open PERFORMANCE_BUDGET.md
- Verify latency targets
- For EACH gap found: Reference PERFORMANCE_BUDGET.md line number
- Example: "Expected (PERFORMANCE_BUDGET.md:78): <20ms p95 for cache hit"

### GAP_ANALYSIS.md Format with Synthesis References:

For EACH gap, reference the synthesis document:

```markdown
### Gap ID: GAP-DB-001
**Document Reference**: DATABASE_SCHEMA.md:45-52
**Requirement**: Unique constraint on base_prompts.team_id
**Expected**:
```sql
CONSTRAINT uk_one_base_per_team UNIQUE (team_id)
  WHERE deleted_on IS NULL
```
**Actual**: No unique constraint found in BasePrompt entity
**Status**: ❌ MISSING
**Priority**: CRITICAL
**Impact**: Multiple base prompts per team possible (data integrity violation)
**Fix Required**:
1. Add unique constraint to base_prompts table
2. Add unique index: CREATE UNIQUE INDEX idx_base_one_per_team ON base_prompts(team_id) WHERE deleted_on IS NULL
3. Update BasePrompt entity with @Index decorator
4. Test: Try creating 2 base prompts for same team, expect 409 Conflict
```

### Gap ID: GAP-API-003
**Document Reference**: API_CONTRACTS.md:234-245
**Requirement**: Rate limiting with 429 status code
**Expected**:
- Response: 429 Too Many Requests
- Headers: X-RateLimit-Limit, X-RateLimit-Remaining, Retry-After
**Actual**: No rate limiting middleware found
**Status**: ❌ MISSING
**Priority**: HIGH
**Impact**: Service vulnerable to abuse
**Fix Required**:
1. Implement rate limiting middleware using express-rate-limit
2. Add rate limit headers to all responses
3. Return 429 with Retry-After when limit exceeded
4. Test: Make 101 requests in 1 minute, expect 429 on request 101
```

---

### Benefits of Using Synthesis Documents:

1. **Faster Review**: 8K lines vs 26K lines (70% reduction)
2. **Consistent References**: All gaps reference same synthesis docs
3. **Clear Expectations**: Synthesis docs show EXACTLY what should exist
4. **Conflict Resolution**: CONTRADICTIONS.md explains design decisions
5. **Progress Tracking**: IMPLEMENTATION_SUMMARY.md shows what's done
6. **Human Readable**: Synthesis docs can be reviewed by human developers

---

## Review Process (SYSTEMATIC - DO NOT SKIP ANY PHASE)

### PHASE 1: Re-Read ALL Documents Completely

**CRITICAL**: You must read EVERY document line-by-line. Do NOT assume you know the requirements from previous implementation.

**For large documents (>1000 lines)**, use 3-pass reading strategy:
1. **Pass 1**: Structure scan (table of contents, section headers)
2. **Pass 2**: Section-by-section detailed read
3. **Pass 3**: Cross-reference and verify

**For EACH document**:
1. Read completely (use 3-pass strategy for large docs)
2. For EVERY requirement found, check implementation
3. Create `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md` with format:

```markdown
# Gap Analysis - Iteration 1
## Date: 2026-04-21T00:16:31.572Z

## Document: {document_name}

### Requirement: {requirement_text}
- **Location**: {document_section}, Line {line_number}
- **Expected**: {what_should_exist}
- **Actual**: {what_exists_or_missing}
- **Status**: ✅ IMPLEMENTED | ⚠️ PARTIAL | ❌ MISSING | 🐛 INCORRECT
- **Priority**: CRITICAL | HIGH | MEDIUM | LOW
- **Fix Required**: {detailed_description_of_fix}

### Requirement: ...
```

---

### PHASE 2: Database Verification (If Applicable)

If implementation includes database:

- [ ] Read `DATABASE_SCHEMA.md` or TDD database section
- [ ] Verify ALL tables exist with correct schema
- [ ] Verify ALL UNIQUE constraints (e.g., `uk_one_base_per_team`, `uk_role_per_team`)
- [ ] Verify ALL CHECK constraints (e.g., `chk_min_tokens`, `chk_token_limit`)
- [ ] Verify ALL triggers (e.g., `check_personal_prompt_limit()`)
- [ ] Verify ALL foreign keys with correct `ON DELETE` behavior
- [ ] Verify ALL indexes created
- [ ] Verify soft delete: `deleted_on` column in all tables
- [ ] Verify soft delete queries: `WHERE deleted_on IS NULL` in ALL queries
- [ ] Verify multi-tenancy: `company_id` in ALL tables and ALL queries filter by it
- [ ] Verify migrations follow "strictly additive" principle (no renames, no deletes)

**For EACH gap found**: Add to `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md` with:
- Exact requirement from document
- What's missing or incorrect
- Priority (CRITICAL for data integrity issues)
- Detailed fix

---

### PHASE 3: API Verification (If Applicable)

If implementation includes API:

- [ ] Read `API_CONTRACTS.md` or TDD API section
- [ ] Verify ALL endpoints implemented
- [ ] Verify standard error response format
- [ ] Verify ALL HTTP status codes correct (200, 201, 400, 401, 403, 404, 409, 500)
- [ ] Verify JWT validation on all protected endpoints
- [ ] Verify RBAC permission checks (Company Admin, Team Admin, Normal User)
- [ ] Verify rate limiting (e.g., 100 req/min per user, 5 login/15min per IP)
- [ ] Verify optimistic locking with `version_number` or `updated_at` check
- [ ] Verify activity logging: ALL mutations logged with (user_id, action, entity_type, entity_id, old_value, new_value)
- [ ] Verify pagination format
- [ ] Verify query parameter validation

**For EACH gap found**: Add to `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`

---

### PHASE 4: Core Algorithm Verification (If Applicable)

If implementation has core business logic algorithms:

- [ ] Read `ALGORITHMS.md` or TDD algorithm sections
- [ ] Verify algorithm implementation matches specification EXACTLY
- [ ] Verify order of operations (e.g., for PO Studio: Base → Role → Repo(s) → Combined → Personal)
- [ ] Verify required components (e.g., base prompt REQUIRED, fail if missing)
- [ ] Verify validation rules (e.g., minimum tokens, token limits)
- [ ] Verify token counting uses correct library (e.g., @anthropic-ai/tokenizer)
- [ ] Verify cache key format matches specification
- [ ] Verify cache key includes all necessary parameters

**For EACH gap found**: Add to `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`

---

### PHASE 5: Caching Verification (If Applicable)

If implementation includes caching:

- [ ] Read `CACHING_STRATEGY.md` or TDD caching section
- [ ] Verify cache key design matches specification
- [ ] Verify TTL strategy correct
- [ ] Verify invalidation rules implemented (delete on update, team changes)
- [ ] Verify cache-first algorithm with lazy loading
- [ ] Verify graceful degradation (works without cache)
- [ ] Verify cache namespace/keyspace correct (e.g., `coweave:po_studio:*`)

**For EACH gap found**: Add to `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`

---

### PHASE 6: Security Verification

- [ ] Read `SECURITY_REQUIREMENTS.md` or TDD security section
- [ ] Verify JWT validation with correct secret
- [ ] Verify RBAC enforced on all protected operations
- [ ] Verify rate limiting implemented
- [ ] Verify audit logging (ALL mutations)
- [ ] Verify CSRF protection (SameSite=Strict + CSRF tokens)
- [ ] Verify SQL injection prevention (parameterized queries, ORM)
- [ ] Verify credential encryption (e.g., AES-256-GCM)
- [ ] Verify secrets detection in user input
- [ ] Verify input validation (XSS, injection)

**For EACH gap found**: Add to `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`

---

### PHASE 7: Edge Cases Verification

- [ ] Read `EDGE_CASES.md` or edge cases document
- [ ] For EACH CRITICAL edge case: verify tested and handled
- [ ] For EACH HIGH edge case: verify tested and handled
- [ ] Verify recovery paths implemented
- [ ] Verify error messages match specifications
- [ ] Verify boundary conditions tested (min/max values, empty strings, null, undefined)
- [ ] Verify concurrent access scenarios tested

**For EACH gap found**: Add to `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`

---

### PHASE 8: Performance Verification (If Applicable)

If performance requirements specified:

- [ ] Read `PERFORMANCE_BUDGET.md` or TDD performance section
- [ ] Verify latency targets met (e.g., <100ms p95 for assembly, <50ms p95 for DB queries)
- [ ] Verify cache hit rate targets met (e.g., >80%)
- [ ] Verify load testing conducted with specified concurrent users (e.g., 25 concurrent users)
- [ ] Verify database connection pool sized correctly (e.g., 20 connections)
- [ ] Verify Redis connection pool sized correctly (e.g., 50 connections)

**For EACH gap found**: Add to `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`

---

### PHASE 9: Branding/Design Verification (If Applicable)

If UI/frontend implementation:

- [ ] Read `BRANDING_DESIGN_SYSTEM.md` or branding documents
- [ ] Verify colors match specification (hex codes exact)
- [ ] Verify typography (font family, weights, sizes)
- [ ] Verify spacing values (padding, margins, gutters)
- [ ] Verify border radius values
- [ ] Verify dark/light mode: same spacing, only colors change
- [ ] Verify zero layout shift on theme toggle
- [ ] Verify accessibility: WCAG compliance (contrast ratios, keyboard navigation, ARIA labels)

**For EACH gap found**: Add to `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`

---

### PHASE 10: Integration Atomicity Verification (If Applicable)

If implementation integrates with external systems:

- [ ] Read `INTEGRATION_ATOMICITY.md` or TDD integration section
- [ ] Verify atomic operations use database transactions
- [ ] Verify retry logic implemented (e.g., 3 retries with exponential backoff)
- [ ] Verify rollback logic on failure
- [ ] Verify auto-cleanup on permanent failure
- [ ] Verify integration tests cover failure scenarios

**For EACH gap found**: Add to `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`

---

### PHASE 11: Testing Verification

- [ ] Verify unit tests exist for all business logic
- [ ] Verify integration tests exist for database operations
- [ ] Verify integration tests exist for API endpoints
- [ ] Verify E2E tests exist for critical user flows
- [ ] Verify load tests exist (if performance requirements specified)
- [ ] Verify all tests are passing
- [ ] Verify test coverage meets requirements (e.g., >80%)

**For EACH gap found**: Add to `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`

---

### PHASE 12: Documentation Verification

- [ ] Verify `IMPLEMENTATION_PLAN.md` exists and complete
- [ ] Verify `IMPLEMENTATION_SUMMARY.md` exists and complete
- [ ] Verify API documentation exists (if API implemented)
- [ ] Verify README updated with new features
- [ ] Verify architecture diagrams updated (if applicable)

**For EACH gap found**: Add to `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md`

---

### PHASE 13: Apply ALL Fixes

**For EACH gap in `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md` with status ❌ MISSING or 🐛 INCORRECT**:

1. **Prioritize**: Fix CRITICAL first, then HIGH, then MEDIUM, then LOW
2. **Apply fix**: Make code changes to address the gap
3. **Add/update tests**: If gap relates to untested behavior, add tests
4. **Mark as ✅ FIXED**: Update `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md` to show gap is fixed
5. **Use TodoWrite**: Track each fix as a separate todo item

**Important**:
- DO NOT skip CRITICAL or HIGH priority gaps
- ALWAYS add tests for new fixes
- ALWAYS verify fix works before marking as ✅ FIXED

---

### PHASE 14: Create Review Summary

Create `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/REVIEW_SUMMARY.md` with:

```markdown
# Review Summary - Iteration 1
## Date: 2026-04-21T00:16:31.572Z
## Repository: mananb77/kanban-test-3
## Issues Reviewed: #1

## Gaps Found: {total_gaps}

### By Priority:
- **CRITICAL**: {count} ({fixed} fixed, {remaining} remaining)
- **HIGH**: {count} ({fixed} fixed, {remaining} remaining)
- **MEDIUM**: {count} ({fixed} fixed, {remaining} remaining)
- **LOW**: {count} ({fixed} fixed, {remaining} remaining)

### By Category:
- **Database**: {count} gaps
- **API**: {count} gaps
- **Core Algorithm**: {count} gaps
- **Caching**: {count} gaps
- **Security**: {count} gaps
- **Edge Cases**: {count} gaps
- **Performance**: {count} gaps
- **Branding/UI**: {count} gaps
- **Integration**: {count} gaps
- **Testing**: {count} gaps
- **Documentation**: {count} gaps

## Files Modified

{List each file with summary of changes}

## Tests Added

{List test files with count of tests added}

## Recommendation for Next Iteration

- ✅ **PASS** - No critical or high gaps remaining. Implementation ready.
- ⚠️ **REVIEW AGAIN** - {count} critical/high gaps remain. Run iteration 2.

## Notes

{Any additional observations or recommendations}
```

---

## CRITICAL INSTRUCTIONS - READ CAREFULLY

1. ✅ **ALWAYS re-read ALL documents completely** (do NOT assume previous implementation read them)
2. ✅ **ALWAYS use 3-pass strategy for large documents** (>1000 lines)
3. ✅ **ALWAYS verify EVERY checklist item** in all applicable phases
4. ✅ **ALWAYS create `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md` before fixing**
5. ✅ **ALWAYS apply fixes for CRITICAL and HIGH gaps**
6. ✅ **ALWAYS add tests for new fixes**
7. ✅ **ALWAYS create `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/REVIEW_SUMMARY.md` at the end
8. ❌ **NEVER skip edge cases or error handling**
9. ❌ **NEVER assume implementation is correct without verification**
10. ❌ **NEVER skip phases** - follow the systematic process

---

## Success Criteria

This review iteration is successful when:

- ✅ All documents re-read completely
- ✅ `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/GAP_ANALYSIS.md` created with all gaps found
- ✅ All CRITICAL gaps fixed
- ✅ All HIGH gaps fixed (or remaining ≤ 2)
- ✅ Tests added for all fixes
- ✅ All tests passing
- ✅ `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/dev-review/iteration-1/REVIEW_SUMMARY.md` created with recommendations

---

## Start Review Now

Begin with PHASE 0A: Load Developer's External Memory.

Use the TodoWrite tool to track your progress through each phase.

Good luck! 🔍
