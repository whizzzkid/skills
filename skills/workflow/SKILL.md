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
  version: "2026.08.27-182138"
  model:
    openai: gpt-5.6-sol
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Workflow

Master orchestration for development tasks. Phases run in ascending order; follow the sequence exactly. The review gate is Phase 5.5 — it follows publishing, so no Phase 4 exists.

---

## Mandatory Activation

- Fires on EVERY task producing code changes, a commit, a push, a PR, or a CI build from a code change. No opt-out, no "too small" exemption.
- Session resumption is a fresh start → before any write action after context compaction, rollover, or "continue where we left off", invoke `wk-workflow` again.
- A planning discussion in chat is NOT a substitute for this invocation — invoke the skill before the first Edit/Write/Bash; it may surface branch hygiene/guardrails/pre-flight the chat missed.
- Before first CLI/subsystem use, re-check skill triggers; invoke matches first.

### HARD RULE — live learning capture

- **Very important:** Invoke [`wk-learn`](../learn/README.md) immediately when a
  user correction, scope redirect, or self-caught error occurs — before
  continuing the task or ending that response.
- Invoke it after every skill run; never ask or offer. Phase 8 retro only verifies live capture.

### Autonomy Rules

Execute the workflow without asking permission at each step.

| Situation | Do this | Do NOT do this |
|---|---|---|
| Ready to commit | Invoke `wk-commit` | Ask “shall I commit?” |
| Tests pass | Invoke `wk-pr` | Ask “would you like a PR?” |
| CI fails | Enter fix loop automatically | Ask “should I investigate?” |
| Review blocks | Fix blockers, re-invoke `wk-adversarial-review` | Ask “should I fix these?” |
| Docs need updating | Invoke `wk-docs` | Ask “should I update docs?” |
| Merge approved | Invoke `wk-pr-merge` | Run raw `gh pr merge` |
| Session ending | Invoke `wk-retro` | Ask “should I do a retro?” |
| Terminal directive as a question (“mark ready?”, “merge?”, “push?”) | Query current state and act now | Wait/poll on CI or approvals as if conditional |
| Defect diagnosed, owning file identified | Edit that file now | Re-state the tradeoffs again |
| Feedback lands mid-action | Finish the authorized action, then adjust | Acknowledge and stop, leaving it undone |

- **Important:** a mandated PR lifecycle authorizes the initial push and PR creation. Ask only where publishing is genuinely optional.

Stop and ask only when: plan ambiguous; CI persists after 3 attempts; user-owned design decision needed; explicit pause requested; or destructive/shared-state action required.

- **Never ask for what your own inputs answer** — search the plan, merged PRs, and tracked config first (a question they already answer proves they went unread).
- **Linked artifact first.** Prompt references a URL/comment/PR → fetch before parallel research.

- **Volunteered feedback is not a stop signal** (unlike a question you asked, below): unless it revokes the action, finish the authorized step in the same turn as the acknowledgement.
- **Curiosity ≠ commission.** A clarifying question ("why is X slow?") after the primary goal is met seeks understanding, not more work → answer and stop; do not pair with a new proposal unless the user explicitly asks.
- **A turn producing no new facts must end in a write** — no new file read or command output means analysis is done, so edit the owning file instead of re-deliberating.
- When soliciting feedback, block on it → end the turn after asking; do not implement until answered. When decisions must be collected first, gather and confirm the full set before executing any — never interleave asking with acting.
- **Verify mechanism before offering options.** An option or proposed approach claiming "accomplish X via tool/capability Y" is a behavioral claim → read Y's interface from upstream source before presenting. Unverified → research first or label mechanism unconfirmed; choosing an unverified path transfers a false premise into the plan.
- **Important:** use Skill tool for every skill-owned event — raw `git commit`/`gh pr merge`/ad-hoc planning IS the approximation this forbids. First write-action of a session is the highest-risk skip point. The table is illustrative; the wrapper's post-action checklist is what raw CLI silently drops.
- **Announce-and-invoke same turn.** A skill counts only when its `Skill` call is
  in that response; narration alone is a violation. Catch it → invoke before any
  other action.
- **Skill presence and phase routing:** [`references/skill-reference.md`](references/skill-reference.md).

### HARD RULE — needs shell? then no worktree isolation

- **Decide at dispatch from tool needs:** tests, lint, build, commit, push, PR creation → never `isolation: "worktree"`.
- `isolation: "worktree"` blocks Bash, Grep, and Glob — Read/Edit/Write only. No runtime error; agents already dispatched need manual recovery.
- Shell unavoidable → skip isolation, or the coordinator runs shell ops on worktree paths after agents finish editing.

