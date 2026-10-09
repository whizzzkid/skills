---
name: wk-workflow
description: >-
  Master workflow for development tasks. Activates whenever the agent begins
  planning, implementing, or executing any coding task — feature work, bug
  fixes, refactors, or infrastructure changes. Prescribes incremental commits,
  testing strategy, adversarial code review, PR lifecycle, documentation, and
  mandatory session retro. Supersedes and extends the global CLAUDE.md workflow.
model-invocable: true
user-invocable: false
model: opus
effort: medium
license: MIT
group: workflows
metadata:
  author: whizzzkid
  version: "2026.10.09-184159"
  model:
    openai: gpt-5.6-sol
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Workflow

Phases run ascending; the review gate is Phase 5.5 (after publishing; no Phase 4).

## Mandatory Activation

Fire on EVERY task producing code changes, a commit, a push, a PR, or a CI build: no opt-out, no "too small" exemption.
Session resumption → re-invoke before any write action. A planning discussion is NOT a substitute — invoke before the
first Edit/Write/Bash.

**HARD RULE — live learning capture.** Invoke [`wk-learn`](../learn/README.md) immediately on user correction, scope
redirect, or self-caught error — before continuing or ending the response. Invoke after every skill run; never ask or
offer. Phase 8 retro only verifies live capture.

### Autonomy Rules

Execute without asking permission at each step. Take the first that matches:

1. Plan ambiguous / CI persists after 3 attempts / user-owned design / explicit pause / destructive action → stop and
   ask.
2. Skill-owned event (commit, PR, docs, merge, retro) → invoke the skill — never raw `git commit`/`gh pr merge`/ad-hoc
   planning.
3. CI fails or review blocks → fix loop automatically, up to 3 attempts.
4. Terminal directive phrased as question ("merge?", "push?") → query state and act now; never wait/poll.
5. Defect diagnosed, owning file identified → edit that file now; never re-state tradeoffs.
6. Feedback lands mid-action → finish the authorized action, then adjust.

- A mandated PR lifecycle authorizes push + PR creation; ask only where publishing is genuinely optional.
- **Interpret execution bans broadly:** "don't run {tool}" covers all heavy local ops — prefer changed-file-only
  validation.
- **Never ask for what your inputs answer** — search plan, merged PRs, tracked config first. **Linked artifact first:**
  prompt references a URL/PR → fetch before parallel research.
- **Curiosity ≠ commission:** clarifying question after goal met → answer and stop; no new proposal unless asked.
- **A turn with no new facts must end in a write** — analysis done, edit the owning file. **Verify mechanism before
  offering options** — read Y's interface before claiming "accomplish X via Y".
- **Announce-and-invoke same turn:** a skill counts only when its `Skill` call is in that response. Skill presence and
  phase routing: [`references/skill-reference.md`](references/skill-reference.md).

**HARD RULE — needs shell? then no worktree isolation.** `isolation: "worktree"` blocks Bash, Grep, Glob —
Read/Edit/Write only, with no runtime error. Decide at dispatch: tests, lint, build, commit, push, PR → never
`isolation: "worktree"`. Shell unavoidable → skip isolation, or coordinator runs shell ops on worktree paths after
agents finish.

**Continuity:** treat the Phase 1 plan as the session contract: enumerate every deliverable before acting. On
interruption: update plan, re-state top item, resume earliest incomplete. Final gate: re-read plan; every step finished
or explicitly deferred.

## Phase 1: Plan

**HARD RULE:** invoke `wk-plan` before any planning:

```
Skill(wk-plan, args="<task from session context>")
```

- Plan supplied → validate only (references resolve, order valid), then Phase 2. Optional sibling-repo work is opt-in —
  confirm before touching another repo.
- Complex task → consult `advisor` server tool: [`references/advisor-tool.md`](references/advisor-tool.md).

**HARD RULE — wait for plan approval before first Edit/Write/Bash write-action (incl. fetching/reading *for* a build).**
No size exemption — "too small"/"obviously right" both violate. Present → approve → execute; user-supplied plan arrives
approved.

## Phase 2: Implement

**HARD RULE — branch pre-flight before first edit.** Run `git rev-parse --abbrev-ref HEAD` — verify branch matches
intended base before any Edit/Write. Linked worktree → resolve paths under `git rev-parse --show-toplevel`.
Rebase/cherry-pick conflicts → `git log --oneline -5`; base mismatches worktree parent → stop, never force through.

- **Pre-patch routing:** `.md` → [`wk-markdown`](../markdown/README.md); Mermaid → [`wk-mermaid`](../mermaid/README.md);
  arch-bearing → [`wk-arch-review`](../arch-review/README.md) detector, then draft-complete gate.
