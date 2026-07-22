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
model: sonnet
effort: low
license: MIT
group: workflows
metadata:
  author: whizzzkid
  version: '2026.07.22-173723'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Workflow

Master orchestration for development tasks. Phases run in order (`## Phase 1`–`8`); follow the sequence exactly.

---

## Mandatory Activation

- Fires on EVERY task producing code changes, a commit, a push, a PR, or a CI build from a code change. No opt-out, no "too small" exemption.
- Session resumption is a fresh start → before any write action after context compaction, rollover, or "continue where we left off", invoke `wk-workflow` again.
- A planning discussion in chat is NOT a substitute for this invocation — invoke the skill before the first Edit/Write/Bash; it may surface branch hygiene/guardrails/pre-flight the chat missed.

### Autonomy Rules

Execute the workflow without asking permission at each step.

| Situation | Do this | Do NOT do this |
|---|---|---|
| Ready to commit | Invoke `wk-commit` | Ask “shall I commit?” |
| Tests pass, review clean | Invoke `wk-pr` | Ask “would you like a PR?” |
| CI fails | Enter fix loop automatically | Ask “should I investigate?” |
| Review blocks | Fix blockers, re-invoke `wk-adversarial-review` | Ask “should I fix these?” |
| Docs need updating | Invoke `wk-docs` | Ask “should I update docs?” |
| Session ending | Invoke `wk-retro` | Ask “should I do a retro?” |

Stop and ask only when: plan is ambiguous; CI persists after 3 attempts; a finding requires a user-owned design decision; user explicitly requested a pause/check-in; or a destructive/shared-state action is required.

- When soliciting feedback, block on it → end the turn after asking; do not implement past that point until answered.
- Skill invocation is mandatory → use the Skill tool for prescribed skills, do not approximate with raw commands. Run the invoked skill's full flow; user prose is additive context, not a license to skip parts.
- **Announce-and-invoke in the same turn:** a skill counts as invoked only when its `Skill` call appears in the same response as the text announcing it. "Now running X" with no same-turn `Skill(X)` call is a protocol violation — narration is not action. On catching a self-announcement without its call, invoke the skill before any other action.
- **HARD RULE — never report a skill absent from the session available-skills list alone.** The list is not exhaustive; a skill can exist on disk yet be missing from it. Confirm via `ls "$WK_SKILLS_HOME/skills/" | grep <name>` before telling the user a skill is missing; report absent only when that returns nothing.
- Batch independent tool calls in one response whenever possible.

### Continuity Rules

The Phase 1 plan is the session contract.

- **Important:** Read the prompt to the end and enumerate every deliverable before acting. A message opening with a noun task ("create a ticket") and closing with an imperative ("fix this") is two work items — commit to the full list first; never stop after the first deliverable. Order left implicit → state the intended sequence in one line before the first write-action so a redirect stays cheap.
- On interruption mid-plan: stop, update the active plan/TodoWrite list, re-state the new top item in one line, resume from the earliest incomplete item.
- Final completeness gate: before claiming completion, re-read the plan and ensure every numbered step is finished or explicitly deferred/removed.

---

## Phase 1: Plan

**HARD RULE:** invoke `wk-plan` before any planning:

```
Skill(wk-plan, args="<task from session context>")
```

- If `wk-plan` already produced an approved plan this session, skip Phase 1 and execute it.
- If `wk-plan` surfaced unanswered questions, resolve them before proceeding.
- Do not re-plan inline after an approved plan exists.
- **Complex task → advisor:** when `wk-plan` flags the task complex (non-obvious architecture, unresolved failure mode, high blast radius), consult the `advisor` server tool before committing and fold its advice in. Reserve for real uncertainty, after orienting (not turn 1); skip when the beta tool is absent. See [`references/advisor-tool.md`](references/advisor-tool.md).

**HARD RULE — wait for plan approval before the first Edit/Write/Bash write-action (incl. fetching/reading *for* the build once it commits to a direction), any size.** Size-independent in BOTH directions: neither "small/2-line/obvious" nor "large/exciting/obviously-right — let me build" (momentum) waives it. Present-plan → wait-for-approval → execute.

---

## Phase 2: Implement

Before the first Edit/Write, confirm cwd is the intended worktree:

```bash
git rev-parse --abbrev-ref HEAD
```

Execute the plan step by step. After each step:

1. Run tests.
2. Invoke `wk-workstyle` before every code commit — no size exemption.
3. Invoke `wk-docs` for affected docs; config-schema additions land with `docs/specs/` in the same or next commit.
4. Invoke `wk-commit`.

Never batch multiple plan steps into one commit, defer docs, or skip tests between commits.

### Cross-cutting changes

For normalization, renames, required fields, schema changes, or similar recurring patterns:

1. Enumerate every affected site before writing:

   ```bash
   grep -rn '<pattern>' <src-dirs>
   ```

2. Implement all sites.
3. Commit.
4. Run adversarial review once.
5. Fix residuals in ≤1 follow-up commit.

### Design pivots travel with their docs

When a commit changes a feature's logical structure, update every artifact describing the old shape in the same commit: design spec, implementation plan, inline comments, test names/comments, ADR, and spec sections enumerating tests.

Triggers: conditional became unconditional, helper lifted/inlined/replaced, paths merged/split, interface signature changed, state lifecycle moved.

### File/table/test sync

- New file → update the spec’s New/Modified Files tables in the same commit.
- Test added/removed/renamed → grep specs/plans/READMEs for the file/function and count phrases, update hits in the same commit.
- Renamed string → grep specs for OLD literal incl negative `not_to include`; stale negatives pass trivially, losing coverage.
- Major spec rewrite → STATUS UPDATE banner citing the SHA; schedule the full rewrite as a follow-up commit.

External-call reproduction before a fix: [`references/external-call-reproduction.md`](references/external-call-reproduction.md).

### Edit-scope pre-flights

Enumerate every affected site and fix all in one pass before tests:

- **Signature widening** — non-optional public param/required field → grep every caller/initializer, fix each in the same commit.
- **`replace_all: true`** — grep the target string first; reject if any occurrence needs a different value/context or must stay unchanged.

### Code Standards

Apply to ALL code:

- **Version pins:** exact versions everywhere. No `latest`, `stable`, `nightly`, unpinned tags, `^`, or `~`. Dockerfile `FROM`, `mise.toml` / `.tool-versions`, GitHub Actions, git clones in Dockerfiles, and package managers must pin exact versions or official-action semver majors.
- **Regexes:** named capture groups: `(?<year>\d{4})`.
- **Bash:** no `cd` per command; use absolute paths or `git -C <repo>`. Resolve base dynamically:

  ```bash
  BASE=$(gh pr view --json baseRefName --jq .baseRefName 2>/dev/null || git symbolic-ref refs/remotes/origin/HEAD --short | sed 's@^origin/@@')
  git diff "$(git merge-base HEAD "origin/$BASE")...HEAD"
  ```

- **CLI flags:** verify any flag against the tool's `--help` (or `--help`-equivalent) before embedding it in a doc, skill, or committed script. An unverified flag name fails with `flag provided but not defined` (exit 2) on first run.
- **File permissions:** executable scripts `chmod +x`; source-only scripts 644.
- **Diagrams:** Mermaid over ASCII; `wk-mermaid` owns diagram-type selection.
- **Layer responsibility:** side effects live only in entrypoint layers. ENV reads in decision modules are side effects.
- **ADRs:** record significant architectural decisions in `docs/adr/` (`wk-docs` owns the template).
- **Niche standards** (example-format confirmation, tool-output/error-string parsing, external-API field reuse, content-lint hook scoping, env-var documentation, structured-row insert, reuse hygiene, hardcoded-constant-vs-dynamic-sibling, boot/internal-symbol error handling, full-boot config-dependency enumeration, sandboxed-step env forwarding, coercion same-class audit, portable home paths) live in [`references/code-standards-extended.md`](references/code-standards-extended.md); apply each under the same authority when its case matches.
- **Two-sided flow survey:** before designing a gate/filter/guardrail, survey codebase/docs for caller-side conditions and callee enforcement.
- **Existing-gate preservation:** never add a `skip_*`/`bypass_*`/`force_*` parameter that disables an existing feature gate, guardrail, or rate limit without explicit user confirmation. A new code path is not a license to bypass — when a gate genuinely cannot be honored (e.g., its input is unavailable at call time), document it as a known limitation, never silently remove the protection.
- **HARD RULE — reuse the mechanism the codebase already provides for config/secret resolution; never invent a parallel override (dummy env exports, a new config path). Repeated user pushback naming an existing convention is a hard stop — adopt the named mechanism, never defend the invented one.** (See reuse-hygiene, code-standards-extended.)