### Continuity Rules

The Phase 1 plan is the session contract.

- **Important:** Enumerate every deliverable before acting — a prompt with a noun task and a closing imperative is two items. Mid-session explicit requests are deliverables — act immediately or track as follow-up. Never silently drop an explicit ask.
- On interruption mid-plan: stop, update the active plan/TodoWrite list, re-state the new top item in one line, resume from the earliest incomplete item.
- Final completeness gate: before claiming completion, re-read the plan and ensure every numbered step is finished or explicitly deferred/removed.

---

## Phase 1: Plan

**HARD RULE:** invoke `wk-plan` before any planning:

```
Skill(wk-plan, args="<task from session context>")
```

- **Plan supplied by user or `wk-plan` → supplying is approval.** Structural minimum: implementation sequence, scope decisions, verification — raw feedback without these is planning input, not a plan. Validate only: references resolve, order valid, nothing done — then Phase 2.
- **Optional sibling-repository work is opt-in.** Confirm before inspecting or changing another repository; adjacency,
  a possible follow-up, or shared ownership does not expand current task scope.
- If `wk-plan` surfaced unanswered questions, resolve them before proceeding.
- **Complex task → advisor:** consult the `advisor` server tool during Phase 1: [`references/advisor-tool.md`](references/advisor-tool.md).

**HARD RULE — wait for plan approval before the first Edit/Write/Bash write-action (incl. fetching/reading *for* the build once committed to a direction).** No size exemption in either direction — "too small" and "obviously right" both violate. Present → approve → execute; a user-supplied plan arrives approved.

---

## Phase 2: Implement

### HARD RULE — branch pre-flight before first edit

- Run `git rev-parse --abbrev-ref HEAD` and verify the branch matches the task's intended base before any Edit/Write.
- **Linked worktree:** resolve edit targets under `git rev-parse --show-toplevel` — absolute paths anchored to the primary checkout silently edit the wrong tree.
- **Rebase/cherry-pick conflicts → verify target base.** Run `git log --oneline -5`; if base mismatches worktree parent, stop and re-examine — never force through a wrong-base conflict.

Pre-patch routing: `.md` → [`wk-markdown`](../markdown/README.md); Mermaid →
[`wk-mermaid`](../mermaid/README.md); arch-bearing →
[`wk-arch-review`](../arch-review/README.md) detector, then draft-complete gate.
Post-edit classification fails.

**Subtractive-first:** before adding code, evaluate if removal/simplification eliminates the problem — zero new failure modes.

- **Fleet-first for shared integrations:** grep 2-3 sibling repos for the same pattern before fixing shared code; fleet consensus outranks spec.

Execute the plan step by step. After each step:

1. Run tests.
2. Invoke `wk-workstyle` before every code commit — no size exemption.
3. Invoke `wk-docs` for affected docs; config-schema additions land with `docs/specs/` in the same or next commit.
4. Invoke `wk-commit`.

Never batch multiple plan steps into one commit, defer docs, or skip tests between commits.

- **Narrate branch-rewriting ops.** Print before/after SHAs after rebase/merge — silence reads as lost work.

### Cross-cutting changes

For normalization, renames, required fields, schema changes, or similar recurring patterns:

1. Enumerate every affected site before writing:

   ```bash
   grep -rn '<pattern>' <src-dirs>
   ```

2. Implement all sites.
3. Commit.
4. Publish, then run adversarial review once.
5. Fix residuals in ≤1 follow-up commit.

### Artifact sync with code changes

Structural change → [sync artifacts](references/doc-sync-mechanics.md) in the
same commit. External failure → [reproduce before fixing](references/external-call-reproduction.md).

### Edit-scope pre-flights

Enumerate every affected site and fix all in one pass before tests:

- **Signature widening** — non-optional public param/required field → grep every caller/initializer, fix each in the same commit.
- **`replace_all: true`** — grep the target string first; reject if any occurrence needs a different value/context or must stay unchanged.
- **Agent-brief identifiers** — grep the declaring source; quote exact names/values into the prompt, never recalled ones. One wrong identifier multiplies across every agent trusting the brief.
- **Guard modification** — before editing an existing guard/filter/null-check, verify whether the upstream change already makes it correct for new inputs; a callee now returning valid data means existing checks already pass.

### Code Standards

Apply to ALL code:

- **Version pins:** exact versions only — no `latest`/`stable`/`nightly`/`^`/`~` in `FROM`, `mise.toml`, Actions, or package managers. Official-action semver majors permitted.
- **Regexes:** named capture groups: `(?<year>\d{4})`.
- **Bash:** no `cd` per command; use absolute paths or `git -C <repo>`. [`references/code-standards-extended.md`](references/code-standards-extended.md) (base resolution + niche).
- **Shell simplicity:** sequential single-purpose commands, not compound chains — classifiers block what they cannot decompose. Surface denials; never silently restructure.
- **CLI flags:** [`references/verify-cli-flags.md`](references/verify-cli-flags.md).
- **Layer responsibility:** side effects live only in entrypoint layers. ENV reads in decision modules are side effects.
- **Platform-API traps:** [`references/platform-api-traps.md`](references/platform-api-traps.md).
- **Two-sided flow survey:** survey caller-side conditions and callee enforcement before designing a gate/filter/guardrail.
- **Identifier composition:** before combining sources (env vars, config, API fields) into a key, classify each by semantic domain (target vs. self, external vs. internal); a cross-domain fallback is a presence check, not identity.
- **HARD RULE — reuse existing config/secret resolution; never invent parallel overrides.** User pushback naming existing convention → adopt it. ([`reuse-existing-mechanism.md`](references/reuse-existing-mechanism.md))

---

## Phase 3: Test

Before code review, verify coverage and pass all checks.

### HARD RULE — select execution environment before validation

- Before first build/lint/test, inspect tracked container, devcontainer, runner, and repo instructions.
- Use a documented runnable project container; if none exists, say so before host fallback.
- **An explicit waiver of local validation short-circuits provisioning** — never
  build an environment to satisfy a gate the user removed; name what stays
  unverified instead.
- Mixed toolchains: [announce subsystem ownership; retain primary repo gate](references/environment-guardrails.md).

Required paths:

- **Happy path** — expected successful flow works end to end.
- **Sad path** — failures, invalid input, missing data, error conditions handled gracefully.
- **Edge cases** — boundaries, empty collections, null/undefined fields, concurrency, large inputs, off-by-one errors.

Verification:

- All tests pass before code review.
- Each commit passes tests independently.
- **Important — local lint before every push.** Run the project linter/type checker on changed files before any `git push`; never rely on CI for lint errors. Inspect hook config to enumerate every pre-push gate.
- Re-run every gate against final HEAD, not a mid-session snapshot.
- **User-loadable artifact:**
  [`build last after mutating gates`](references/2026-08-04_final-development-build.md).
- Validate transformations with a formerly-failing input.
- **Data-only change → compare the published set's membership and count
  before/after**, never a diff read alone.
- **Fix-symptom match:** verify a fix targets the exact user-reported symptom — not a plausible-but-different failure mode. When in-agent testing is impossible, state what the user should observe differently.
- **Default-branch-only producers:** apply
  [`generated-artifact acceptance`](references/2026-08-01_generated-artifact-acceptance.md);
  a post-merge-only caveat is a blocker, not a waiver.
- **A fast/narrow check is never the authoritative gate.** A pre-commit hook may lint a narrower file set than the full CI-mirroring check — run the full gate before claiming lint/format clean.
- **Dependent verification fails fast.** Run an expected-red proof and its later green gate in separate tool calls. If they must share one shell command, begin it with `set -euo pipefail`; never launch the green gate after the expected-red proof exits non-zero.
- **Important — never take a verdict from `$?` after a pipe.** See `wk-workstyle-shell` for limiters and the `PIPESTATUS` split.

Shell-script structure & symlink-guard tests: [`references/shell-script-test-checks.md`](references/shell-script-test-checks.md).

---

## Phase 3.5: Refactor & Deletion-Safety Scan

For every new/modified function/block, scan file + siblings for: existing helpers, repeated literals, near-duplicates (≥3 lines), nested conditionals, re-implemented patterns.

- **Post-correction re-audit:** after any mid-session correction, re-diff the full change set; revert/simplify hunks whose justification no longer holds.

Classify each opportunity:

- **Apply now** — reuse existing helper/constant, lift near-duplicate into a helper, flatten conditionals. Land as one commit before Phase 5.
- **Defer with note** — real but out-of-scope; add TODO to PR "Follow-ups".
- **Skip** — no real win or premature abstraction.

Re-run tests after every Apply-now change. Clean diff → record "refactor scan: none" in Phase 8.

### Deletion-safety scan

For every removed line/symbol/file, classify intentional or accidental — unexplained removal is a blocker, not a style nit.

