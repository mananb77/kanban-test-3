# GAP ANALYSIS — Architecture Review Iteration 2

> **Repository**: mananb77/kanban-test-3
> **Issue**: #1 — Build a Full-Stack Quick Poll App
> **Review Mode**: TDD_DIFF (Living Documents)
> **Design Document**: `docs/design/TDD.md` (TDD_DIFF_issue-1.md absent; TDD.md is the authoritative design for this greenfield feature)
> **Requirements Document**: `docs/requirements/PRD_DIFF_issue-1.md`
> **Iteration**: 2
> **Date**: 2026-04-20
> **Reviewer**: architect-reviewer-ai

---

## Scope Note

`docs/design/TDD_DIFF_issue-1.md` does not exist. `docs/design/TDD.md` (produced by arch/iteration-1) serves as the complete and sole technical design for this greenfield feature. All gaps below reference TDD.md sections.

---

## Previous Gap Status (from prd-review/iteration-3)

The following gaps were identified in the PRD review before the TDD was written. They are assessed against TDD.md:

| Gap ID | Priority | Description | Status |
|--------|----------|-------------|--------|
| GAP-DIFF-001 | HIGH | Q2/Q4/Q5 marked OPEN in PRD despite inline answers | **FIXED** — TDD §13 explicitly resolves all Q1–Q5 |
| GAP-DIFF-002 | HIGH | No database schema in PRD | **FIXED** — TDD §4.1 provides complete SQL schema with PRAGMAs |
| GAP-DIFF-003 | HIGH | Port OPEN despite A1 setting 3001 | **FIXED** — TDD §4.3 establishes PORT=3001 as default |
| GAP-DIFF-004 | MEDIUM | SQLite WAL mode not addressed in PRD | **FIXED** — TDD §4.1, §8.1 specify WAL mode and rationale |
| GAP-DIFF-005 | MEDIUM | No error behavior for DB failures | **FIXED** — TDD §7.2 defines three-layer error model (400/404/500) |
| GAP-DIFF-006 | MEDIUM | No API contract | **FIXED** — TDD §5.1 has full request/response shapes and status codes |
| GAP-DIFF-007 | LOW | Q3 percentage vs count OPEN | **FIXED** — TDD §6.5, §13 resolves: raw count only, no percentages |
| GAP-DIFF-008 | LOW | No FR-to-AC traceability matrix | **PARTIALLY FIXED** — TDD §2.1 maps FRs to implementations and §10.1 has AC tests, but no explicit FR→AC cross-reference table exists |

---

## New Gaps (TDD vs PRD_DIFF)

### Gap ID: GAP-ARCH-001
**Status**: [NEW] NEW ISSUE
**Category**: Change Coverage
**Priority**: MEDIUM
**PRD_DIFF Requirement**: §9 Design Guidelines — "Bars animate in on results reveal"
**TDD Coverage**: TDD §6.5 (PollResults component) specifies bar width calculation, color logic, and min-width, but contains no mention of CSS transitions, animations, or any approach to the animate-in behavior required by the PRD.
**Impact**: The bar chart will appear without animation on results reveal. This violates an explicit UX requirement from PRD §9. Tailwind CSS supports transition utilities (`transition-all`, `duration-500`) that can satisfy this, but without design direction in the TDD, implementers may omit it.
**Fix Required**: Add to TDD §6.5: specify that each bar uses a CSS transition on `width` (e.g., Tailwind `transition-all duration-500 ease-out`), starting from `0%` and animating to the calculated `pct%` value on mount. Clarify the implementation approach (CSS transition vs. React state timing).

---

