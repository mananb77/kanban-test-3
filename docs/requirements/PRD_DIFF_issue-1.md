# PRD DIFF — Build a Full-Stack Quick Poll App

> **Type**: New Feature
> **Issue**: #1 — Build a Full-Stack Quick Poll App
> **Repository**: mananb77/kanban-test-3
> **Iteration**: 7
> **Depth Mode**: detailed
> **Coverage Score**: 90/100 — PRD Generation Mode
> **Date**: 2026-04-20

---

## Summary of Changes

This PRD DIFF documents the addition of a complete full-stack quick poll application to the kanban-test-3 repository. The base repository is an empty test harness. This feature introduces the entire application from scratch: a React frontend, a Node.js/Express backend, and a SQLite database, all within a monorepo structure.

---

## 1. Executive Summary

The kanban-test-3 repository will be extended with a full-stack quick poll application. The app enables any user to create an instant poll with a question and 2–6 options, share it via a unique link, vote anonymously, and view results as a bar chart — all without user registration or login. The application is self-contained: it runs from a single command on a single port, with no external infrastructure required.

This feature is primarily motivated by the need to evaluate agent-driven software development workflows against a real-world, production-representative full-stack application.

---

## 2. Background & Strategic Context

The kanban-test-3 project serves as a test harness for evaluating agent-driven software development workflows. The quick poll app was selected as the test vehicle because it exercises the key concerns of a real full-stack application — routing, state management, API design, database modeling, and UI — while remaining small enough to complete in a single sprint.

The "no accounts, no setup, just share a link" design philosophy keeps the scope tight while still representing a meaningful user-facing product. The choice of SQLite eliminates external database infrastructure, making the project fully self-contained and easy to spin up in any environment.

**Why now**: This is the foundational feature that transforms the empty repository into a working application, establishing the codebase structure all future iterations will build on.

---

## 3. Goals & Success Metrics

| Goal | Metric | Target |
|------|--------|--------|
| Single-command startup | `npm install && npm run build && npm start` starts the app | Must succeed from clean clone |
| Fast poll creation | Time from page load to poll creation | Under 30 seconds |
| Page load performance | Home page and poll page load time | Under 2 seconds on broadband |
| Vote responsiveness | Time from vote submission to results display | Under 1 second |
| Data persistence | Poll data survives server restart | 100% of polls and votes preserved |
| Cross-device usability | UI functions correctly on mobile and desktop | 320px–1440px viewport range |
| Option range enforcement | Polls always have 2–6 options | Enforced by UI and API validation |

---

## 4. Target Users & Personas

### Persona 1: The Poll Creator

**Who they are**: A developer, team lead, student, or individual who has a quick question they want answered by a group. They may be working on a decision (e.g., "Which library should we use?") or running a fun vote (e.g., "Best pizza topping?").

**Their needs**:
- Create a poll in under 30 seconds without signing up
- Get a shareable link immediately after creation
- See results as they come in

**Pain points**:
- Existing poll tools require account creation or are overly complex
- Sharing a poll should be as simple as pasting a URL

---

### Persona 2: The Poll Voter

**Who they are**: Someone who received a poll link via Slack, email, or chat. They have no prior knowledge of the app.

**Their needs**:
- Open the link, understand the question immediately, pick an option, and see results
- Zero friction — no login, no account, no app install

**Pain points**:
- Being forced to sign up before voting is a barrier that leads to drop-off
- Unclear UI makes it hard to know if the vote was recorded

---

### Persona 3: The Developer / Evaluator

**Who they are**: The technical stakeholder running this application to evaluate code quality and agent-driven workflow outputs.

**Their needs**:
- The app must start from a single command without manual configuration
- The code structure must follow a sensible monorepo pattern
- All acceptance criteria must pass

---

## 5. User Scenarios & User Stories

### Scenario A: Creating a Poll

A developer wants to poll their team on a technology decision. They visit the home page, type a question, add four options, and click "Create Poll." They are immediately taken to the poll page and copy the URL to share in Slack.

**User Story A1**: As a poll creator, I want to enter a question and multiple answer options so that I can gather opinions from others.

