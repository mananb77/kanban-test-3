# PRD Gap Analysis — Issue #1: Full-Stack Quick Poll App

> **Review Iteration**: 3
> **Date**: 2026-04-20
> **PRD Version**: Iteration 7

---

## Overview

This document identifies gaps, ambiguities, and missing elements in the PRD DIFF for the Quick Poll App. Since the base repository is empty, this is a greenfield feature — "backward compatibility" is not a concern, but completeness, clarity, and internal consistency are critical before development begins.

Total gaps identified: **8**

| ID | Priority | Dimension | Short Description |
|----|----------|-----------|-------------------|
| GAP-DIFF-001 | HIGH | Consistency / Clarity | Open questions already answered inline not marked ANSWERED |
| GAP-DIFF-002 | HIGH | Completeness | No database schema documented |
| GAP-DIFF-003 | HIGH | Consistency | Q1 (port) is OPEN despite A1 stating 3001 as default |
| GAP-DIFF-004 | MEDIUM | Completeness | SQLite write concurrency behavior not addressed |
| GAP-DIFF-005 | MEDIUM | Completeness | No error state defined for database failure at startup or during a request |
| GAP-DIFF-006 | MEDIUM | Completeness | No API contract documented (request/response shapes) |
| GAP-DIFF-007 | LOW | Consistency | Q3 (percentage vs. count) is OPEN despite Section 9 implying count-only |
| GAP-DIFF-008 | LOW | Traceability | No FR-to-AC traceability matrix |

---

## Detailed Gap Descriptions

### Gap ID: GAP-DIFF-001
**Priority**: HIGH
**Section**: Section 13 (Open Questions) vs. FR3.5, User Story B2, Assumption A5
**Description**: Three open questions (Q2, Q4, Q5) are already answered by content elsewhere in the PRD:
- **Q2** ("Results shown inline or via redirect/reload?") is answered by FR3.5 and User Story B2 AC: "no full page reload required," results replace the voting form inline.
- **Q4** ("First-time visitors see voting interface or results?") is answered by Assumption A5: "First-time visitors to a poll URL see the voting interface."
- **Q5** ("Confirmation step before voting?") is answered by User Story B2 AC: voting is single-click ("Clicking 'Vote' submits the selection").
Having these questions marked OPEN contradicts the already-documented design decisions, creating ambiguity for developers about which source is authoritative.
**Impact**: Developers may ignore the inline requirements in favor of the "OPEN" designation, leading to misimplementation or unnecessary re-work.
**Recommendation**: Mark Q2, Q4, and Q5 as **ANSWERED** in Section 13 and populate the Answer column with the decisions already reflected in the PRD body. This costs no development time — it is a 5-minute document update.

---

### Gap ID: GAP-DIFF-002
**Priority**: HIGH
**Section**: Section 7 (Functional Requirements) / Section 10 (Dependencies)
**Description**: No data schema is documented. The PRD references "polls table" and "options table" in the timeline (Phase 2) but provides no field names, types, relationships, or constraints. For example: how is the vote count stored — as a column on the options table, or in a separate votes table? Is there a `created_at` timestamp? What is the poll ID type (UUID string vs. integer)?
**Impact**: Different developers may infer different schemas from the FRs, leading to inconsistent implementations that are costly to reconcile. FR1.2 (unique identifier), FR2.1 (vote counts), and FR6.1 (durable storage) all depend on schema decisions.
**Recommendation**: Add an appendix section "Data Model" with a table listing each entity (Poll, Option), its fields, types, and relationships. Even a lightweight ERD description (3–5 rows per table) is sufficient to prevent ambiguity. Example:
- **polls**: `id` (UUID string, PK), `question` (TEXT, NOT NULL), `created_at` (INTEGER, Unix timestamp)
- **options**: `id` (INTEGER, PK), `poll_id` (UUID, FK→polls.id), `text` (TEXT, NOT NULL), `vote_count` (INTEGER, default 0)

---

### Gap ID: GAP-DIFF-003
**Priority**: HIGH
**Section**: Section 13 Q1 vs. Assumption A1
**Description**: Q1 ("What port should the application run on by default?") is marked OPEN with no answer, yet Assumption A1 in Section 10 explicitly states "3001 is used as default." This creates a split-brain: Q1 implies the decision is pending while A1 has already made the decision.
**Impact**: A developer reading Section 13 before Section 10 may wait for clarification on a question that has already been answered, blocking startup configuration.
**Recommendation**: Mark Q1 as **ANSWERED** with the answer "Default port is 3001; override via the `PORT` environment variable" and reference A1.

---

