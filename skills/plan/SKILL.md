---
name: wk-plan
description: >-
  Use when planning any non-trivial task — grills for ambiguities, researches
  the codebase in parallel, validates the plan from multiple personas, and
  produces an explicitly-numbered, agent-parallelizable plan ready for
  wk-workflow execution. Auto-invoked by wk-workflow Phase 1; directly
  invocable with /wk-plan <task>. Stops and clarifies when requirements are
  vague, conflicting, or missing acceptance criteria.
argument-hint: '<task description | "." to use current session context>'
allowed-tools:
  - AskUserQuestion
  - Agent
  - Bash
  - Read
  - Grep
  - Glob
  - Skill
model: fable
effort: high
model-invocable: true
user-invocable: true
license: MIT
group: workflows
metadata:
  author: whizzzkid
  version: '2026.06.11-192012'
  model:
    openai: o3
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# Plan

Produce a thorough, parallelizable, agent-ready plan before any code is
written. Invoked at the start of every non-trivial task — either directly
(`/wk-plan <task>`) or by `wk-workflow` Phase 1.

The output is an explicit numbered plan where every item carries an agent
assignment marker, temporal dependencies are minimized, and parallel phases
are the default.

---

## Step 0: Grill — Detect and resolve ambiguities

**HARD RULE:** Never plan a vague task. Stop here and clarify before
research or planning begins.

Scan the task description for these ambiguity signals:

| Signal | Example | Blocker? |
|---|---|---|
| No acceptance criteria | "improve the API" | Yes |
| Scope boundary missing | "refactor the auth flow" | Yes |
| Conflicting requirements | "fast AND consistent" with no priority | Yes |
| Undefined inputs | "fix the issue" without a ticket or repro | Yes |
| Vague degree | "make it better", "clean this up" | Yes |
| Missing "what must NOT change" | new feature touching shared code | Yes |
| ≥2 distinct deliverables bundled | "add X, fix Y, and refactor Z" | Yes — confirm granularity |

When ≥1 signal fires, ask the minimum set of questions (max 4) to unblock.
Use `AskUserQuestion` rather than prose so the user can answer efficiently.

**Multi-deliverable granularity.** When the prompt lists ≥2 deliverables that
could each stand alone (own ticket, commit, or PR), surface them as a numbered
list and ask "one PR or separate?" **before** planning. A bundle of N tasks
reads as a clear requirement but hides a granularity decision only the user
owns; a single deliverable with sub-tasks does not trigger this.

Structure each question with a concrete `header` label. Good question forms:

- **Definition of done:** "The task is complete when ___?"
- **Scope boundary:** "Which components / files / systems are in scope?"
- **What must not change:** "Are there behaviors that must be preserved exactly?"
- **Priority tiebreaker:** "If speed and correctness conflict, which wins?"
- **Risk tolerance:** "Is a partial rollout (flag/canary) acceptable, or must it ship atomically?"

Proceed to Step 1 only when every blocker is resolved.

---

## Step 1: Research — Parallel context gathering

Dispatch parallel `Agent` calls to build the context map before planning.
Select the relevant agents for the task type (not all are needed every time).

```
// Agent roles — dispatch the subset that applies:

Agent A — Codebase topology
  Find files, modules, and entry points relevant to the task.
  Grep for the key symbols, APIs, or config keys mentioned in the task.
  Identify the blast radius: what else imports / depends on what will change?

Agent B — Spec and ticket context
  Read linked Jira tickets (via wk-jira Stage 0) for acceptance criteria.
  Read linked spec files, ADRs, or design docs.
  Surface any open PRs touching the same files.

Agent C — Test coverage and recent history
  Find existing tests for the affected code.
  Read the last 10 git commits touching relevant files.
  Note: which behaviors are already tested? which are not?

Agent D — Prior art and patterns
  Find the closest existing implementation of a similar pattern.
  Check for shared helpers, lib modules, or utilities already in scope.
  (Informs the prefactor probe in Step 3.)
```

Collect all agent results before Step 2. Treat contradictions between agents
as a signal to probe further, not a reason to guess.

### File-role sanity check

When the user tags a file by path **and** describes its role in prose, read
the tagged file's actual purpose and compare it to the description before
accepting it as a plan target.

