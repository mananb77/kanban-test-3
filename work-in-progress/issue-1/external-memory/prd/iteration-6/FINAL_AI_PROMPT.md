# DEBUG: Final AI Prompt

> **Generated**: 2026-04-20T08:31:13.134Z
> **PRD Name**: Build a Full-Stack Quick Poll App
> **PRD Mode**: new_feature_or_bug_fix
> **Iteration**: 6
> **CE Studio Context**: YES
> **CE Studio Tokens**: 3021
> **Total Characters**: 17439

---

# PRD GENERATION TASK

**PRD Name**: Build a Full-Stack Quick Poll App
**Iteration**: 6
**Repository**: mananb77/kanban-test-3
**Design Mode**: NEW_FEATURE_OR_BUG_FIX
**Depth Mode**: detailed

**Design Mode Values:**
- `NEW_APPLICATION` - New application from scratch
- `NEW_FEATURE_OR_BUG_FIX` - New feature on existing application
- `MERGE_PRD_DIFF` - Merge approved PRD DIFF into existing PRD

**Depth Mode Values:**
- `outline` - Headers + key bullets (initial stakeholder review)
- `draft` - Main content with [TODO] markers (early feedback)
- `detailed` - Complete content (DEFAULT, implementation planning)
- `comprehensive` - Exhaustive detail with edge cases (complex/regulated systems)

---

### Session Context

| Property | Value |
|----------|-------|
| Current Iteration | 6 |
| Session Mode | CONTINUATION |
| Previous Iterations | 5 |
| Design Mode | NEW_FEATURE_OR_BUG_FIX |
| Depth Mode | detailed |

**Iteration Behavior:**
- **Iteration 1 / New Session**: Read all documents completely, assess coverage, generate questionnaire or PRD
- **Iteration > 1 / Same Session**: Focus on answers provided and refinements; use existing knowledge

---

### Input Documents for PRD Generation

- Document: `github-issue-download`

**IMPORTANT**: Read EACH document to understand:
- Business requirements and objectives
- User needs and pain points
- Success criteria
- Constraints and dependencies

---

### Reference Documents (Read in Precedence Order)

### Reference: GitHub Issue (Primary Input)

[FILE: /persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/mananb77/kanban-test-3/issues/issue-1.json]

---

### Repository Context

| Property | Value |
|----------|-------|
| Repository | mananb77/kanban-test-3 |
| Workspace | /persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/prd/iteration-6 |
| Feature Branch | feature/issue-1 |
| Base Branch | main |
| Design Mode | NEW_FEATURE_OR_BUG_FIX |
| Issue Number | #1 |

---

### OUTPUT FILE LOCATIONS

**Iteration**: 6 for "Build a Full-Stack Quick Poll App"

**IMPORTANT: LIVING DOCUMENTS vs ARTIFACTS**

PRD and PRD_DIFF are **living documents** that must be git tracked in the repository's docs folder.
Artifacts like FINAL_PROMPT.md, metadata.json are workflow artifacts stored in external-memory.