*Acceptance Criteria:*
- The home page displays a text input for the poll question
- The page shows a minimum of 2 option input fields by default
- An "Add Option" button appends a new option field (up to a maximum of 6)
- A "Remove" button is shown for any option beyond the initial 2
- The "Create Poll" button is disabled if the question is empty or fewer than 2 options contain text
- Attempting to submit with invalid input shows an inline error message

**User Story A2**: As a poll creator, I want to be redirected to the poll's shareable page immediately after creating it so that I can copy and send the link right away.

*Acceptance Criteria:*
- After successful poll creation, the user is automatically redirected to `/poll/:id`
- The URL contains the unique poll ID
- The "Copy Link" button is visible and copies the current URL to the clipboard

---

### Scenario B: Voting on a Poll

A team member receives a Slack message with a poll link. They open the link, see the question and options, pick their choice, and submit. The bar chart results appear immediately.

**User Story B1**: As a voter, I want to see the poll question and all options clearly so that I can make an informed choice.

*Acceptance Criteria:*
- The poll page displays the question prominently at the top
- All options are shown as selectable cards or radio buttons
- The page is accessible to anyone with the link, with no login required
- If the poll ID does not exist, the user sees a clear "Poll not found" message

**User Story B2**: As a voter, I want to select an option and submit my vote so that my preference is recorded.

*Acceptance Criteria:*
- Exactly one option can be selected at a time
- The "Vote" button is disabled until an option is selected
- Clicking "Vote" submits the selection and immediately shows the results view
- The results view replaces the voting form on the same page (no full page reload required)

**User Story B3**: As a voter, I want to see a bar chart of current results after voting so that I know where the poll stands.

*Acceptance Criteria:*
- The results view shows each option label alongside a proportional bar
- The bar width is proportional to each option's share of total votes
- Each option's vote count is displayed as a number
- The option with the most votes is visually distinguishable (e.g., highlighted bar)

---

### Scenario C: Sharing a Poll

After creating or voting on a poll, a user wants to send the link to someone else.

**User Story C1**: As a poll creator or voter, I want a "Copy Link" button so that I can easily share the poll URL with others.

*Acceptance Criteria:*
- A "Copy Link" button is visible on the poll page at all times
- Clicking it copies the current page URL to the clipboard
- A brief confirmation message (e.g., "Copied!") appears after clicking and disappears after 2 seconds

---

## 6. Scope & Features

### In Scope

| Feature | Description | Priority |
|---------|-------------|----------|
| Poll creation form | Question input + 2–6 dynamic option inputs + submit | Must Have |
| Unique poll URL | Each poll gets a UUID-based unique URL | Must Have |
| Anonymous voting | Select one option and submit without logging in | Must Have |
| Results bar chart | Proportional bar chart displayed after voting | Must Have |
| Copy Link button | One-click URL copy on poll page | Must Have |
| SQLite persistence | All poll and vote data stored in local SQLite file | Must Have |
| Single-command startup | `npm install && npm run build && npm start` from repo root | Must Have |
| Input validation | Reject empty questions, <2 options, invalid vote indexes | Must Have |
| Responsive UI | Works on mobile (320px+) and desktop (1024px+) | Should Have |
| "Poll not found" state | Graceful error for unknown poll IDs | Should Have |

### Out of Scope

| Feature | Reason |
|---------|--------|
| User accounts / authentication | Explicitly excluded in issue |
| Real-time WebSocket vote updates | Explicitly excluded; manual refresh acceptable |
| Deployment / CI/CD configuration | Explicitly excluded |
| Rate limiting | Explicitly excluded |
| Duplicate vote prevention | Explicitly excluded |
| Email sharing integration | Not requested |
| Poll expiration / closing | Not requested |
| Poll editing or deletion | Not requested |

---

## 7. Functional Requirements

### FR1: Poll Creation

- FR1.1: The system must accept a poll creation request containing a non-empty question string and an array of 2–6 non-empty option strings.
- FR1.2: The system must assign a globally unique identifier to each poll upon creation.
- FR1.3: The system must store the poll and all its options durably in the local database.
- FR1.4: The system must return the newly created poll (including its ID) in the response.
- FR1.5: The frontend must redirect the user to the poll page at `/poll/:id` after successful creation.

### FR2: Poll Retrieval

