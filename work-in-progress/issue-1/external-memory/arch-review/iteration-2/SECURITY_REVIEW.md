# Security Review — Architecture Iteration 2

> **Repository**: mananb77/kanban-test-3
> **Issue**: #1 — Build a Full-Stack Quick Poll App
> **Design Document**: `docs/design/TDD.md`
> **Date**: 2026-04-20
> **Reviewer**: architect-reviewer-ai

---

## Security Score: 88/100

---

## Threat Model

### Attack Surface

| Surface | Exposure | Mitigation in TDD |
|---------|----------|-------------------|
| `POST /api/polls` | Public, anonymous | Server-side validation before DB access |
| `GET /api/polls/:id` | Public, anonymous | Parameterized query; 404 on miss |
| `POST /api/polls/:id/vote` | Public, anonymous | Bounds validation; atomic increment |
| Static file serving | Public | `express.static` internal traversal protection |
| SQLite file | Local filesystem | Not exposed via HTTP |
| Clipboard API | Browser | HTTPS/localhost gated; fallback provided |

---

## Finding: PASS — SQL Injection

TDD §7.1 specifies and TDD §5.1 demonstrates `better-sqlite3` parameterized queries (`?` placeholders) for all database operations. No string interpolation in any SQL statement. Foreign key constraint enforced via `PRAGMA foreign_keys = ON`.

**Status: PASS**

---

## Finding: PASS — XSS

React JSX escapes all interpolated values by default. TDD §7.1 explicitly notes no `dangerouslySetInnerHTML` is used. Poll question and option text are rendered as text content, not as HTML.

**Status: PASS**

---

## Finding: PASS — Oversized Request Bodies

Express `json()` middleware enforces a 100kb default limit. For poll creation (question + 6 short options), the maximum legitimate payload is well under 1kb. TDD §7.1 documents this.

**Status: PASS**

---

## Finding: PASS — Path Traversal

Static file serving uses `express.static` which handles directory traversal internally. No user-controlled path segments used in `fs` operations.

**Status: PASS**

---

## Finding: INFORMATIONAL — No CORS Policy Documented

The TDD does not explicitly state that no CORS middleware is needed. In production, the React SPA and Express API are same-origin (single port), so CORS is not required. During development, the Vite proxy handles cross-origin API calls. However, the TDD §7.1 does not document this explicitly, which could lead a future developer to add `cors()` with wildcard origins unnecessarily.

**Recommendation**: Add one sentence to TDD §7.1: "No CORS middleware is required. In production, the React SPA and API are same-origin. In development, the Vite proxy eliminates cross-origin requests. Do not add the `cors` package."

**Status: INFORMATIONAL (not a vulnerability)**

---

## Finding: INFORMATIONAL — No HTTP Security Headers

The TDD does not specify HTTP security headers (`X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Content-Security-Policy`). For the stated scope (no HTTPS, no sensitive user data, no authentication), this is acceptable. If the application is ever deployed over HTTPS or handles sensitive data, these headers should be added.

**Status: INFORMATIONAL (out of scope per PRD NFR5)**

---

## Finding: PASS — Input Validation Coverage

All 7 validation rules (FR7.1–FR7.6) are implemented at both client and server layers:
- Empty/whitespace question: checked
- Option count (2–6): checked
- Empty/whitespace options: checked
- Vote index type and bounds: `Number.isInteger(optionIndex) && optionIndex >= 0 && optionIndex < opts.length`

Server is authoritative. Client validation is a UX enhancement only.

**Status: PASS**

---

## Finding: PASS — Clipboard API Security

`navigator.clipboard.writeText()` requires a secure context. TDD §6.6 and §8.3 document the browser requirement and provide a fallback: a read-only `<input>` displaying the URL for manual copy. This prevents a hard failure in HTTP (non-localhost) environments.

**Status: PASS**

---

## Security Risk Matrix

| Risk | Likelihood | Impact | Residual Risk | Mitigation |
|------|-----------|--------|---------------|------------|
| SQL injection | Very Low | High | Negligible | Parameterized queries |
| XSS | Very Low | Medium | Negligible | React JSX escaping |
| Mass polling/spam | Medium | Low | Accepted | Explicitly out of scope (no rate limiting) |
| Duplicate voting | High | Low | Accepted | Explicitly out of scope per PRD |
| Data exfiltration | Low | Low | Negligible | No sensitive data stored |
| Session hijacking | N/A | N/A | N/A | No authentication system |

---

## Overall Security Assessment

The TDD adequately addresses the security concerns appropriate for this application's scope (no authentication, no sensitive PII, no HTTPS requirement per PRD NFR5). The parameterized query approach and React's XSS escaping cover the two highest-risk vectors. Remaining informational items are acceptable given explicit out-of-scope declarations in the PRD.

**Security clearance: APPROVED for implementation at stated scope.**