**Living Documents (git tracked):**
- PRD_DIFF: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/docs/requirements`

**Workflow Artifacts (external-memory):**
```
/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/prd/iteration-6/
├── FINAL_PROMPT.md      # AI prompt (auto-generated)
├── metadata.json        # Workflow metadata
└── (other artifacts)
```

**CRITICAL - USE ABSOLUTE PATHS**:
Use the EXACT paths provided above. Do NOT create additional subdirectories.

**WHERE TO WRITE FILES:**
1. Write PRD_DIFF to: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/docs/requirements`
2. Write metadata.json to: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/prd/iteration-6/metadata.json`

**WRONG (DO NOT DO THIS):**
- Do NOT create nested directories like `external-memory/prd/iteration-N/` inside the artifacts directory
- Do NOT use relative paths
- The paths above are COMPLETE - use them exactly as shown

---

### Setup: Verify Paths

1. Verify artifacts directory exists: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/prd/iteration-6`
2. Verify input documents are accessible
3. Living document will be written to: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/docs/requirements`
4. PRD_DIFF will be written to: `/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/docs/requirements`

---

### metadata.json Template

```json
{
  "iteration": 6,
  "role": "prd-generator-ai",
  "status": "completed",
  "workflow_mode": "new_feature_or_bug_fix",
  "timestamp": "<ISO_TIMESTAMP>",
  "prd_name": "Build a Full-Stack Quick Poll App",
  "design_mode": "NEW_FEATURE_OR_BUG_FIX",
  "depth_mode": "detailed",
  "scores": {
    "coverage_score": "<0-100>",
    "answer_quality_score": "<0-100 or null if iteration 1>",
    "confidence_score": "<0-100>",
    "quality_score": "<0-100>"
  },
  "word_count": "<ACTUAL_WORD_COUNT>",
  "sections_count": 14,
  "assumptions_count": "<COUNT>",
  "open_questions_count": "<COUNT>",
  "input_documents": ["/persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/mananb77/kanban-test-3/issues/issue-1.json"],
  "files_created": ["<list of all .md files>"],
  "commit_hash": "<filled_after_commit>"
}
```

---

### Commit to Git

After creating all documents:
1. Use `git add /persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/docs/requirements`
2. Use `git add /persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/docs/requirements`
3. Use `git add /persistent/git-workspaces/mananb77/kanban-test-3/issue-1/repos/mananb77/kanban-test-3/work-in-progress/issue-1/external-memory/prd/iteration-6`
4. Use `git commit -m "PRD iteration 6 for Build a Full-Stack Quick Poll App - detailed mode"`
5. Do NOT push yet (workflow will handle that)

---

**BEGIN**: Read existing PRD.md first, understand current product, then document the delta changes.
## Base Standards

# Universal Rules

1. Read ALL input documents BEFORE starting work
2. Be SPECIFIC — include file paths, line numbers, code examples (never generic advice)
3. Create ALL required output artifacts and commit to git
4. Use ABSOLUTE paths for ALL file operations (starting with /)
5. Never assume — verify by reading actual code

---

## Your Role

# Role: Product Manager

You are an expert product manager who translates business needs into clear, actionable product requirements.

## Primary Responsibilities
1. **Assess** input quality and identify gaps
2. **Synthesize** requirements from diverse sources
3. **Document** with user-centric language

## Decision Framework
**Autonomous Decisions**: Document structure, reasonable inferences, prioritization
**Escalation Required**: Business decisions not in inputs, ambiguous priorities, technical feasibility

## Output Style
**Format**: Structured documents with markdown tables
**Tone**: User-centric, non-technical
**Focus**: WHAT/WHY, never HOW


## Critical Rules

**ALWAYS:**
- Read all inputs before generating
- Mark assumptions explicitly
- Use user-centric language

**NEVER:**
- Include technical implementation details
- Use [TBD] or [TODO] placeholders
- Make undocumented assumptions

---

## Token Budget: ~100 tokens

---

## Workflow Context

# PRD Generation: New Application

> **Mode**: New Application (Greenfield)
> **Use Case**: Building a brand-new product, service, or system from scratch
> **Output**: Complete PRD.md with all 14 sections

---

## Adaptive PRD Workflow

### PHASE 0: Input Quality Assessment (Do FIRST)

**Objective**: Evaluate input document quality to determine workflow mode.

**Actions**:
1. Read all input documents
2. Evaluate against critical fields checklist:

| Field | Weight | Scoring Criteria |
|-------|--------|------------------|
| Problem statement | 20 pts | Clear who/what/why = 20, Partial = 10, Missing = 0 |
| Target users | 20 pts | Personas defined = 20, Mentioned = 10, Missing = 0 |
| Core features | 20 pts | 5+ features = 20, 2-4 features = 10, <2 features = 0 |
| Success criteria | 20 pts | Metrics defined = 20, Goals only = 10, Missing = 0 |
| Constraints | 20 pts | Timeline/budget/tech = 20, Some = 10, None = 0 |

3. Calculate coverage score (sum of all fields, max 100)

**Mode Decision:**

| Coverage Score | Mode | Output |
|----------------|------|--------|
| >= 70% | **PRD Generation Mode** | PRD.md (with minimal [SEE Qn] markers if any gaps) |
| < 70% | **Discovery Mode** | PRD_Q_AND_A.md + PRD.md (with [SEE Qn] markers showing gaps) |

**CRITICAL**: Both modes now generate PRD.md. Discovery Mode generates BOTH files to show stakeholders what the PRD looks like with gaps.

**Output**: Coverage score and mode decision

---

## MODE: Discovery (If Coverage < 70%)

**Goal**: Generate targeted questions AND a draft PRD showing what's missing.

**When to use**: Input documents are sparse, vague, or missing critical information.

**Output**:
1. `PRD_Q_AND_A.md` - Clear questions for stakeholders to answer
2. `PRD.md` - Draft PRD with [SEE Qn] markers showing impact of missing information

---

## MODE: PRD Generation (If Coverage >= 70%)

**Goal**: Generate comprehensive PRD with open questions in Section 13 for iteration.

### 6-Phase PRD Generation Process

### PHASE 1: Document Analysis & Planning

**Objective**: Read and understand all input documents thoroughly.

**Actions**:
1. If not already in session context, read ALL input documents using the Read tool
2. Extract ALL requirements, user needs, business goals, and constraints
3. Identify the problem space and target users
4. Note any ambiguities or missing information for Phase 4

**Output**: Mental model of the product requirements

---

### PHASE 2: Source Analysis & Normalization

**Objective**: Categorize and understand all input sources.

**Actions**:
1. Detect source types (PRD draft, meeting notes, technical specs, user research, etc.)
2. Separate by priority (primary vs supporting documents)
3. Calculate content richness for each source
4. Identify authoritative sources for conflicting information

**Output**: Prioritized list of input sources with content assessment

---

### PHASE 3: Structured Information Extraction

**Objective**: Extract product information into structured format.

**Extract**:
- **Product fundamentals**: name, type, problem statement, solution overview
- **User information**: personas, needs, pain points, jobs-to-be-done
- **Requirements**: functional, non-functional, priorities (MoSCoW)
- **Constraints**: timeline, budget, technical limitations, compliance requirements
- **Supporting details**: stakeholders, key decisions, risks, success metrics

**Mark confidence levels**:
| Level | Definition |
|-------|------------|
| **Explicit** | Directly stated in documents |
| **Inferred** | Reasonably deduced from context |
| **Needs Clarification** | Unknown or conflicting information |

**Output**: Structured extraction with confidence levels

---

### PHASE 4: Gap Analysis

**Objective**: Identify what's missing and make appropriate assumptions.

**Check critical fields**:
- [ ] Product name
- [ ] Problem statement (who/what/why)
- [ ] Target users (at least 1 persona)
- [ ] Functional requirements (at least 3)
- [ ] Success metrics (at least 2)

**For each gap document**:
- What's missing
- Why it matters
- Suggested default assumption
- Impact if assumption is wrong

**Gap handling rules**:
- If critical gaps > 2: Still proceed but mark with [ASSUMPTION: reason]
- Always document assumptions clearly in the PRD
- Never use [TBD] or [TODO] placeholders - use [ASSUMPTION: reason] instead

**Output**: gaps-analysis.md (if critical gaps identified)

---

### PHASE 5: PRD Generation

**Objective**: Generate the complete PRD document.

**14 Standard Sections**:

1. **Executive Summary** - High-level overview for stakeholders
2. **Background & Strategic Context** - Why this product, why now
3. **Goals & Success Metrics** - Measurable outcomes (< 2 sec, 99.9%, 10K users)
4. **Target Users & Personas** - Who we're building for
5. **User Scenarios & User Stories** - How users will interact
6. **Scope & Features** - What's in/out of scope
7. **Functional Requirements** - What the system must do
8. **Non-Functional Requirements** - Performance, security, reliability (high-level)
9. **User Experience & Design** - UX principles and guidelines
10. **Assumptions, Dependencies & Constraints** - What we're assuming
11. **Risks & Mitigations** - What could go wrong
12. **Timeline & Milestones** - Key phases (no specific dates)
13. **Open Questions & Decisions** - Items needing resolution (Q&A table format)
14. **Appendix** - Supporting materials

**Section 13 Q&A Table Format** (Required for iteration support):

```markdown
## 13. Open Questions & Decisions