---

## Phase 3: Test

Before code review, verify coverage and pass all checks.

Required paths:

- **Happy path** — expected successful flow works end to end.
- **Sad path** — failures, invalid input, missing data, error conditions handled gracefully.
- **Edge cases** — boundaries, empty collections, null/undefined fields, concurrency, large inputs, off-by-one errors.

Verification:

- All tests pass before code review.
- Each commit passes tests independently.
- Project linter/type checker passes.
- Full pre-push gate passes before any `git push`; inspect hook config to enumerate every gate.
- Re-run every gate against final HEAD, not a mid-session snapshot.
- Validate transformations with a formerly-failing input.
- **A fast/narrow check is never the authoritative gate.** A pre-commit hook may lint a narrower file set than the full CI-mirroring check — run the full gate before claiming lint/format clean. And never read `$?` from a pipe: after `a | b` it is `b`'s status, so `check | tail` reports `tail`'s success and hides the check's failure — read `${PIPESTATUS[0]}`, or redirect output to a file and check `$?`.

In a mise-managed repo, `GemNotFound` on `bundle exec` / `bin/rspec` is a setup gap. Run `bin/setup`, then invoke tests via `mise exec -- <cmd>`.

Shell-script structure & symlink-guard tests: [`references/shell-script-test-checks.md`](references/shell-script-test-checks.md).

---

## Phase 3.5: Refactor & Deletion-Safety Scan

After tests pass and before adversarial review, scan the diff and neighboring code for refactor/reuse opportunities.

For every new/modified function, helper, constant, or block, scan same file, sibling files, and imported modules for: existing helpers/constants/types, repeated literals, near-duplicate blocks (≥3 similar lines), long conditional chains, nested blocks, re-implemented language/framework patterns.

Classify each opportunity:

- **Apply now** — reuse existing helper/constant, lift near-duplicate into a helper, flatten conditionals. Land as one commit before Phase 4.
- **Defer with note** — real but out-of-scope; add TODO to PR "Follow-ups".
- **Skip** — no real win or premature abstraction.

Re-run tests after every Apply-now change. A clean diff is valid → record "refactor scan: no opportunities" in Phase 8.

### Deletion-safety scan

For every removed line/symbol/file in the diff, classify the deletion intentional or accidental — an unexplained removal is a blocker, not a style nit.

- Removed symbol (function, const, field, export) → grep the repo for surviving references; any live caller is an accidental drop → restore or migrate it.
- Removed validation, guard, error-handling, cleanup, or test → confirm a replacement covers the same case; no replacement = regression → restore it.
- Removed file → confirm nothing still imports it and its responsibility moved elsewhere.
- Deletion collateral to the change's stated goal (unrelated cleanup) → split into its own commit, never bundle it silently.

---

## Phase 3.6: Frontend Live Preview

Run only when the diff changes browser-rendered UI: client components, templates/views, styles, or client-side routes (`.tsx/.jsx/.vue/.svelte/.html/.css/.scss` and view/component/template dirs).

- Launch the app via the `run` skill or documented dev-server command.
- Drive every changed view in a real browser with Playwright tools; exercise happy paths.
- Capture snapshots and console messages.
- Treat load failure, console error on the changed surface, or broken interaction as a Phase 4 blocker.
- Leave app/browser running and hand off the URL; continue Phase 4 onward while the user inspects.

Skip backend/config/docs-only diffs and record "frontend preview: N/A" in Phase 8.

---

## Phase 4: Adversarial Review — the single review gate

After implementation, tests, refactor scan, and frontend preview (if applicable), invoke `wk-adversarial-review`. **This is the only place the workflow runs it**; later phases never re-declare it as a separate step.

**HARD RULE:** adversarial review is one session gate keyed to *new commits since the last clear verdict* — not per-phase, not per-commit.

- Run once on the complete logical change, then push. Never push-and-review per incremental commit.
- Idempotent re-entry: a later push (Phase 6 CI fix, Phase 5 rework, `gh pr ready`) re-fires the gate only when commits landed since the last clearance, and then sweeps only the delta. No new commits → it prints the prior clearance instead of re-running.
- Fix residuals in ≤1 follow-up commit, then re-run once.

`wk-adversarial-review` returns **clear**, **blocked**, or **suggestions-only**.