- Removed symbol (function, const, field, export) → grep for surviving references; live caller = accidental drop → restore or migrate.
- Removed guard/validation/error-handling/cleanup/test → confirm replacement covers the case; none = regression → restore.
- Removed file → confirm no surviving imports and responsibility moved elsewhere.
- Deletion collateral to the stated goal (unrelated cleanup) → split into own commit, never bundle silently.

---

## Phase 3.6: Frontend Live Preview

Run only when the diff changes browser-rendered UI (`.tsx/.jsx/.vue/.svelte/.html/.css/.scss`, view/component/template dirs).

- Launch the app via the `run` skill or documented dev-server command.
- Drive every changed view in a real browser with Playwright tools; exercise happy paths.
- Capture snapshots/console; platform-pinned baselines → regenerate in CI container, never local host ([artifacts](references/2026-08-04_linux-visual-artifacts.md)).
- Load failure, console error on changed surface, or broken interaction → blocker; fix before publishing.
- Leave app/browser running and hand off the URL; continue Phase 5 onward while the user inspects.

Backend/config/docs-only diffs → record "frontend preview: N/A" in Phase 8.

---

## Phase 5: PR

**HARD RULE — "push succeeded" is NOT "work complete".** After `git push`, run `gh pr view 2>/dev/null`; no open PR → invoke `wk-pr` immediately. Push triggers this gate, not ends the task.

### Repo convention before branching

Branching is the default, not an absolute. Probe first:

- Treat the user's current task branch as authoritative. Branch only from default, detached HEAD, unrelated dirty work, or explicit isolation request.
- Resolve default branch dynamically.
- Gather PR-gated evidence: branch protection, `CODEOWNERS`, recent feature-branch merge commits.
- Branch only when evidence points to PR-gated workflow; otherwise commit straight to default and skip auto-PR.
- If signals conflict/are absent for a non-trivial change, branch and say why in one line.
- **Follow-up branch:** after a merged PR, branch from `origin/<default>` (fetch first) — stale local ref inflates diff.

After tests and Phase 3.5/3.6 scans pass, invoke `wk-pr` (never raw `gh pr create`) — it handles draft creation, stacking, self-review, feedback triage, and marking ready. Publishing precedes review; it does not wait on a verdict.

### Stacked PRs — per-PR lifecycle

- Each PR in a stack must independently complete Phases 5 → 6.5. Batch-pushing all PRs as drafts without running the lifecycle per PR is a violation.

### Post-push sync

`wk-commit` handles PR description sync and stale comment resolution after every push.

**HARD RULE:** auto-sync drifted artifacts — never ask. After push, code change, or pivot, audit PR title/body, self-review, ticket, docs; update same turn. On pivot, resolve stale self-review threads and re-post via `wk-self-review`. Confirm only when genuinely ambiguous.

Before reworking a PR branch, [reconcile against its actual base](references/pre-rework-base-reconcile.md) — resolve the PR's base first; never assume default as the rebase target.

---

## Phase 5.5: Adversarial Review — the single review gate

With the PR published and ready, invoke `wk-adversarial-review`. **This is the
workflow's only dispatch point.**

**HARD RULE — review gates merge, not publish.** Push, PR creation, and readying
need no verdict. Merge and `gh pr merge --auto` require clear review lineage;
SHA equality is not required. No size or docs-only exemption.

- Every other skill reads the record; missing means Phase 5.5 never ran.
- Publishing first lets CI and review run together.
- Finding-response commits and tree-identical rewrites preserve lineage through
  targeted validation. Unmatched scope, refactor, or logic gets one
  delta-scoped re-review:
  [`wk-adversarial-review`](../adversarial-review/README.md).

`wk-adversarial-review` returns **clear**, **blocked**, or **suggestions-only**.

- **Clear** — if fix commits landed since self-review was staged, re-stage via
  `wk-self-review`; proceed to Phase 6.
- **Blocked** — fix each blocker via `wk-commit`, re-invoke until clear. Never merge or enable auto-merge on a blocked verdict.
- **Suggestions only** — follow the skill's A/B/C prompt.

Pre-flight findings are mandatory → fold blockers/improvements into the artifact and commit. Pause only for a genuine user-owned design decision.

**HARD RULE — never defer a security guard.** Missing guard/input validation (SSRF, injection, path traversal, scheme check) is blocker-class — apply now; never propose deferring without explicit user instruction. Split a larger tooling swap into a follow-up, never the guard itself.

---

## Phase 6: CI Fix Loop

After PR creation or any push, monitor and fix CI until green. CI runs concurrently with Phase 5.5 — fold failures into the same fix pass.