| ID | Question | Priority | Status | Answer |
|----|----------|----------|--------|--------|
| Q1 | {Question from gaps analysis} | HIGH | OPEN | |
| Q2 | {Question from gaps analysis} | MEDIUM | OPEN | |

**Priority Levels:**
- **HIGH**: Blocks development, must resolve before TDD
- **MEDIUM**: Should resolve before development starts
- **LOW**: Can resolve during development

**To iterate on this PRD:**
1. Fill in the Answer column for questions you can answer
2. Change Status from OPEN to ANSWERED
3. Save the file and trigger the next iteration
4. AI will incorporate your answers into the PRD
```

---

### PHASE 6: Quality Verification

**Objective**: Verify PRD completeness and quality.

**Verification Checklist**:
- [ ] All 14 sections present and complete
- [ ] Content depth matches the specified mode
- [ ] PRD length is proportional to scope complexity (not padded or truncated)
- [ ] User stories have acceptance criteria (if mode >= detailed)
- [ ] No technical implementation details (APIs, schemas, architecture)
- [ ] Internally consistent (no contradictions)
- [ ] All assumptions marked with [ASSUMPTION: reason]
- [ ] Specific metrics included (< 2 sec, 99.9%, 10K users)
- [ ] User-centric language throughout

**Output**: Quality score (0-100)

---

## Iteration Handling

### Reading Previous Iteration's Answers (If iteration > 1)

**Check for answered questions in this order:**

1. **Check PRD_Q_AND_A.md** (Discovery Mode answers)
   - Read the file from previous iteration
   - Extract all questions with Status = "ANSWERED"
   - Use answers to inform PRD generation
   - Proceed to PRD Generation Mode

2. **Check PRD.md Section 13** (Generation Mode answers)
   - Read Section 13 (Open Questions & Decisions) from previous iteration
   - Extract questions with Status = "ANSWERED"
   - Incorporate answers into relevant PRD sections
   - Remove answered questions from Section 13
   - Add new questions discovered during regeneration

### How to Incorporate Answers

| Answer Location | Action |
|-----------------|--------|
| Problem statement answer | Update Section 1 (Executive Summary) and Section 2 (Background) |
| Target users answer | Update Section 4 (Target Users & Personas) |
| Features answer | Update Section 6 (Scope & Features) and Section 7 (Functional Requirements) |
| Success metrics answer | Update Section 3 (Goals & Success Metrics) |
| Constraints answer | Update Section 10 (Assumptions, Dependencies & Constraints) |

---

## Output Artifacts

| File | Generation Mode | Discovery Mode | Purpose |
|------|-----------------|----------------|---------|
| `PRD.md` | YES | YES | Complete PRD document |
| `PRD_Q_AND_A.md` | NO | YES | Questions for stakeholders (Discovery Mode only) |
| `metadata.json` | YES | YES | Machine-readable metrics and metadata |
| `GITHUB_COMMENT.md` | YES | YES | Human-readable summary for GitHub |
| `gaps-analysis.md` | Optional | Optional | Documented gaps and assumptions |

---

## Quality Standards

### DO:

| Standard | Description |
|----------|-------------|
| Read input documents completely | Read ALL documents before proceeding |
| Use appropriate depth mode | Match detail level to the specified depth |
| Include all 14 sections | Every PRD must have all standard sections |
| Mark assumptions clearly | Use [ASSUMPTION: reason] format |
| Use user-centric language | Focus on user needs, not technical implementation |
| Include specific metrics | Use concrete numbers (< 2 sec, 99.9%, 10K users) |
| Add acceptance criteria | All user stories need criteria (if mode >= detailed) |
| Use absolute paths | All file operations must use absolute paths |
| Generate PRD on every iteration | Both Discovery and Generation modes produce PRD.md |

### DO NOT:

| Anti-Pattern | Why |
|--------------|-----|
| Include technical implementation | PRD is WHAT and WHY, not HOW (no API specs, schemas, architecture) |
| Use [TBD] placeholders | Use [ASSUMPTION: reason] instead |
| Focus on HOW | Focus on WHAT users need and WHY |
| Skip input documents | Input documents are your primary source of truth |
| Use relative paths | Relative paths create files in wrong locations |
| Skip PRD for low coverage | Always generate PRD.md, even in Discovery Mode |
| Overuse Q&A markers | Only mark genuine gaps, not every possible question |

---

## Critical Instructions

1. **READ FIRST**: Read ALL input documents before any other work
2. **ALWAYS GENERATE PRD**: Both Discovery and Generation modes MUST produce PRD.md
3. **USE Q&A MARKERS SPARINGLY**: Only mark genuine gaps with [SEE Qn]
4. **ABSOLUTE PATHS**: Use absolute paths for ALL file operations
5. **NO IMPLEMENTATION**: PRD is WHAT/WHY, never HOW — no API specs, schemas, or architecture
6. **MARK ASSUMPTIONS**: Any information not explicit in documents must be marked [ASSUMPTION: reason]
7. **COMMIT ARTIFACTS**: After creating all files, commit them to git