- If the file's content contradicts the described role and a sibling in the
  same directory is a better match, surface the mismatch before drafting:
  "The file you tagged does X — you described one that does Y; did you mean
  `{better-match}`?"
- Accepting a mis-tagged file at face value plans changes to the wrong file
  and wastes the run.

---

## Step 2: Multi-Persona Validation

Think simultaneously from multiple perspectives to surface concerns the
research phase may not have raised. Select the 3–5 personas relevant to
the task.

For each persona, answer: **"What does this plan need to include from my
perspective to be acceptable?"**

**Implementor**
- What is the smallest set of changes that satisfies the requirement?
- Are there prefactor / lift-and-shift steps needed before the new work?
- What is the correct order of changes to keep tests green at each step?

**Code Reviewer**
- What edge cases would I flag in review?
- What is the blast radius if this change is wrong?
- Are all side effects (DB, cache, queue, event bus, downstream consumers) addressed?
- Is behavior preservation provable by the test plan?

**Security**
- Does this change affect auth, authorization, input validation, or data exposure?
- Are there injection vectors, credential leaks, or TOCTOU windows?
- Does the plan include a security check step?

**Ops / Platform**
- Does this require a migration, schema change, or deploy ordering?
- What breaks on rollback? Is the change forward-compatible?
- Are observability / logging / alerting covered in the plan?

**Product / User**
- Does the plan deliver the stated requirement, or does it deliver a
  technically-correct implementation of a different thing?
- Are there user-visible gaps between what is planned and what was asked?

**For each concern raised by a persona:**
- If it reveals a missing step → add it to the plan (Step 3).
- If it reveals a scope conflict → go back to Step 0 and re-clarify.
- If it is explicitly out of scope → record it as an exclusion with a
  one-line rationale in the plan's Exclusions section.

---

## Step 3: Draft the Plan

Synthesize Step 1 (research) and Step 2 (persona concerns) into a plan
document with the following format. Write this as a fenced block for easy
copy/paste into a TodoWrite list or a PLAN.md artifact.

### Plan format

```
## Plan: <task title>

**Scope:** <one-sentence boundary — what is in and out>
**Done when:** <acceptance criteria — measurable, not aspirational>
**Parallel budget:** <N> independent agents can run simultaneously

---

### EXCLUSIONS
- <item>: <one-line rationale for excluding>

---

### Phase <letter>: <Phase Title>  [PARALLEL | SEQUENTIAL]

> PARALLEL — all steps in this phase run concurrently.
> SEQUENTIAL — each step depends on the previous one completing.

**Step <letter><n>**  [AGENT-READY | AGENT-GUIDED | HUMAN-IN-LOOP]
- **Goal:** <what this step achieves — one sentence>
- **Artifacts out:** <files changed / docs written / tests added>
- **Instructions:**
  1. <concrete imperative>
  2. <concrete imperative>
  ...
- **Commit after this step:** `<type>(<scope>): <message>`

...
```

### Step markers

Every step must carry exactly one marker:

| Marker | Meaning |
|---|---|
| `[AGENT-READY]` | Agent can complete this step autonomously without user input |
| `[AGENT-GUIDED]` | Agent executes, then reports back before the next step starts |
| `[HUMAN-IN-LOOP]` | A user decision is required before the step can complete |

### Parallelism rules

- **Default to parallel phases.** If two steps do not share a write target
  and neither's output is another's input, they go in the same parallel phase.
- **Declare a sequential dependency explicitly.** Write `SEQUENTIAL — depends
  on Phase <letter>` when the ordering is load-bearing.
- **Never serialize for tidiness.** Sequential ordering must be justified by
  a data or file dependency, not by preference for linear presentation.
- **Maximum phase depth.** If the plan has more than 5 phases, look for
  steps that can be collapsed or run earlier. Depth > 5 is a smell for
  over-specification.

### Mandatory plan elements

Every plan must contain these elements before it is valid. If any are
missing, add them before Step 4:

1. Implementation steps covering the full scope
2. A commit boundary after each meaningful unit of work
3. A documentation update step (`wk-docs`) for every changed behavior
4. A testing step: happy path, sad path, edge cases
5. An adversarial review step (`wk-adversarial-review`) before push
6. A PR offer step
7. A CI fix loop step (monitor + auto-diagnose up to 3 rounds)
8. A session retro step (`wk-retro`)

---

## Step 4: Validate the Plan