- **Subtractive-first:** evaluate if removal/simplification eliminates the problem before adding code. Fleet-first for
  shared integrations: grep 2-3 sibling repos before fixing shared code.
- Execute step by step. After each: (1) run tests, (2) `wk-workstyle`, (3) `wk-docs` for affected docs, (4) `wk-commit`.
  Never batch steps, defer docs, or skip tests between commits. Print before/after SHAs on branch-rewriting ops.
- **Cross-cutting changes** (normalization, renames, schema): grep all sites → implement all → commit → adversarial
  review once → ≤1 follow-up commit.
- **Artifact sync:** structural change → [sync artifacts](references/doc-sync-mechanics.md) same commit. External
  failure → [reproduce before fixing](references/external-call-reproduction.md).

Edit-scope pre-flights — enumerate every affected site (callers, `replace_all` occurrences, brief identifiers, guards,
harness reachability, contract owners, false-positive class); fix all in one pass before tests:
[`references/edit-scope-preflights.md`](references/edit-scope-preflights.md).

Code standards:

- **Version pins:** exact only — no `latest`/`^`/`~`. Official-action semver majors permitted.
- **Regexes:** named capture groups: `(?<year>\d{4})`.
- **Bash:** absolute paths, no `cd`. Extended:
  [`references/code-standards-extended.md`](references/code-standards-extended.md). **Shell:** sequential single-purpose
  commands. Surface denials; never silently restructure.
- **CLI flags:** [`references/verify-cli-flags.md`](references/verify-cli-flags.md). **Platform-API traps:**
  [`references/platform-api-traps.md`](references/platform-api-traps.md).
- **Layer responsibility:** side effects in entrypoint layers only. **Two-sided flow survey:** survey caller + callee
  before designing gates. **Identifier composition:** classify sources by semantic domain before combining into keys.
- **HARD RULE — reuse existing config/secret resolution; never invent parallel overrides.** User names an existing
  convention → adopt it. ([`reuse-existing-mechanism.md`](references/reuse-existing-mechanism.md))

## Phase 3: Test

**HARD RULE — select execution environment before validation.** Before first build/lint/test, inspect container,
devcontainer, runner, repo instructions. Use documented runnable container; if none, say so before host fallback.
Explicit validation waiver short-circuits provisioning — never build an env for a removed gate; name what stays
unverified. Mixed toolchains: [announce subsystem ownership](references/environment-guardrails.md).

Cover required paths: **happy** (expected flow), **sad** (failures, invalid input, error handling), **edge**
(boundaries, nulls, concurrency, off-by-one). Verify:

- All tests pass; each commit passes independently. **Local lint before every push** — inspect hook config for every
  pre-push gate. Re-run every gate against final HEAD, not a mid-session snapshot.
- Validate transformations with formerly-failing input. **Fix-symptom match:** verify fix targets exact reported
  symptom.
- **A fast/narrow check is never the authoritative gate** — run the full gate. **Dependent verification fails fast** —
  run expected-red and green gate separately; `set -euo pipefail` if sharing one shell.
- **Never take a verdict from `$?` after a pipe** — see `wk-workstyle-shell`.
- User-loadable artifact: [`build last`](references/2026-08-04_final-development-build.md). Generated artifacts:
  [`acceptance`](references/2026-08-01_generated-artifact-acceptance.md). Data-only change → compare published set
  membership/count before and after.
- Shell-script tests: [`references/shell-script-test-checks.md`](references/shell-script-test-checks.md).

## Phase 3.5: Refactor & Deletion-Safety Scan

Scan every new/modified function for: existing helpers, repeated literals, near-duplicates (≥3 lines), nested
conditionals, re-implemented patterns. Post-correction → re-diff full change set; revert hunks whose justification no
longer holds. Classify: **Apply now** (reuse helper, lift duplicate, flatten conditional — one commit), **Defer** (TODO
in PR "Follow-ups"), **Skip** (no real win). Re-run tests after Apply-now.

Deletion-safety: classify every removed line/symbol/file intentional or accidental; unexplained removal = blocker.
Removed symbol with live callers, guard/validation/test without replacement, or file still imported (or whose
responsibility did not move) → accidental → restore or migrate. Split unrelated cleanup into its own commit. Detail:
[`references/deletion-safety-scan.md`](references/deletion-safety-scan.md).

## Phase 3.6: Frontend Live Preview

Run only when diff changes browser-rendered UI (`.tsx/.jsx/.vue/.svelte/.html/.css/.scss`); backend/config/docs-only →
"frontend preview: N/A". Launch via `run` skill or dev-server. Drive every changed view with Playwright; capture
snapshots/console; platform-pinned baselines → regenerate in CI container, never local host
([artifacts](references/2026-08-04_linux-visual-artifacts.md)). Load failure, console error, or broken interaction →
blocker. Leave app running; continue Phase 5.

