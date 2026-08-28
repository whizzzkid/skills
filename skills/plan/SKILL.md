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
  version: "2026.08.28-030254"
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

- Invoked at the start of every non-trivial task — directly (`/wk-plan <task>`) or by `wk-workflow` Phase 1.
- Output: explicit numbered plan; every item carries an agent-assignment marker; temporal dependencies minimized; parallel phases are the default.

---

## Step 0: Grill — Detect and resolve ambiguities

**HARD RULE:** Never plan a vague task. Stop here and clarify before research or planning begins.

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
| Fix approach undetermined | symptom fixable by "add/produce/provision" OR "disable/suppress" | Yes |

- When ≥1 signal fires → ask only the questions needed to unblock, via `AskUserQuestion` (not prose).
- **HARD RULE — one question per message.** Ask a single question, wait for the answer, then ask the next; track answers as you go. Never present a batched/numbered list, even with recommended defaults — a wall of simultaneous questions is overwhelming. Generalizes the wk-pr-resolve one-comment-at-a-time rule to every grill/clarify/decision flow.
- Proceed to Step 1 only when every blocker is resolved.

**Multi-deliverable granularity.** When the prompt lists ≥2 deliverables that could each stand alone (own ticket, commit, or PR) → surface them as a numbered list and ask "one PR or separate?" **before** planning. A bundle of N tasks reads as a clear requirement but hides a granularity decision only the user owns; a single deliverable with sub-tasks does not trigger this.

**Is-a-fix-warranted gate.** When the investigated root cause is benign (correct behavior, external timing, no defect) → surface "no fix needed / close as working-as-intended" as an explicit `[HUMAN-IN-LOOP]` option alongside any fix options, and confirm the user wants a change before planning one. "Do nothing" is a legitimate — often the correct — outcome; do not default to scoping a fix just because a ticket exists.

- When a revert already landed on a premise the gate dissolves → plan re-land of original commit (cherry-pick / revert-the-revert), not a cross-repo re-implementation of the same design.
- When the symptom is perception-based (slow load, missing skeleton loaders, stale cache) → surface the UI-affordance gap as the real follow-up; the data path is not defective.

**Fix-philosophy branch.** When a symptom has multiple valid fixes that split into "add/produce/provision" vs "disable/suppress" branches → surface the branch choice as a `[HUMAN-IN-LOOP]` decision before implementing. The obvious make-it-work fix (provision the missing resource, produce the missing record) may violate the component's role — a consumer-only service must never produce or create. Confirm which branch is legal for the app's role before drafting; do not optimize for "make the feature work" when a role constraint is discoverable.

**Already-done pre-check.** Before grilling, when the prompt may describe work already underway or complete (a re-fired/looped prompt, "continue X", a resumed session) → verify current state first: open/merged PR on the branch, ticket status (Done?), the described artifact already present. Already complete → report completion and stop; never re-execute finished work. A stale re-fired prompt is indistinguishable from a fresh one at the text level, so the check is explicit, not intuited.

Structure each question with a concrete `header` label. Good question forms:

- **Definition of done:** "The task is complete when ___?"
- **Scope boundary:** "Which components / files / systems are in scope?"
- **What must not change:** "Are there behaviors that must be preserved exactly?"
- **Priority tiebreaker:** "If speed and correctness conflict, which wins?"
- **Risk tolerance:** "Is a partial rollout (flag/canary) acceptable, or must it ship atomically?"

---

## Step 1: Research — Parallel context gathering

### Gate 1: Jira ticket pre-flight

Before any exploration (`Read`, `Grep`, `Agent` dispatch) → check whether a Jira ticket exists for the work.

- Treat a Jira URL or key in the user's prompt as a confirmed ticket.
- When a ticket exists → invoke `wk-jira` Stage 0+1+2 before drafting the plan.
- Put ticket acceptance criteria and linked specs in the plan before exploration starts.
- Ask the user once if the ticket status is unknown.
- Do not surface the ticket after exploration is underway.

### Gate 2: Investigate user-provided artifacts first

