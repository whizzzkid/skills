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
model: opus
effort: xhigh
model-invocable: true
user-invocable: true
license: MIT
group: workflows
metadata:
  author: whizzzkid
  version: "2026.10.09-003641"
  model:
    openai: gpt-5.6-sol
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# Plan

Produce a thorough, parallelizable, agent-ready plan before any code is written.

Invoked at the start of every non-trivial task — directly (`/wk-plan <task>`) or
by `wk-workflow` Phase 1. Output: explicit numbered plan with agent-assignment
markers, minimized dependencies, parallel phases by default.

---

## Step 0: Grill — Detect and resolve ambiguities

**HARD RULE:** Never plan a vague task. Stop and clarify before research begins.

Scan for ambiguity signals — each is a blocker:

1. No acceptance criteria ("improve the API")
2. Scope boundary missing ("refactor the auth flow")
3. Conflicting requirements with no priority
4. Undefined inputs (no ticket or repro)
5. Vague degree ("make it better")
6. Missing "what must NOT change" on shared code
7. ≥2 distinct deliverables bundled — confirm granularity
8. Fix approach undetermined (add/produce vs disable/suppress)

**HARD RULE — one question per message.** Ask a single question, wait, ask the
next. Never a batched/numbered list. Proceed to Step 1 only when every blocker
resolves.

**Multi-deliverable granularity.** ≥2 standalone deliverables → numbered list,
ask "one PR or separate?" before planning.

**Is-a-fix-warranted gate.** Benign root cause → surface "no fix needed / close
as working-as-intended" as `[HUMAN-IN-LOOP]`. Revert already landed → plan
re-land (cherry-pick / revert-the-revert), not re-implementation.
Perception-based symptom → surface the UI-affordance gap as the real follow-up.

**Fix-philosophy branch.** Multiple valid fixes splitting "add/produce" vs
"disable/suppress" → `[HUMAN-IN-LOOP]`. Consumer-only service must never
produce — confirm role before drafting.

**Already-done pre-check.** Before grilling on re-fired/looped prompts → check:
open/merged PR, ticket status, artifact present. Complete → report and stop.

---

## Step 1: Research — Parallel context gathering

### Gate 1: Jira ticket pre-flight

Ticket found → invoke `wk-jira` Stage 0+1+2; put acceptance criteria in the plan
before exploration.

### Gate 2: User-provided artifacts first

Scan for concrete references (URLs, PRs, paths, errors, build IDs, stack frames).
Present → fetch directly before spawning agents. GitHub comment URLs →
`gh api repos/{owner}/{repo}/{pulls|issues}/comments/{id}`. MCP tools available
→ prefer over building a client.

Dispatch parallel `Agent` calls only when artifacts are exhausted and gaps remain:

```
Agent A — Codebase topology: files, modules, entry points, blast radius.
Agent B — Spec/ticket context: Jira ACs, specs/ADRs, open PRs on same files.
Agent C — Test coverage/history: existing tests, tested vs untested behaviors.
Agent D — Prior art: closest implementation, shared helpers/lib modules.
```

Contradictions between agents → probe further, not guess.

### File-role sanity check

User tags a file by path AND describes its role → read the file, compare purpose
to description. Mismatch + better sibling → surface before drafting.

---

## Step 2: Multi-Persona Validation

Think from multiple perspectives. For each: "What must this plan include to be
acceptable?"

**Implementor / Reviewer**
- Smallest change set? Correct order to keep tests green at each step?
- Edge cases to flag? Blast radius if wrong?
- All side effects (DB, cache, queue, downstream) addressed?
- Behavior preservation provable by tests?

**Security / Ops**
- Auth, authorization, input validation, data exposure affected?
- Injection vectors, credential leaks, TOCTOU windows?
- Migration, schema change, deploy ordering? Forward-compatible? Rollback safe?
- Observability covered? Proposed operations violate documented perf constraints?
  Use existing mitigation pattern (cache, background job, materialized view).

**Product**
- Delivers stated requirement, or a technically-correct different thing?
- User-visible gaps between planned and asked?

For each concern: missing step → add; scope conflict → re-clarify (Step 0);
out of scope → record in Exclusions with one-line rationale.

---

## Step 2.5: Simplest-Viable Scope Gate

**HARD RULE:** Plan the **simplest approach satisfying the stated requirement** —
never more capable, general, or defensive than asked. This gate prevents mid-task
"why are you overcomplicating this?" corrections.

List every approach the plan introduces that the user did not name:

- **Unrequested mechanism** — auth scheme, transport, caching, retry chain the task didn't mention.
- **Unrequested generality** — parameterized where concrete was asked. Rule of Three.
- **Unrequested hardening/breadth** — guards for out-of-scope inputs; systems outside target.

Surviving → one-line rationale. Otherwise drop. Uncertain → `[HUMAN-IN-LOOP]`
with simplest alternative.

**Secret-ownership probe.** Separate consumption from provisioning. Manual →
operational prerequisite. Unknown → `[HUMAN-IN-LOOP]`.

**Search-scope boundary.** Stay inside project root. Never `find /` or `grep -r /`.

---

## Step 3: Draft the Plan

Synthesize research + persona concerns into a fenced plan block with: task title,
scope boundary, measurable done criteria, parallel budget, exclusions, numbered
phases.

### Step markers

Every step carries exactly one: `[AGENT-READY]` (autonomous), `[AGENT-GUIDED]`
(execute + report back), `[HUMAN-IN-LOOP]` (user decision required).

### Parallelism

Default to parallel. Declare sequential dependencies explicitly (`depends on
Phase <X>`). Never serialize for tidiness. Max 5 phase depth — collapse or
run earlier.

### Mandatory plan elements

1. Implementation steps covering full scope
2. Commit boundary after each unit
3. `wk-docs` for every changed behavior
4. Testing: happy/sad/edge
5. `wk-adversarial-review` — once, at completion gate after PR published
6. PR offer step
7. CI fix loop (up to 3 rounds)
8. `wk-retro`
9. `wk-arch-review` at draft-complete — when plan authors/modifies arch-bearing
   artifacts (spec, ADR, RFC, design doc). Run mechanical detector; hit makes it
   mandatory, doc-only included.
10. Jira lifecycle steps (only when ticket in scope) — surface transitions as
    named numbered steps, not invisible side-effects. Mark `[AGENT-READY]` with
    auto-mode caveat.

### Commit granularity

Smallest possible — each does one logical thing, passes CI, includes doc updates.

### Probes before drafting

**Prefactor probe.** New caller of existing pattern → lift → migrate → extend.
Grep the operation; identify duplicated prologue/epilogue; lift into helper;
migrate existing caller (separate commit); extend.

**Duplication probe.** Adding to a large mixed-content file (>200 lines) → grep
the file for function/event/feature name first; match → remove/replace/merge,
never add alongside. Producing a new spec → grep open PRs; found → stack and
extend. Scaffolding a new skill → ask if it's a new verb on existing skill's
noun; yes → add routing mode.

**Rule-set doc sync.** Diff modifies check/validator/rule file → grep guides for
count-enumerations; add sync step.

**Tool/producer swap.** Tool swap → probe replacement defaults match prior
behavior; identify gap-closing flags. Lookup→scan switch → audit upstream
producer; add filter step.

---

## Step 4: Validate the Plan

Checklist before presenting:

- **Requirement coverage:** every clarified requirement → ≥1 step; every persona
  concern → addressed or excluded.
- **Agent-readiness:** every `[AGENT-READY]` has concrete instructions; every
  `[HUMAN-IN-LOOP]` names the decision.
- **Parallelism:** no unjustified sequential ordering; parallel budget = max
  phase width.
- **Commit map:** every phase boundary has a commit.
- **Mandatory elements:** all 10 present. Arch artifact → element 9 present.
  Ticket → Jira lifecycle steps present.
- **Probe coverage:** Jira pre-flight, user artifacts, prefactor, duplication,
  rule-set sync, tool/producer swap, secret-ownership — each ran when applicable.
- **Self-generated findings:** fold immediately as mandatory corrections;
  re-present only when scope/phasing/PR count changes.

Flag every failure inline (`⚠️ MISSING: …`). Resolve all before Step 5.

---

## Step 5: Present and Wait for Approval

> "Plan for: <title>. <N> phases, <M> steps, <P> parallelizable. ~<C> commits.
> Key risks: <1-2>. Open questions/exclusions: <list>."

Then show the full plan block.

**HARD RULE: Do not execute until user approves.** Silence is not approval. Auto
mode + unambiguous imperative in original prompt = approval — present and proceed
same turn.

After approval → hand off to `wk-workflow`. The approved plan replaces Phase 1.

---

## Integration with wk-workflow

`wk-workflow` Phase 1 invokes: `Skill(wk-plan, args="<task>")`. Approved plan
exists → skip own planning. Direct invocation → standalone plan.

---

## Requirements

- `AskUserQuestion` (Step 0 grill)
- `Agent` (Step 1 parallel research)
- `Skill` (`wk-jira` Stage 0 when ticket exists)
- Read/Grep/Glob/Bash for codebase research

---