- **Do not repeat a green pre-push gate locally after pushing the same SHA.**
  Poll CI; re-run locally only after a new commit or to reproduce a CI failure.
  Before any command, name the new evidence it can produce; known output is not
  verification.
- Use `gh pr checks --watch --fail-fast` for generic checks; it can exit on partial resolution → re-confirm the rollup is terminal before calling CI green (`wk-gh`).
- Use `wk-buildkite` for Buildkite.
- Run long watches in background; before any wait >~1 min, state what runs and rough duration.
- **Complete CI watches same turn** — never hand "merge once CI passes" to the user or end a turn announcing a holding pattern.
- **Don't idle on CI — interleave.** Start independent plan tasks while polling; hard-wait only when nothing else can progress.
- Read actual logs first.

Diagnosis rules — map failure type to action and error signal to first check: [`references/ci-diagnosis-table.md`](references/ci-diagnosis-table.md).

Fix and re-push:

1. Apply minimal targeted fix.
2. Run failing gate locally.
3. Commit via `wk-commit`.
4. Push normally — never force-push unless explicitly required.
5. Update PR description via `wk-commit`.
6. Re-enter loop.

Fix-candidate ordering — least invasive first, never skip ahead: [`references/ci-fix-candidate-ordering.md`](references/ci-fix-candidate-ordering.md).

Loop limits:

- Maximum 3 fix attempts per CI run.
- Each attempt must differ from prior attempts.
- Before attempt 3, state the axis being varied; if prior attempts varied the same axis, broaden.
- After 3 failures, stop and hand off with what was tried and the current failure.

Exit on all-green, max attempts, or confirmed infra/flaky failure. After green, resume `wk-pr` post-creation.

**HARD RULE:** verify every test-plan checkbox before updating the PR description and before merge or auto-merge enablement. Run every runnable verification command; leave a box unchecked only when genuinely impossible and note why.

---

## Phase 6.5: Review-Comment Resolution Loop

After CI green and PR ready, drive every open review comment to resolution before merge.

- Poll unresolved review threads.
- While any remain, invoke `wk-pr-resolve`.
- Re-poll after every pass **and after every later push** — bots re-review on each push, so resolution is per-push, not one-time.
- Re-enter Phase 6 if a resolving commit turns CI red.
- Exit only when zero unresolved threads remain and CI is green.
- Treat the loop as spanning sessions; resume from the poll step on later invocations. Never run the Phase 8 retro while a push since the last `wk-pr-resolve` pass has unaddressed threads.

---

## Phase 7: Documentation Audit

Final audit after all code is complete:

1. Invoke `wk-docs`.
2. Verify README reflects user-facing changes.
3. ADRs for architectural decisions; specs if behavior changed; `docs/README.md` current.
6. If no `docs/` folder exists, `wk-docs` bootstraps `plans/`, `specs/`, `adr/`, `tutorials/`, `examples/`.

---

## Phase 8: Session Retro — NON-NEGOTIABLE

**HARD RULE:** at the end of every session, invoke `wk-retro`. No exceptions.

**HARD RULE:** `gh pr ready` is not a session terminus. After every successful `gh pr ready`, the next action is `Skill(wk-retro)`.

---

## Environment Guardrails

[`references/environment-guardrails.md`](references/environment-guardrails.md) (cloud auth, containers, global config, CI-provider routing).

---

## Skill Reference

Use [`references/skill-reference.md`](references/skill-reference.md) for phase
ownership and invocation routing.

---

## Checklist

Use this as a final gate before claiming work is complete:

- [ ] Every commit is atomic and passes tests/CI independently
- [ ] `wk-workstyle` pass completed on all touched files
- [ ] Documentation updated alongside each code change
- [ ] Tests cover happy path, sad path, and edge cases
- [ ] `wk-adversarial-review` returned clear review lineage before merge
- [ ] CI fix loop exited green on the current head — local HEAD, remote head, and
      the SHA the checks ran against are one commit
- [ ] PR description reflects current branch state
- [ ] Self-review posted for critical changes only
- [ ] All PR review threads resolved
- [ ] Version pins are exact
- [ ] Scripts have correct file permissions
- [ ] Diagrams use Mermaid, not ASCII art
- [ ] Regexes use named capture groups
- [ ] ADRs created for significant architectural decisions
- [ ] Session retro completed via `wk-retro`
- [ ] Every numbered plan step is finished or explicitly deferred

---

## Post-Completion

Invoke `wk-learn workflow`.