- FR2.1: The system must return the poll question, all options, and current vote counts when a poll is fetched by ID.
- FR2.2: The system must return a clear error response when a poll ID does not exist.
- FR2.3: The frontend must display a "Poll not found" message when the poll ID is invalid.

### FR3: Voting

- FR3.1: The system must accept a vote containing a valid option index (0-based, within bounds).
- FR3.2: The system must reject votes with an out-of-range option index.
- FR3.3: The system must increment the vote count for the selected option and return the updated poll.
- FR3.4: The frontend must disable the "Vote" button until an option is selected.
- FR3.5: The frontend must display the results view immediately after a successful vote (no full page reload).

### FR4: Results Display

- FR4.1: The results view must display each option's label and current vote count.
- FR4.2: Bar widths must be proportional to each option's share of the total vote count.
- FR4.3: The option with the highest vote count must be visually distinguished.

### FR5: Link Sharing

- FR5.1: The poll page must display a "Copy Link" button at all times.
- FR5.2: Clicking "Copy Link" must copy the current page URL to the user's clipboard.
- FR5.3: A brief confirmation message must appear after copying and disappear after approximately 2 seconds.

### FR6: Data Persistence

- FR6.1: All polls and vote counts must be stored in a SQLite file on the server's local file system.
- FR6.2: Poll data must be fully intact after the server process is restarted.

### FR7: Input Validation

- FR7.1: Poll creation must be rejected if the question is empty or whitespace-only.
- FR7.2: Poll creation must be rejected if fewer than 2 options are provided.
- FR7.3: Poll creation must be rejected if more than 6 options are provided.
- FR7.4: Poll creation must be rejected if any option is empty or whitespace-only.
- FR7.5: Vote submission must be rejected if the option index is not a non-negative integer within the valid range.
- FR7.6: Validation errors must return a clear, descriptive error message.

### FR8: Production Serving

- FR8.1: In production mode, the Express server must serve the built React frontend as static files.
- FR8.2: The root `package.json` must include an `install` script that installs dependencies for both `client/` and `server/`.
- FR8.3: The root `package.json` must include a `build` script that builds the React frontend.
- FR8.4: The root `package.json` must include a `start` script that starts the Express server (which serves the built frontend).
- FR8.5: The entire application must be accessible on a single port after running the startup sequence.

---

## 8. Non-Functional Requirements

### NFR1: Performance

- Home page and poll page must fully load within 2 seconds on a broadband connection (>10 Mbps).
- Vote submission must return a response and display results within 1 second under normal single-user load.
- The SQLite database must support concurrent reads without blocking.

### NFR2: Reliability

- The application must start successfully from a clean `git clone` after running `npm install && npm run build && npm start`.
- The SQLite database file must not be corrupted across normal server restarts.
- If the database file does not exist on startup, the server must create it automatically.

### NFR3: Usability

- The UI must be fully functional and visually correct on viewport widths from 320px (mobile) to 1440px (desktop).
- Interactive elements (buttons, option cards) must have visible focus states for keyboard navigation.
- All form errors must be communicated inline, near the relevant input field.

### NFR4: Maintainability

- The codebase must follow the monorepo structure with `client/` (frontend) and `server/` (backend) as top-level directories.
- Configuration (port, database path) should be settable via environment variables where applicable.

### NFR5: Security

- All user inputs (question, options, vote index) must be validated server-side before storage.
- [ASSUMPTION: No SQL injection prevention beyond parameterized queries needed] The SQLite driver's parameterized query support is sufficient for this scope.
- [ASSUMPTION: No HTTPS required] The application runs over HTTP only; no SSL certificates are required.

---

## 9. User Experience & Design

### UX Principles

1. **Zero friction**: No login, no account creation, no setup. A user should be able to vote within 10 seconds of clicking a link.
2. **Linear flow**: The user journey is always one of two paths — Create or Vote — and each path has clear, sequential steps.
3. **Immediate feedback**: After any action (poll creation, vote submission, link copy), the user sees an immediate visual response.
4. **Progressive disclosure**: The results view only appears after voting; first-time visitors see only the voting interface.

### Design Guidelines