## Phase 5: PR

**HARD RULE — "push succeeded" is NOT "work complete".** After push, run `gh pr view 2>/dev/null`; no open PR → invoke
`wk-pr` immediately.

- **Repo convention:** treat the current task branch as authoritative. Branch from default only on detached HEAD,
  unrelated dirty work, or explicit request. Resolve default branch dynamically. Branch when evidence points to PR-gated
  workflow; otherwise commit to default. Follow-up branch → from `origin/<default>` (fetch first).
- Invoke `wk-pr` (never raw `gh pr create`) after tests and Phase 3.5/3.6 pass. Each stacked PR independently completes
  Phases 5→6.5.
- **Post-push sync:** `wk-commit` handles PR description sync and stale comment resolution. **HARD RULE:** auto-sync
  drifted artifacts — never ask. After push, code change, or pivot: audit PR title/body, self-review, ticket, docs;
  update same turn. On pivot, resolve stale self-review threads and re-post via `wk-self-review`. Confirm only when
  genuinely ambiguous.
- Before reworking a PR branch, [reconcile against actual base](references/pre-rework-base-reconcile.md).

## Phase 5.5: Adversarial Review

Invoke `wk-adversarial-review` with PR published and ready. **This is the workflow's only dispatch point.**

**HARD RULE — review gates merge, not publish.** Push/PR/readying need no verdict. Merge and `gh pr merge --auto`
require clear review lineage (SHA equality not required). No size or docs-only exemption.

Act on the verdict: **clear** → re-stage via `wk-self-review` if fix commits landed, then Phase 6; **blocked** → fix via
`wk-commit`, re-invoke until clear, never merge on blocked; **suggestions-only** → follow the skill's A/B/C prompt.

**HARD RULE — never defer a security guard.** Missing guard/input validation (SSRF, injection, path traversal) →
blocker-class, apply now; never propose deferring without explicit user instruction. Split a tooling swap into a
follow-up, never the guard.

## Phase 6: CI Fix Loop

Monitor and fix CI until green, concurrently with Phase 5.5.

- Do not re-run a green pre-push gate locally after pushing same SHA. `gh pr checks --watch --fail-fast` for generic;
  `wk-buildkite` for Buildkite.
- Long watches → background. **Complete CI watches same turn** — never hand off. **Interleave** independent tasks while
  polling.
- Diagnosis: [`references/ci-diagnosis-table.md`](references/ci-diagnosis-table.md). Fix ordering:
  [`references/ci-fix-candidate-ordering.md`](references/ci-fix-candidate-ordering.md).
- Fix loop: (1) targeted fix, (2) run failing gate locally, (3) `wk-commit`, (4) push, (5) update PR, (6) re-enter. Max
  3 attempts per run; each must differ; before attempt 3, state the axis being varied. After 3, hand off.

**HARD RULE:** verify every test-plan checkbox before updating the PR description and before merge/auto-merge. Run every
runnable verification; leave a box unchecked only when impossible, noting why.

## Phase 6.5: Review-Comment Resolution

Poll unresolved threads → invoke `wk-pr-resolve` while any remain → re-poll after every pass and push (bots re-review
per push) → re-enter Phase 6 if CI turns red → exit on zero unresolved + green CI. Spans sessions. Never run Phase 8
retro while a post-push pass has unaddressed threads.

## Phase 7: Documentation Audit

Invoke `wk-docs`. Verify README, ADRs, specs, `docs/README.md`. No `docs/` → `wk-docs` bootstraps.

## Phase 8: Session Retro — NON-NEGOTIABLE

**HARD RULE:** invoke `wk-retro` at end of every session, no exceptions. `gh pr ready` is not a terminus — the next
action after it is `Skill(wk-retro)`.

## Checklist

Environment guardrails: [`references/environment-guardrails.md`](references/environment-guardrails.md). Skill reference:
[`references/skill-reference.md`](references/skill-reference.md). Final gate before claiming complete — confirm each:

- [ ] Atomic commits, each passes tests/CI independently; `wk-workstyle` + docs updated alongside code
- [ ] Tests cover happy/sad/edge paths; `wk-adversarial-review` clear before merge; CI green on current HEAD
- [ ] PR description current; all review threads resolved; version pins exact; scripts have correct permissions
- [ ] Diagrams use Mermaid; regexes use named captures; ADRs for arch decisions
- [ ] Session retro via `wk-retro`; every plan step finished or deferred

## Post-Completion

Invoke `wk-learn workflow`.
