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
  version: "2026.10.09-184159"
  model:
    openai: gpt-5.6-sol
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# Plan

Produce an explicit numbered plan with agent-assignment markers, minimized dependencies, and parallel phases by
default, before any code is written. Invoked directly (standalone plan) or by `wk-workflow` Phase 1.

## Step 0: Grill — Detect and resolve ambiguities

**HARD RULE:** Never plan a vague task. Stop and clarify before research begins.

Treat each signal as a blocker: 1) no acceptance criteria ("improve the API"); 2) scope boundary missing ("refactor
the auth flow"); 3) conflicting requirements with no priority; 4) undefined inputs (no ticket or repro); 5) vague
degree ("make it better"); 6) missing "what must NOT change" on shared code; 7) ≥2 distinct deliverables bundled —
confirm granularity; 8) fix approach undetermined (add/produce vs disable/suppress).

**HARD RULE — one question per message.** Ask a single question, wait, ask the next. Never a batched/numbered list.
Proceed to Step 1 only when every blocker resolves.

- **Already-done pre-check:** re-fired/looped prompt → before grilling, check open/merged PR, ticket status, artifact
  present. Complete → report and stop.
- **Multi-deliverable granularity:** ≥2 standalone deliverables → numbered list, ask "one PR or separate?" first.
- **Is-a-fix-warranted gate:** benign root cause → surface "no fix needed / close as working-as-intended" as
  `[HUMAN-IN-LOOP]`; revert already landed → plan re-land (cherry-pick / revert-the-revert), not re-implementation;
  perception-based symptom → surface the UI-affordance gap as the real follow-up.
- **Fix-philosophy branch:** multiple valid fixes splitting "add/produce" vs "disable/suppress" → `[HUMAN-IN-LOOP]`.
  Consumer-only service must never produce — confirm role before drafting.

## Step 1: Research — Parallel context gathering

1. **Jira pre-flight:** ticket found → invoke `wk-jira` Stage 0+1+2; put acceptance criteria in the plan before
   exploration.
2. **User artifacts first:** concrete references (URLs, PRs, paths, errors, build IDs, stack frames) → fetch directly
   before spawning agents. GitHub comment URLs → `gh api repos/{owner}/{repo}/{pulls|issues}/comments/{id}`. MCP tools
   available → prefer over building a client.
3. **Parallel agents:** only when artifacts are exhausted and gaps remain, dispatch parallel `Agent` calls: A —
   codebase topology (files, modules, entry points, blast radius); B — spec/ticket context (Jira ACs, specs/ADRs, open
   PRs on same files); C — test coverage/history (existing tests, tested vs untested behaviors); D — prior art
   (closest implementation, shared helpers/lib modules).

Contradictions between agents → probe further, not guess. User tags a file by path AND describes its role → read
it and compare purpose to description; mismatch + better sibling → surface before drafting.

## Step 2: Multi-Persona Validation

Ask "What must this plan include to be acceptable?" as Implementor/Reviewer, Security/Ops, and Product, using the
question set in [persona checklist](references/persona-checklist.md). Per concern: missing step → add; scope
conflict → re-clarify (Step 0); out of scope → record in Exclusions with one-line rationale.

## Step 2.5: Simplest-Viable Scope Gate

**HARD RULE:** Plan the **simplest approach satisfying the stated requirement** — never more capable, general, or
defensive than asked.

List every approach the plan introduces that the user did not name: **unrequested mechanism** (auth scheme,
transport, caching, retry chain the task didn't mention); **unrequested generality** (parameterized where concrete was
asked; Rule of Three); **unrequested hardening/breadth** (guards for out-of-scope inputs; systems outside target).
Surviving → one-line rationale; otherwise drop; uncertain → `[HUMAN-IN-LOOP]` with simplest alternative.

- **Secret-ownership probe:** separate consumption from provisioning. Manual → operational prerequisite. Unknown →
  `[HUMAN-IN-LOOP]`.
- **Search-scope boundary:** stay inside project root. Never `find /` or `grep -r /`.

## Step 3: Draft the Plan

Run the probes below, then synthesize into a fenced plan block: task title, scope boundary, measurable done
criteria, parallel budget, exclusions, numbered phases.

- **Markers:** every step carries exactly one: `[AGENT-READY]` (autonomous), `[AGENT-GUIDED]` (execute + report
  back), `[HUMAN-IN-LOOP]` (user decision required).
- **Parallelism:** default to parallel; declare sequential dependencies explicitly (`depends on Phase <X>`). Never
  serialize for tidiness. Max 5 phase depth — collapse or run earlier.
- **Commits:** smallest possible — each does one logical thing, passes CI, includes doc updates.
- **Prefactor probe:** new caller of existing pattern → grep the operation, identify duplicated prologue/epilogue,
  lift into helper, migrate existing caller (separate commit), extend.
- **Duplication probe:** adding to a large mixed-content file (>200 lines) → grep it for the function/event/feature
  name first; match → remove/replace/merge, never add alongside. New spec → grep open PRs; found → stack and
  extend. New skill → ask if it's a new verb on an existing skill's noun; yes → add routing mode.
- **Rule-set doc sync:** diff modifies check/validator/rule file → grep guides for count-enumerations; add sync step.
- **Tool/producer swap:** tool swap → probe replacement defaults match prior behavior; identify gap-closing flags.
  Lookup→scan switch → audit upstream producer; add filter step.

Mandatory plan elements: 1) implementation steps covering full scope; 2) commit boundary after each unit;
3) `wk-docs` for every changed behavior; 4) testing: happy/sad/edge; 5) `wk-adversarial-review` — once, at completion
gate after PR published; 6) PR offer step; 7) CI fix loop (up to 3 rounds); 8) `wk-retro`; 9) `wk-arch-review` at
draft-complete when plan authors/modifies arch-bearing artifacts (spec, ADR, RFC, design doc) — run mechanical
detector; hit makes it mandatory, doc-only included; 10) Jira lifecycle steps (only when ticket in scope) as named
numbered steps, not invisible side-effects, marked `[AGENT-READY]` with auto-mode caveat.

## Step 4: Validate the Plan

Check before presenting; flag every failure inline (`⚠️ MISSING: …`) and resolve all before Step 5:

- Every clarified requirement → ≥1 step; every persona concern → addressed or excluded.
- Every `[AGENT-READY]` has concrete instructions; every `[HUMAN-IN-LOOP]` names the decision.
- No unjustified sequential ordering; parallel budget = max phase width; every phase boundary has a commit.
- All 10 mandatory elements present. Arch artifact → element 9 present. Ticket → Jira lifecycle steps present.
- Jira pre-flight, user artifacts, prefactor, duplication, rule-set sync, tool/producer swap, secret-ownership probes
  each ran when applicable. Self-generated findings: fold immediately as mandatory corrections; re-present only when
  scope/phasing/PR count changes.

## Step 5: Present and Wait for Approval

Post this summary, then the full plan block:
> "Plan for: <title>. <N> phases, <M> steps, <P> parallelizable. ~<C> commits.
> Key risks: <1-2>. Open questions/exclusions: <list>."

**HARD RULE: Do not execute until user approves.** Silence is not approval. Auto mode + unambiguous imperative in
original prompt = approval — present and proceed same turn.

After approval → hand off to `wk-workflow` (`Skill(wk-plan, args="<task>")` from its Phase 1); the approved plan
replaces Phase 1 and `wk-workflow` skips its own planning.

## Post-Completion

Invoke `wk-learn plan`.