Before spawning exploration `Agent` calls → scan the user's most recent message for concrete references: URLs, PR numbers, file paths, error messages with line/column, build IDs, stack frames.

When a concrete artifact is present:

- Fetch or read it directly first (`gh pr diff`, `Read`, `gh run view`, `bk build view`, etc.).
- For GitHub comment or review URLs → fetch the comment body before any codebase grep:

  ```bash
  gh api repos/{owner}/{repo}/{pulls|issues}/comments/{id}
  ```

- Before writing any HTTP client, SDK wrapper, or API integration for a third-party service → survey available MCP tools for that service name.
- Prefer the MCP when the use case is interactive and the call must run inside a Claude session.
- Build a client only when the call must run outside a Claude session → document that reason in the plan.
- Spawn parallel exploration agents only when no concrete artifact exists, or the artifact is exhausted and gaps remain.
- Treat parallel `Agent` dispatch as a higher-cost fallback, not the default.

Dispatch parallel `Agent` calls to build the context map after the gates above clear. Select the relevant agents for the task type (not all are needed every time).

```
// Agent roles — dispatch the subset that applies:
Agent A — Codebase topology: files, modules, entry points, key symbols, blast radius.
Agent B — Spec and ticket context: Jira ACs (wk-jira Stage 0), specs/ADRs, open PRs on same files.
Agent C — Test coverage and history: existing tests, last 10 commits, tested vs untested behaviors.
Agent D — Prior art and patterns: closest existing implementation, shared helpers/lib modules.
```

Collect all agent results before Step 2. Contradictions between agents → probe further, not guess.

### File-role sanity check

When the user tags a file by path **and** describes its role in prose → read the tagged file's actual purpose and compare it to the description before accepting it as a plan target.

- If the file's content contradicts the described role and a sibling in the same directory is a better match → surface the mismatch before drafting: "The file you tagged does X — you described one that does Y; did you mean `{better-match}`?"
- Accepting a mis-tagged file at face value plans changes to the wrong file and wastes the run.

---

## Step 2: Multi-Persona Validation

Think simultaneously from multiple perspectives to surface concerns the research phase may not have raised. Select the 3–5 personas relevant to the task.

For each persona, answer: **"What does this plan need to include from my perspective to be acceptable?"**

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
- Does any proposed query or operation on a request path violate a documented performance constraint (no live aggregates, no N+1, read-replica-only, query-budget cap)? If such a constraint exists, the plan must use the same mitigation pattern the existing code uses (cache, background job, materialized view) — never acknowledge the constraint as a risk while proposing a step that violates it.

**Product / User**
- Does the plan deliver the stated requirement, or a technically-correct implementation of a different thing?
- Are there user-visible gaps between what is planned and what was asked?

**For each concern raised by a persona:**
- Missing step → add it to the plan (Step 3).
- Scope conflict → go back to Step 0 and re-clarify.
- Explicitly out of scope → record as an exclusion with a one-line rationale in the plan's Exclusions section.

---

## Step 2.5: Simplest-Viable Scope Gate

**HARD RULE:** The plan implements the **simplest approach that satisfies the stated requirement** — never a more capable, more general, or more defensive one the user did not ask for. This gate is the single biggest source of mid-task corrections ("did I ask you to implement that? why are you overcomplicating this?") — catch it in the plan, not at review.

Before drafting, list every approach the plan would introduce that the user did **not** name, and justify or drop each:

- **Unrequested mechanism** — an auth scheme, transport, caching layer, retry/fallback chain, or config surface the task did not mention (`netrc`, a temp-file credential dance, a generic wrapper). If the task is "fetch X" and X has a one-line call → plan the one-line call.
- **Unrequested generality** — a parameterized/abstracted solution where a concrete one was asked for. Apply the Rule of Three: do not generalize on the first instance.
- **Unrequested hardening** — defensive guards, validation, or error recovery for inputs the task does not put in scope.
- **Unrequested breadth** — touching files, modules, or systems outside the named target.