- **Styling**: Tailwind CSS utility classes for all styling; no custom CSS files unless Tailwind cannot express the style.
- **Color**: A single primary accent color for interactive elements (buttons, selected state, bar chart fill). Neutral grays for backgrounds and borders.
- **Typography**: Clean sans-serif font; question text displayed at a larger size than option labels.
- **Spacing**: Generous padding on cards and form elements; clear visual separation between sections.
- **Bar Chart**: Each bar is a horizontal element whose width is a percentage of the container. The percentage is calculated as `(option votes / total votes) * 100`. Bars animate in on results reveal. Bars show the vote count as a number at the end of the bar or as a label.

### Page Layouts

**Home Page (`/`)**:
- Centered card layout on desktop; full-width on mobile
- Question input at top, option inputs below, "Add Option" / "Remove" controls, "Create Poll" button at bottom
- Clear heading: "Create a Poll"

**Poll Page (`/poll/:id`) — Voting State**:
- Question displayed prominently at top
- Options shown as selectable cards with radio-button semantics (click anywhere on the card to select)
- Selected option is visually highlighted (border color change, background tint)
- "Vote" button below options, disabled until a selection is made
- "Copy Link" button in the upper-right or below the question

**Poll Page (`/poll/:id`) — Results State**:
- Question remains at the top
- Options replaced by a results list: each row shows the option label on the left and its bar + vote count on the right
- A total vote count is shown below the chart
- "Copy Link" button remains visible

---

## 10. Assumptions, Dependencies & Constraints

### Assumptions

| ID | Assumption | Impact if Wrong |
|----|-----------|-----------------|
| A1 | [ASSUMPTION: Default port is 3001] No specific port was stated; 3001 is used as default | Application conflicts with another service; user must set PORT env variable |
| A2 | [ASSUMPTION: No duplicate vote prevention] Any visitor can vote multiple times; this is intentional per the issue spec | If prevention is later required, a session-based mechanism must be added |
| A3 | [ASSUMPTION: No HTTPS required] HTTP is sufficient for this scope | Clipboard API may require HTTPS in some browsers for "Copy Link" to work |
| A4 | [ASSUMPTION: No poll editing or deletion needed] Polls are immutable after creation | If editing is required, new API endpoints and UI flows must be designed |
| A5 | [ASSUMPTION: Results shown after voting only] First-time visitors to a poll URL see the voting interface, not the results | If results should always be visible, the page logic and FR3.5 must change |
| A6 | [ASSUMPTION: SQLite file stored in server/db/ directory] No storage path specified | If the path conflicts with deployment environments, it must be configurable |

### Dependencies

| Dependency | Version | Purpose |
|-----------|---------|---------|
| Node.js | 18+ | Backend runtime |
| npm | 9+ | Package management |
| React | 18+ | Frontend framework |
| Vite | 5+ | Frontend build tool |
| Tailwind CSS | 3+ | UI styling |
| Express | 4+ | Backend web framework |
| better-sqlite3 | Latest | SQLite database driver |
| uuid or crypto | Built-in | UUID generation for poll IDs |
| react-router-dom | 6+ | Frontend routing |

### Constraints

- The application must run on a single port in production (no separate frontend/backend ports).
- No external database — SQLite file on local disk only.
- No authentication system of any kind.
- Maximum of 6 options per poll (enforced by both UI and API).
- No WebSocket or real-time push support.

---

## 11. Risks & Mitigations

| ID | Risk | Likelihood | Impact | Mitigation |
|----|------|-----------|--------|------------|
| R1 | SQLite file cannot be created due to file system permissions | Low | High | Server creates the file on startup in a known relative path; document the path in README |
| R2 | Default port 3001 is already in use on developer's machine | Medium | Medium | Support `PORT` environment variable override; document this in README |
| R3 | Developer forgets to run build before start | Medium | Medium | `npm start` should check for or trigger the build; document startup steps clearly |
| R4 | CORS errors during local development (different ports) | High | Medium | Configure Vite dev server proxy to forward `/api/*` requests to the backend |
| R5 | Clipboard API unavailable without HTTPS | Medium | Low | Fall back gracefully; show the URL in a text input so users can copy manually |
| R6 | Bar chart rendering issues on very narrow viewports | Low | Low | Test at 320px width; use horizontal bars that wrap gracefully |
| R7 | Results show 0 votes initially (empty bar chart) | Medium | Low | Handle zero-vote state gracefully; show empty bars or a "No votes yet" message |

---