- **Clear** — proceed to Phase 5.
- **Blocked** — fix each blocker via `wk-commit`, re-invoke until clear. Never push, `gh pr ready`, or `gh pr create` on a blocked verdict.
- **Suggestions only** — follow the skill's A/B/C prompt.

Pre-flight findings are mandatory actions, not options → fold blockers/improvements into the relevant artifact and commit. Pause only for a genuine user-owned design decision.

**HARD RULE — never defer a security guard.** A missing guard or input validation (SSRF, injection, path traversal, scheme check) is blocker-class regardless of scope — apply it now; never propose deferring it without explicit user instruction. Split a larger tooling swap into a follow-up, never the guard itself.

**HARD RULE:** nothing leaves the machine without a clear verdict covering current HEAD — every push, PR transition (`gh pr create`, `gh pr ready`), force-push. Satisfy this through the idempotent gate above, never a fresh full review per step. No size/docs-only exemption.

---

## Phase 5: PR

**HARD RULE — "push succeeded" is NOT "work complete".** After every successful `git push`, run `gh pr view 2>/dev/null`; no open PR → invoke `wk-pr` immediately (no size exemption, no waiting to be asked). The push is this check's trigger, not the task's end.

### Repo convention before branching

Branching is the default, not an absolute. Probe first:

- Resolve default branch dynamically.
- Gather PR-gated evidence: branch protection, `CODEOWNERS`, recent feature-branch merge commits.
- Branch only when evidence points to PR-gated workflow; otherwise commit straight to default and skip auto-PR.
- If signals conflict/are absent for a non-trivial change, branch and say why in one line.

After code review passes, invoke `wk-pr` (never raw `gh pr create`) — it handles draft creation, stacking, CI polling, self-review, feedback triage, and marking ready.

### Post-push sync

`wk-commit` handles PR description sync and stale comment resolution after every push.

**HARD RULE:** auto-sync drifted artifacts — never ask permission to fix obvious drift. After any push, significant code change, or approach pivot, audit PR title/body, self-review comments, ticket description, and related docs; update in the same turn. On an approach pivot, also resolve stale self-review threads and post fresh comments via `wk-self-review`. Confirm only when sync content is genuinely ambiguous.

Before reworking a PR branch — force-push, restructure, content rewrite, big rebase, scope change — fetch and reconcile against the PR's actual base and default branch. Resolve PR base before proposing a rebase target; never assume default. Recipe: [`references/pre-rework-base-reconcile.md`](references/pre-rework-base-reconcile.md).

---

## Phase 6: CI Fix Loop

After PR creation or any push to a PR branch, monitor, diagnose, and fix CI until green. Do not mark ready while CI is red.

- Use `gh pr checks --watch --fail-fast` for generic checks; it can exit on partial resolution → re-confirm the rollup is terminal before calling CI green (`wk-gh`).
- Use `wk-buildkite` for Buildkite.
- Run long watches in the background; before any wait >~1 min (suite, CI poll, flake re-runs) state what runs and rough duration so silence isn't read as a hang.
- **Never end a turn announcing a holding pattern or delegating its final action.** Watch CI to completion this turn; once green, run `gh pr ready` yourself — never hand "mark ready once CI passes" to the user.
- **Don't idle on the CI barrier — interleave.** While a background poll runs, start the next plan task that has no dependency on this PR's green state; the poll re-invokes you on completion. Hard-wait only when nothing else can progress (last PR in stack, or a step genuinely needs green: auto-merge, or a later stacked PR that builds on this one). Tail of PR N + body of PR N+1 in parallel is the default.
- Read actual logs first.

| Failure type | Action |
|---|---|
| Code failure | Diagnose root cause; apply the smallest fix |
| Flaky test | Re-trigger once; if it repeats, treat as real |
| Infrastructure | Re-trigger; if persistent, inform user — no code fix |

Diagnosis rules — map error signal to first check: [`references/ci-diagnosis-table.md`](references/ci-diagnosis-table.md).

Fix and re-push:

1. Apply minimal targeted fix.
2. Run failing gate locally.
3. Commit via `wk-commit`.
4. Push normally — never force-push unless explicitly required.
5. Update PR description via `wk-commit`.
6. Re-enter loop.

Fix-candidate ordering:

| Priority | Candidate | Notes |
|---:|---|---|
| 1 | Version downgrade | One minor/patch when dep upgrade is proximate cause |
| 2 | Repo-rule compliance | Usually one-line config change |
| 3 | Same-tool config tweak | Tool config before tool swap |
| 4 | Same-tool backend/option change | Backend, installer flag, or runner option within existing tool |
| 5 | Tool-stack change | Removing/replacing a user-named tool requires explicit confirmation |

Rules:

- Coupled config rule: when changing a tool version, audit every config file that tool reads in the same commit.
- CI-only fix evidence: prove the concrete environment delta and keep the fix scoped to it.
- If failure was caused by stale base, integrate latest base first.
- If CI cannot be reproduced locally, inspect the full remote log before changing code.

Loop limits:

- Maximum 3 fix attempts per CI run.
- Each attempt must differ from prior attempts.
- Before attempt 3, state the axis being varied; if prior attempts varied the same axis, broaden.
- After 3 failures, stop and hand off with what was tried and the current failure.

Exit when all checks pass, max attempts are reached, or infrastructure/flaky failure is confirmed. After green, resume `wk-pr` post-creation: self-review, automated feedback triage, and mark ready.

**HARD RULE:** verify every test-plan checkbox before updating the PR description. Run every runnable verification command; leave a box unchecked only when genuinely impossible and note why.

---

## Phase 6.5: Review-Comment Resolution Loop

After CI exits green and the PR is marked ready, drive every open review comment to resolution before merge.

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
3. Create/update ADRs for significant architectural decisions.
4. Update specs if behavior changed.
5. Ensure `docs/README.md` is current.
6. If no `docs/` folder exists, `wk-docs` bootstraps `plans/`, `specs/`, `adr/`, `tutorials/`, `examples/`.

---

## Phase 8: Session Retro — NON-NEGOTIABLE

**HARD RULE:** at the end of every session, invoke `wk-retro`. No exceptions.

**HARD RULE:** never ask whether to capture learnings — offering to capture is still asking. Invoke `wk-learn` in the same turn a correction or mistake surfaces, and after every skill run.

**HARD RULE:** `gh pr ready` is not a session terminus. After every successful `gh pr ready`, the next action is `Skill(wk-retro)`.

The retro scans the session, classifies interruptions/redirects by affected skill, writes per-skill learning files, reviews mistakes/corrections/gaps/decisions/successes, writes a dated entry to the global retro log, and promotes actionable rules globally.

---

## Environment Guardrails

- **AWS / ECR:** on auth/credential errors, prompt for `aws sso login`; do not retry without valid creds.
- **Docker:** on daemon/socket errors, prompt for Docker Desktop or Colima; use `wk-docker`.
- **Configuration:** add permission rules, settings, and MCP servers to `$HOME/.claude/settings.json` (global), not `.claude/settings.local.json`, unless intentionally local. For MCP servers, use `--scope user`. Never add MCPs to `$HOME/.claude.json`.
- **CI:** use `wk-buildkite` for Buildkite; read actual logs, do not guess.

---

## Skill Reference

| Skill | When | Phase |
|---|---|---|
| `wk-plan` | Every non-trivial task before implementation | 1 |
| `wk-commit` | After each implementation step; CI fix commits | 2, 6 |
| `wk-workstyle` | Code-quality gate before every commit | 2 |
| `wk-docs` | With each commit and final audit | 2, 7 |
| `wk-pr` | Creating/updating a pull request | 5 |
| `wk-self-review` | Invoked automatically by `wk-pr` after CI passes | 5 |
| `wk-buildkite` | Diagnosing Buildkite CI failures | 6 |
| `wk-adversarial-review` | Single review gate; owned by Phase 4, idempotent re-entry on new commits | 4 |
| `wk-pr-update` | Rebasing/syncing a PR branch with its base | 5, 6 |
| `wk-learn` | Post-completion learning capture | any |
| `wk-retro` | End of every session | 8 |
| `wk-docker` | Docker/containers | any |
| `wk-datadog` | Observability resources | any |
| `wk-worktree-cleanup` | Cleaning up merged worktrees | any |

---

## Checklist

Use this as a final gate before claiming work is complete:

- [ ] Every commit is atomic and passes tests/CI independently
- [ ] `wk-workstyle` pass completed on all touched files
- [ ] Documentation updated alongside each code change
- [ ] Tests cover happy path, sad path, and edge cases
- [ ] `wk-adversarial-review` returned a clear verdict against current HEAD
- [ ] CI fix loop exited green
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