Surviving item → add a one-line rationale to the plan. Otherwise → drop it. **When an unrequested approach seems necessary but you are not certain the user wants it → surface it as a `[HUMAN-IN-LOOP]` decision with the simplest alternative stated — do not silently bake it into the plan.**

### Secret-ownership probe

When a runtime secret is required, separate secret consumption from secret
provisioning before defining workstreams:

- Identify the owner and provisioning mode for every secret: repository
  automation, external platform, or manual operator action.
- Manual population selected → document it as an operational prerequisite;
  do not invent infrastructure or cross-repository work.
- Ownership or mode unknown → add a `[HUMAN-IN-LOOP]` decision before assigning
  implementation work.

### Search-scope boundary

The plan's research and implementation steps stay **inside the project root**. Never plan a filesystem-root search (`find /`, `grep -r /`) or reads outside the repo / bundle path — grep within the project, or the tool-managed dependency path (`bundle show`, `mise where`). A step that reaches outside the repo is a scope-gate violation unless the task explicitly requires it.

---

## Step 3: Draft the Plan

Synthesize Step 1 (research) and Step 2 (persona concerns) into a plan document with the following format. Write as a fenced block for easy copy/paste into a TodoWrite list or a PLAN.md artifact.

### Plan format

Write the plan as a fenced block with: task title, scope boundary, measurable done criteria, parallel budget, exclusions, then numbered phases. Each step carries a marker (`AGENT-READY`, `AGENT-GUIDED`, or `HUMAN-IN-LOOP`), a goal, artifacts out, numbered imperatives, and a commit message.

### Step markers

Every step must carry exactly one marker:

| Marker | Meaning |
|---|---|
| `[AGENT-READY]` | Agent completes autonomously |
| `[AGENT-GUIDED]` | Agent executes, then reports back |
| `[HUMAN-IN-LOOP]` | User decision required |

### Parallelism rules

- **Default to parallel phases.** Steps without shared write targets or data dependencies run concurrently.
- **Declare sequential dependencies explicitly.** Write `SEQUENTIAL — depends on Phase <letter>` when ordering is load-bearing.
- **Never serialize for tidiness.** Sequential ordering must be justified by a data or file dependency.
- **Maximum phase depth.** If the plan has more than 5 phases, look for steps that can be collapsed or run earlier.

### Mandatory plan elements

Every plan must contain these elements before it is valid:

1. Implementation steps covering the full scope
2. Commit boundary after each meaningful unit
3. Documentation update step (`wk-docs`) for every changed behavior
4. Testing step: happy path, sad path, edge cases
5. Adversarial review step (`wk-adversarial-review`) — exactly one, at the
   completion gate after the PR is published and ready; never per push
6. PR offer step
7. CI fix loop step (monitor + auto-diagnose up to 3 rounds)
8. Session retro step (`wk-retro`)
9. Architecture review step (`wk-arch-review`) — **whenever the plan authors or
   modifies an arch-bearing artifact** (spec, ADR, RFC, design doc, HLD/LLD,
   tech-spec, implementation plan, delivery estimate) or changes system topology,
   per that skill's contract. This skill is the owner on the authoring path: the
   review runs once at draft-complete, **before the plan is presented for
   approval** — not deferred to the PR gate, where the design is already built.
   Run its mechanical detector over the artifacts the plan will write; a hit makes
   the step mandatory, doc-only work included.
10. Jira lifecycle steps — **only when a ticket key is in scope** (see below)

### Jira lifecycle as explicit plan steps

When a Jira key is in scope (Gate 1), surface its lifecycle transitions as
**named numbered steps**, not invisible `wk-jira` side-effects. A transition
handled only as an ambient side-effect is prone to being skipped or blocked
without the user noticing.

- Add a step group: `(Jira) claim ticket → In Progress`, `(Jira) post PR-opened
  comment`, `(Jira) transition → In Review on gh pr ready`, `(Jira) → Done on
  merge`.
- Mark each `[AGENT-READY]` with the caveat: "auto mode may block this Jira write
  (treated as an external-system write) — if denied, re-invoke `wk-jira` or add a
  permission rule; do not silently retry."