### Gap ID: GAP-ARCH-002
**Status**: [NEW] NEW ISSUE
**Category**: Change Coverage
**Priority**: LOW
**PRD_DIFF Requirement**: §8 NFR3 — "Interactive elements (buttons, option cards) must have visible focus states for keyboard navigation"
**TDD Coverage**: TDD §2.2 maps NFR3 to "Tailwind responsive utilities" for viewport range only. No mention of focus states, keyboard navigation, or Tailwind `focus:` utilities anywhere in the document.
**Impact**: Without explicit design direction, implementers may use Tailwind's default `focus:outline-none` reset (common in Tailwind starter configs), which removes visible focus rings. This would fail NFR3 and reduce accessibility.
**Fix Required**: Add to TDD §7 (Cross-Cutting Concerns) or §6.4 (PollVote): "All interactive elements must have visible focus states using Tailwind `focus:ring-2 focus:ring-blue-500` or equivalent. Do not apply `outline-none` without a replacement focus indicator."

---

### Gap ID: GAP-ARCH-003
**Status**: [PARTIALLY FIXED] NOT FULLY RESOLVED
**Category**: Traceability
**Priority**: LOW
**PRD_DIFF Requirement**: §14 Appendix — Acceptance Criteria AC1–AC6 must be traceable to functional requirements
**TDD Coverage**: TDD §2.1 maps FRs to implementations. TDD §10.1 maps ACs to test steps. However, there is no column or table linking specific FRs to the ACs they satisfy (e.g., AC3 is satisfied by FR3.3+FR3.4+FR3.5+FR4.1+FR4.2+FR4.3).
**Impact**: Low — implementers can infer the mapping. But automated tracking systems or future reviewers may need explicit traceability.
**Fix Required**: Add a FR→AC traceability table to TDD §2 or §10: map each AC (AC1–AC6) to the FRs it exercises.

---

## Requirements Coverage Summary

| Requirement Group | PRD_DIFF Coverage | TDD Coverage | Status |
|-------------------|------------------|--------------|--------|
| FR1: Poll Creation | §7 FR1.1–FR1.5 | TDD §5.1, §6.2 | COVERED |
| FR2: Poll Retrieval | §7 FR2.1–FR2.3 | TDD §5.1, §6.3 | COVERED |
| FR3: Voting | §7 FR3.1–FR3.5 | TDD §5.1, §6.3 | COVERED |
| FR4: Results Display | §7 FR4.1–FR4.3 | TDD §6.5 | COVERED |
| FR5: Link Sharing | §7 FR5.1–FR5.3 | TDD §6.3, §6.6 | COVERED |
| FR6: Data Persistence | §7 FR6.1–FR6.2 | TDD §4.1, §9.1 | COVERED |
| FR7: Input Validation | §7 FR7.1–FR7.6 | TDD §5.1, §6.2 | COVERED |
| FR8: Production Serving | §7 FR8.1–FR8.5 | TDD §4.4, §5.2 | COVERED |
| NFR1: Performance | §8 NFR1 | TDD §2.2, §10.2 | COVERED |
| NFR2: Reliability | §8 NFR2 | TDD §2.2, §4.2, §9.1 | COVERED |
| NFR3: Usability | §8 NFR3 | TDD §2.2 (partial) | GAP-ARCH-002 |
| NFR4: Maintainability | §8 NFR4 | TDD §3.2, §4.3 | COVERED |
| NFR5: Security | §8 NFR5 | TDD §7.1 | COVERED |
| UX Animations | §9 Design Guidelines | TDD §6.5 | GAP-ARCH-001 |
| User Stories A1–A2 | §5 Scenario A | TDD §6.2 | COVERED |
| User Stories B1–B3 | §5 Scenario B | TDD §6.3, §6.5 | COVERED |
| User Story C1 | §5 Scenario C | TDD §6.6 | COVERED |
| AC1–AC6 | §14 Appendix | TDD §10.1 | COVERED |

---

## Gap Count Summary

| Priority | New Gaps | Previously Open | Total Open |
|----------|----------|-----------------|------------|
| CRITICAL | 0 | 0 | 0 |
| HIGH | 0 | 0 (all fixed) | 0 |
| MEDIUM | 1 | 0 | 1 |
| LOW | 2 | 0 | 2 |
| **TOTAL** | **3** | **0** | **3** |