Before presenting, run a validation checklist against the draft plan:

**Requirement coverage**
- Every clarified requirement (Step 0) maps to ≥1 step.
- Every persona concern (Step 2) is either addressed by a step or
  explicitly excluded with a rationale.

**Agent-readiness**
- Every `[AGENT-READY]` step has concrete instructions (not "investigate
  and fix") — an agent can execute it without asking a clarifying question.
- Every `[HUMAN-IN-LOOP]` step names the specific decision the user must make.

**Parallelism**
- No sequential ordering exists that is not justified by a dependency.
- The parallel budget number in the header equals the maximum width
  of any parallel phase.

**Commit map**
- Every phase or step boundary has a commit. No phase ends without one.

**Mandatory elements**
- All 8 mandatory elements from Step 3 are present and numbered.

Flag every validation failure inline in the draft (`⚠️ MISSING: …`).
Resolve all flags before Step 5.

---

## Step 5: Present and Wait for Approval

Present the plan with a one-paragraph summary:

> "Plan for: <task title>
> <N> phases, <M> steps total. <P> steps are agent-parallelizable.
> Estimated commit count: <C>.
> Key risks: <top 1-2 risks surfaced by the persona pass>.
> Open questions / exclusions: <list if any>."

Then show the full plan block from Step 3.

**HARD RULE: Do not execute any step until the user approves the plan.**
The plan is a contract. Execution starts only after an explicit "yes",
"proceed", "looks good", or equivalent approval signal. Silence is not
approval.

After approval, hand off to `wk-workflow` for execution. The approved plan
replaces `wk-workflow` Phase 1's inline planning entirely — do not re-plan
in wk-workflow if wk-plan has already produced an approved plan this session.

---

## Plan Notation Reference

```
[PARALLEL]       — phase header: all steps in this phase run concurrently
[SEQUENTIAL]     — phase header: each step waits for the previous
[AGENT-READY]    — step: agent executes autonomously
[AGENT-GUIDED]   — step: agent executes, reports back before next step
[HUMAN-IN-LOOP]  — step: user decision required before step completes
⚠️ MISSING:       — validation flag: gap in plan coverage
```

---

## Integration with wk-workflow

`wk-workflow` Phase 1 invokes this skill before doing its own planning:

```
Skill(wk-plan, args="<task from session context>")
```

If wk-plan was already run this session and an approved plan exists,
wk-workflow skips its own planning and executes the approved plan directly.

When wk-plan is invoked directly (`/wk-plan`), the output is a standalone
plan that the user can then hand to wk-workflow, a multi-agent Workflow
script, or execute manually step by step.

---

## Quick Reference

| Trigger | Behavior |
|---|---|
| `/wk-plan <task>` | Full grill → research → persona → plan → approval |
| `/wk-plan` (no args) | Uses current session context as the task description |
| `Skill(wk-plan)` from wk-workflow | Replaces Phase 1 inline planning |
| Ambiguous / vague task | Stops at Step 0 and asks ≤4 clarifying questions |
| All requirements clear | Skips Step 0 grill, proceeds directly to research |

---

## Common Mistakes

- **Planning before grilling.** A plan built on a vague requirement
  produces rework. Step 0 is non-skippable.
- **Sequential by default.** Most steps can run in parallel. Declare
  dependencies explicitly — don't let caution serialize the work.
- **Vague agent instructions.** `[AGENT-READY]` steps with "investigate
  and fix" instructions will stall. Every AGENT-READY step must have
  numbered imperatives an agent can execute cold.
- **Missing exclusions.** Persona concerns that are "out of scope" but
  not recorded will resurface as reviewer comments. Write them down.
- **Executing before approval.** The plan is a contract. Starting before
  the user approves it means executing the wrong contract.
- **Ignoring the Jira ticket.** Acceptance criteria in the ticket override
  the verbal task description. Always fetch the ticket before planning.
- **Not re-running wk-plan after scope change.** If the user interrupts
  mid-execution to add scope, re-invoke wk-plan on the new scope rather
  than patching the running plan inline.

---

## Requirements

- `AskUserQuestion` tool (for Step 0 grill)
- `Agent` tool (for Step 1 parallel research)
- `Skill` tool (to invoke `wk-jira` Stage 0 when a ticket exists)
- Read/Grep/Glob/Bash for codebase research

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn plan`).