### Commit granularity

Smallest possible commits — each does one logical thing, passes CI in isolation, includes doc updates for changed behavior, and is committable via `wk-commit`. Too large → split into sub-steps.

### Prefactor probe — lift before extending

Before writing a new caller of an existing pattern → **lift → migrate → extend**.

Triggers: "another/similar to/like the <X>", new feature duplicates an existing verb, new caller in a different file.

1. Grep the operation across codebase; read both call sites.
2. Identify duplicated prologue/epilogue (validation, error handling, logging, retries).
3. Lift into a helper in the `lib/`-equivalent location.
4. Migrate existing caller onto helper (separate commit).
5. Extend — new caller as thin wrapper delegating to helper.

List these as numbered steps before the new-feature step. No existing caller → no-op.

### Intra-file duplication probe

Before adding any new block to a large mixed-content file (>200 lines, especially `.erb`, `.html`, `.vue`, `.svelte`, or any template that interleaves multiple languages) → grep the file itself for the function name, event name, selector, or feature keyword first.

```bash
grep -nE '<feature-keyword>|<function-name>|<event-name>' "$FILE"
```

If a match exists → decide in the same commit whether to remove the prior version, replace it, or merge — never add alongside.

### Spec pre-flight — extend an in-flight spec before creating a new one

Before producing a new spec/design doc → grep open PRs for related specs. Related spec in an open PR → stack and extend it. Create standalone only when none exists.

### New-capability probe — extend an existing skill before scaffolding a new one

Before scaffolding a new skill → ask whether it is a new verb on a noun an existing skill owns. Subcommand/mode of existing → add routing mode. Standalone only for genuinely distinct workflows (different argument shape, tool set, or mental model).

### Rule-set doc sync probe

Diff modifies a check/validator/rule file → grep guides (README, `docs/how-to`) for count-enumerations (`"N things"`, numbered lists). Add each as a sync step so count and body stay aligned.

### Tool-swap flag-parity probe

Plan swaps one tool for another in same role → probe whether replacement's defaults match the prior tool's behavior. Identify gap-closing flags in the plan, not at review time. Pay attention to CWD-sensitive/module-aware tools.

### Producer-audit probe

Plan switches from named-file lookup to directory scan/glob → audit the upstream producer. Grep the build/compile script; add a filter step that includes/excludes each file type.

---

## Step 4: Validate the Plan

Before presenting, run a validation checklist against the draft plan.

**Requirement coverage**
- Every clarified requirement (Step 0) maps to ≥1 step.
- Every persona concern (Step 2) is addressed by a step or explicitly excluded with a rationale.

**Agent-readiness**
- Every `[AGENT-READY]` step has concrete instructions (not "investigate and fix") — an agent can execute it without asking a clarifying question.
- Every `[HUMAN-IN-LOOP]` step names the specific decision the user must make.

**Parallelism**
- No sequential ordering exists that is not justified by a dependency.
- The parallel budget number in the header equals the maximum width of any parallel phase.

**Commit map**
- Every phase or step boundary has a commit. No phase ends without one.

**Self-generated review findings**
- When `wk-arch-review` (or any self-dispatched validation step) produces findings → fold them into the plan immediately as mandatory corrections; do not ask the user whether to apply the plan's own review output.
- Re-present the updated plan only when findings alter scope, phasing, or PR count; otherwise apply silently and proceed to Step 5.

**Mandatory elements**
- All 8 mandatory elements from Step 3 are present and numbered.
- Arch-bearing artifact in scope → element 9 (`wk-arch-review` at draft-complete) is
  present; its absence on a spec/estimate plan is a validation failure, not a choice.
- Ticket in scope → Jira lifecycle steps (element 10) are present, named, and carry the auto-mode caveat.