## 12. Timeline & Milestones

> Specific dates are not defined. The following phases represent relative sequencing.

### Phase 1: Project Setup
- Initialize monorepo directory structure (`client/`, `server/`)
- Configure root `package.json` with `install`, `build`, and `start` scripts
- Initialize Vite + React project in `client/`
- Configure Tailwind CSS in the React project
- Initialize Express project in `server/`
- Set up SQLite database connection and schema initialization on server startup
- **Milestone**: Running `npm run dev` in `client/` shows the Vite default page; running `node server/index.js` starts Express

### Phase 2: Backend API
- Implement database schema (polls table, options table)
- Implement `POST /api/polls` — create poll with validation
- Implement `GET /api/polls/:id` — fetch poll with vote counts
- Implement `POST /api/polls/:id/vote` — cast vote with validation
- **Milestone**: All three API endpoints return correct responses when tested with a REST client (e.g., curl or Postman)

### Phase 3: Frontend UI
- Implement home page with poll creation form (dynamic option inputs, validation, submit)
- Implement poll page — voting state (display question and options, submit vote)
- Implement poll page — results state (bar chart view after voting)
- Implement "Copy Link" button with clipboard API and confirmation feedback
- **Milestone**: Full user journey works in the Vite dev server against the running backend

### Phase 4: Integration & Production Build
- Configure Express to serve the Vite build output as static files
- Configure Vite proxy for `/api` during development
- Test `npm install && npm run build && npm start` from repo root
- Test data persistence across server restarts
- **Milestone**: All acceptance criteria pass; UI is responsive and visually clean

---

## 13. Open Questions & Decisions

| ID | Question | Priority | Status | Answer |
|----|----------|----------|--------|--------|
| Q1 | What port should the application run on by default? | LOW | OPEN | |
| Q2 | Should results be shown immediately after voting (replace voting UI inline) or after a redirect/page reload? | MEDIUM | OPEN | |
| Q3 | Should the bar chart show a percentage alongside the vote count, or just the raw count? | LOW | OPEN | |
| Q4 | Should first-time visitors to a poll URL see the voting interface or the results? | MEDIUM | OPEN | |
| Q5 | Should there be a confirmation step before casting a vote, or should voting be a single click? | LOW | OPEN | |

**Priority Levels:**
- **HIGH**: Blocks development, must resolve before TDD
- **MEDIUM**: Should resolve before development starts
- **LOW**: Can resolve during development

**To iterate on this PRD:**
1. Fill in the Answer column for questions you can answer
2. Change Status from OPEN to ANSWERED
3. Save the file and trigger the next iteration
4. AI will incorporate your answers into the PRD

---

## 14. Appendix

### Source Documents

- **GitHub Issue #1**: [Build a Full-Stack Quick Poll App](https://github.com/mananb77/kanban-test-3/issues/1) (mananb77/kanban-test-3)
- **ticket.md**: Local copy of the issue body in the repository root

### Acceptance Criteria (from Issue)

| # | Criterion | Test Method |
|---|-----------|-------------|
| AC1 | Running `npm install && npm run build && npm start` from the repo root starts the full app on a single port | Manual: run the command sequence from a clean clone |
| AC2 | A user can create a poll with a question and 2–6 options | Manual: use the home page form |
| AC3 | A user can vote on a poll and immediately see updated results | Manual: vote on a poll and verify bar chart appears |
| AC4 | A user can share a poll link and another user can vote on it | Manual: copy link, open in incognito, vote |
| AC5 | Poll data persists across server restarts (SQLite file on disk) | Manual: create poll, restart server, verify poll still exists |
| AC6 | The UI is responsive and visually clean | Manual: test on mobile viewport and desktop |

### Tech Stack (from Issue)

| Layer | Technology |
|-------|-----------|
| Frontend | React (Vite) with Tailwind CSS |
| Backend | Node.js with Express |
| Database | SQLite via `better-sqlite3` |
| Repository | Monorepo with `client/` and `server/` directories |

### Out-of-Scope Reference

The following were explicitly excluded in the issue and must not be implemented:
- User accounts or authentication of any kind
- Real-time WebSocket updates (polling or manual refresh acceptable)
- Deployment or CI/CD configuration
- Rate limiting or duplicate vote prevention