### Gap ID: GAP-DIFF-004
**Priority**: MEDIUM
**Section**: Section 8 NFR1 (Performance)
**Description**: NFR1 states "The SQLite database must support concurrent reads without blocking" but does not address concurrent write behavior. SQLite in default journal mode blocks concurrent writes. With multiple users voting simultaneously, write conflicts are possible. The PRD does not specify WAL (Write-Ahead Logging) mode, which is the standard mitigation.
**Impact**: Under moderate concurrent load (e.g., a poll shared widely), simultaneous vote submissions may result in "database is locked" errors, violating the 1-second vote responsiveness target (NFR1).
**Recommendation**: Add to NFR1 or FR6: "The SQLite database must be configured to use WAL mode to permit concurrent writes." Alternatively, document that single-writer concurrency is an accepted constraint at this scope and the 1-second SLA applies only to single-user load (as implied by "under normal single-user load" — though this phrase should be made explicit).

---

### Gap ID: GAP-DIFF-005
**Priority**: MEDIUM
**Section**: Section 8 NFR2 (Reliability)
**Description**: NFR2 addresses the scenario where the database file does not exist on startup ("the server must create it automatically") but does not define behavior for: (a) database file exists but is corrupted, (b) a request fails due to a database error mid-operation (e.g., disk full), or (c) the server cannot write to the SQLite file due to permissions.
**Impact**: Users may receive unhandled 500 errors with no meaningful feedback. This is a reliability gap, not a code-quality gap — the PRD should specify the expected user-facing behavior for these failure states.
**Recommendation**: Add to NFR2: "If a database operation fails, the API must return a 500 response with a user-readable error message. The server must log the underlying error. The server must not crash on a single request failure." This is consistent with the existing error handling in FR7.6 (validation errors return descriptive messages).

---

### Gap ID: GAP-DIFF-006
**Priority**: MEDIUM
**Section**: Section 7 (Functional Requirements)
**Description**: The three API endpoints (`POST /api/polls`, `GET /api/polls/:id`, `POST /api/polls/:id/vote`) are described by behavior (FRs) but not by contract. There is no documentation of: request body shapes, response body shapes, HTTP status codes for each outcome, or error response format.
**Impact**: The frontend and backend must be built in parallel. Without an API contract, the frontend developer must guess the exact JSON shape returned by each endpoint. Mismatches cause integration failures that are caught late.
**Recommendation**: Add an "API Reference" appendix with a table or description per endpoint covering: method, path, request body schema (field names and types), success response shape, and error response format. A minimal example:

```
POST /api/polls
Request: { question: string, options: string[] }
Success (201): { id: string, question: string, options: [{ id, text, voteCount }] }
Error (400): { error: string }
```

---

### Gap ID: GAP-DIFF-007
**Priority**: LOW
**Section**: Section 13 Q3 vs. Section 9 (UX & Design)
**Description**: Q3 ("Should the bar chart show a percentage alongside the vote count, or just the raw count?") is marked OPEN, yet Section 9 Design Guidelines describes bars that "show the vote count as a number at the end of the bar or as a label" — no mention of percentages. The design section implies count-only, but the open question implies the decision hasn't been made.
**Impact**: A developer implementing the results view may add percentage display unnecessarily or skip it and later be asked to add it, causing rework.
**Recommendation**: Mark Q3 as **ANSWERED** with the answer "Show raw vote count only; percentage is not displayed" and update Section 9 to be explicit. If percentages are desired, add them to Section 9.

---

### Gap ID: GAP-DIFF-008
**Priority**: LOW
**Section**: Section 14 (Appendix — Acceptance Criteria)
**Description**: The Appendix lists 6 acceptance criteria (AC1–AC6) from the GitHub issue, and Section 7 defines 35+ functional requirements (FR1.1–FR8.5). There is no traceability matrix linking specific FRs to the ACs they fulfill. For example, AC3 ("vote and see updated results") is fulfilled by FR3.1–FR3.5, FR4.1–FR4.3, and FR2.1, but this linkage is implicit.
**Impact**: When a developer claims AC3 is satisfied, there is no shared checklist to verify which FRs were validated. This slows QA and makes it harder to verify completeness.
**Recommendation**: Add a simple FR→AC mapping table in the Appendix. This is a documentation task requiring no engineering input.

---

## Gaps NOT Found

The following common DIFF gap patterns were checked and are **not present** in this PRD:

| Pattern | Status |
|---------|--------|
| Missing impact on existing features | N/A — greenfield feature, empty base repo |
| No backward compatibility statement | N/A — no existing users |
| Data migration without rollback plan | N/A — new database, no migration needed |
| API change without versioning strategy | N/A — new API, no versioning required |
| Scope boundaries not explicit | Section 6 Out of Scope table is thorough |
| No risk assessment | Section 11 provides 7 identified risks |
| User personas missing | Section 4 covers 3 distinct personas |