**Probe coverage**
- Jira ticket pre-flight cleared or asked once.
- User-provided artifacts were read before agent dispatch.
- Prefactor probe ran when an existing pattern is reused.
- Intra-file duplication probe ran for large mixed-content files.
- Spec pre-flight ran before creating a new spec/design doc.
- New-capability probe ran before scaffolding a new skill or entry point.
- Rule-set doc sync probe ran when rule files change.
- Tool-swap flag-parity probe ran when tools are swapped.
- Producer-audit probe ran when named-file lookup becomes directory scan.
- Secret-ownership probe ran when runtime secrets are required; each secret has
  an explicit owner and provisioning mode.

Flag every validation failure inline in the draft (`⚠️ MISSING: …`). Resolve all flags before Step 5.

---

## Step 5: Present and Wait for Approval

Present the plan with a one-paragraph summary:

> "Plan for: <task title>
> <N> phases, <M> steps total. <P> steps are agent-parallelizable.
> Estimated commit count: <C>.
> Key risks: <top 1-2 risks surfaced by the persona pass>.
> Open questions / exclusions: <list if any>."

Then show the full plan block from Step 3.

**HARD RULE: Do not execute any step until the user approves the plan.** The plan is a contract. Execution starts only after an explicit "yes", "proceed", "looks good", or equivalent approval signal. Silence is not approval.

**Auto mode + an unambiguous implementation directive already in the original prompt is approval.** When the user's own message contains a clear imperative ("fix this", "implement X", "make this change") and the plan executes exactly that, present the plan and proceed in the same turn — do not block on a second "proceed?". Re-asking what the original directive already authorized is the over-gating this forbids. Block only when the plan is speculative or the user's intent is genuinely unclear.

After approval → hand off to `wk-workflow` for execution. The approved plan replaces `wk-workflow` Phase 1's inline planning entirely — do not re-plan in wk-workflow if wk-plan has already produced an approved plan this session.

---

## Plan Notation Reference

```
[PARALLEL]       — phase header: all steps run concurrently
[SEQUENTIAL]     — phase header: each step waits for the previous
[AGENT-READY]    — step: agent executes autonomously
[AGENT-GUIDED]   — step: agent executes, reports back before next
[HUMAN-IN-LOOP]  — step: user decision required
⚠️ MISSING:       — validation flag: gap in plan coverage
```

---

## Integration with wk-workflow

`wk-workflow` Phase 1 invokes this skill before doing its own planning:

```
Skill(wk-plan, args="<task from session context>")
```

If wk-plan was already run this session and an approved plan exists → wk-workflow skips its own planning and executes the approved plan directly. When invoked directly (`/wk-plan`) → output is a standalone plan the user can hand to wk-workflow, a multi-agent Workflow script, or execute manually step by step.


---

## Common Mistakes

- **Planning before grilling.** A plan built on a vague requirement produces rework.
- **Overcomplicating past the ask.** Plan the simplest viable path; surface unrequested approaches as `[HUMAN-IN-LOOP]`.
- **Sequential by default.** Declare dependencies explicitly — don't let caution serialize the work.
- **Vague agent instructions.** Every `[AGENT-READY]` step must have numbered imperatives.
- **Missing exclusions.** Persona concerns that are out of scope but not recorded will resurface as reviewer comments.
- **Executing before approval.** The plan is a contract. Starting before approval means executing the wrong contract.
- **Ignoring the Jira ticket.** Acceptance criteria in the ticket override the verbal task description.
- **Not re-running wk-plan after scope change.** If the user interrupts mid-execution to add scope, re-invoke wk-plan on the new scope.
- **Acknowledging a constraint but violating it.** Noting a performance or architectural constraint in the risk section, then proposing a step that contradicts it. A documented constraint is a design input to satisfy, not a risk to note — the plan must use the same mitigation pattern the existing code uses.
- **Asking permission to apply own findings.** When `wk-arch-review` or another self-dispatched validation produces technical corrections, fold them immediately — they are mandatory, not proposals requiring user consent.

---

## Requirements

- `AskUserQuestion` tool (for Step 0 grill)
- `Agent` tool (for Step 1 parallel research)
- `Skill` tool (to invoke `wk-jira` Stage 0 when a ticket exists)
- Read/Grep/Glob/Bash for codebase research

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn plan`).
