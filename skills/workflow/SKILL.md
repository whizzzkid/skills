---
name: wk:workflow
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
metadata:
  author: whizzzkid
  version: '2026.04.29-231055'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Workflow

Master orchestration for all development tasks. Every `wk:*` skill is invoked
from within this workflow at the prescribed point. Follow this sequence exactly.

```
Plan -> Implement (commit per step + docs) -> Test (happy/sad/edge)
  -> Review (adversarial agent) -> PR (wk:pr) -> CI Fix Loop
  -> Self-Review -> Docs Audit -> Retro
```

---

## Mandatory Activation

**This workflow fires on EVERY task that will produce code changes, a
commit, or a pull request.** There are no exceptions. The agent does not
get to decide whether a task is "too small" or "just a quick fix."

If the task will result in any of these, this workflow is active:
- A new or modified file in the repository
- A git commit
- A push to a remote branch
- A pull request (new or updated)
- A CI build triggered by a code change

**There is no opt-out.** The agent follows the phases in order. Skipping
phases, reordering phases, or substituting ad-hoc commands for prescribed
skills is a violation.

## Autonomy Rules

**Execute the workflow without asking permission at each step.** The user
has already approved the workflow by using it. Minimize interruptions:

| Situation | Do this | Do NOT do this |
|-----------|---------|----------------|
| Ready to commit | Invoke `wk:commit` | Ask "shall I commit?" |
| Tests pass, review clean | Invoke `wk:pr` | Ask "would you like a PR?" |
| CI fails | Enter fix loop automatically | Ask "should I investigate?" |
| Review surfaces issues | Fix them and re-review | Ask "should I fix these?" |
| Docs need updating | Invoke `wk:docs` | Ask "should I update docs?" |
| Session ending | Invoke `wk:retro` | Ask "should I do a retro?" |

**Only stop and ask the user when:**
- The plan is ambiguous and multiple valid approaches exist
- A CI failure persists after 3 fix attempts
- A code review finding requires a design decision (not just a fix)
- The user explicitly said to pause or check in at a specific point
- Destructive or shared-state actions (force push, production deploy)

**Skill invocation is mandatory.** When this workflow says "invoke
`wk:commit`" or "invoke `wk:pr`", the agent MUST use the Skill tool to
call the skill — not approximate the behavior by running raw commands.
The skills contain rules, guards, and conventions that raw commands skip.

## Continuity Rules

The plan presented in Phase 1 is the contract for the session. Two
recurring failure modes corrode that contract — handle both explicitly.

### On user interruption mid-plan

When the user interrupts to add, redirect, or reprioritize:

1. **Stop** before executing the new ask.
2. **Update the active plan/TodoWrite list** — insert the new work, keep
   every unfinished prior item visible. The new ask adds to the plan; it
   does not replace the remaining steps.
3. **Re-state** the new top of the plan in one line.
4. **Resume** from the earliest incomplete item — which may be the new
   ask, but only if it is genuinely the next step.

The natural drift after an interruption is to execute the new ask and
then continue from "whatever was last on screen" — which is the new
ask, not the original plan. The update-first rule prevents that drift.

### Final completeness gate

Before declaring the task complete, re-read the full plan and confirm
that **every numbered step** is either (a) finished or (b) explicitly
deferred or removed by the user. "The code shipped" is not the same as
"the plan is done." Polish steps — `wk:self-review`, `wk:docs`,
`wk:retro`, the CI verification — are part of the contract; silently
skipping them is a violation even when they feel optional after a
successful merge.

If any step is ambiguous, ask the user before claiming completion.

---

## Phase 1: Plan

Before writing any code, produce an explicitly numbered plan. Every plan MUST
contain these elements — if any are missing, add them before executing:

1. **Implementation steps** — what to build or change, broken into the smallest
   meaningful units
2. **Commit boundary after each step** — each step ends with `wk:commit`
3. **Documentation update with each step** — each step includes a `wk:docs`
   invocation for affected docs, README, specs, or ADRs
4. **Testing step** — covers happy path, sad path, and edge cases
5. **Code review step** — adversarial critique agent reviews the branch
6. **PR offer** — ask the user if they want a PR
7. **CI fix loop** — monitor CI, auto-diagnose and fix failures, re-push
8. **Session retro** — `wk:retro` at end of session (non-negotiable)

### Commit Granularity

Prefer the smallest possible commits. Each commit must:

- Do exactly one logical thing
- Pass all tests and CI in isolation — no commit may break the build
- Include documentation updates for any behavior it introduces or changes
- Be immediately committable via `wk:commit`

If a step is too large for a single commit, split it into sub-steps with their
own commit boundaries. When in doubt, split.

### Plan Presentation

Present the plan to the user before executing. Number every step. Mark which
steps produce commits. Example:

```
1. Add auth middleware          -> commit
2. Add auth tests (happy/sad)  -> commit
3. Update docs/specs/ADR       -> commit (or fold into step 1/2 if small)
4. Run full test suite
5. Adversarial code review
6. Offer to create PR
7. CI fix loop (auto-fix until green or bail after 3 attempts)
8. Session retro
```

---

## Phase 2: Implement

Execute the plan step by step. After completing each step:

1. **Run tests** — verify the step doesn't break anything
2. **Invoke `wk:docs`** — check for and update affected documentation (README,
   specs, ADRs, tutorials, reference docs). A feature commit without its
   documentation update is incomplete
3. **Invoke `wk:commit`** — create a signed, conventional commit with emoji

Never batch multiple steps into one commit. Never defer documentation to the
end. Never skip tests between commits.

### Code Standards

Apply these standards to ALL code written during implementation:

#### Version Pinning

Always pin to exact versions. Never use `latest`, `stable`, `nightly`, or
unpinned tags. This applies everywhere:

- Dockerfile `FROM` images: `rust:1.94.0-slim-bookworm` not `rust:latest`
- `mise.toml` / `.tool-versions`: `rust = "1.94.0"`
- GitHub Actions: `@v4` for official actions, commit SHAs for non-verified
- Git clones in Dockerfiles: pin to a commit hash
- Package managers: exact version, no `^` or `~` ranges

When adding a dependency or toolchain, verify the latest stable release via
the registry or release page. Do not guess.

#### Regular Expressions

Always use named capture groups: `(?<year>\d{4})` not `(\d{4})`. This
applies to all languages — no exceptions.

#### File Permissions

Ensure executable scripts have `chmod +x` before committing. Scripts that are
only `source`d remain 644. Check neighboring files for the project's
convention.

#### Diagrams

Use Mermaid over ASCII art in all markdown files. Choose the right type:

| Diagram type | Use for |
|--------------|---------|
| `flowchart` / `graph` | System flows, data flows, pipelines |
| `sequenceDiagram` | Request/response, API interactions |
| `classDiagram` | Type hierarchies, trait relationships |
| `stateDiagram-v2` | State machines, lifecycle diagrams |

#### Architecture Decision Records

When making a significant architectural decision (new dependency, pattern
change, technology choice, trade-off acceptance), create an ADR in
`docs/adr/` using the format: title, status, context, decision, consequences.

### Reuse hygiene

Patterns lifted from neighboring files are not portable by default.
Before copying a fallback chain, default, or conditional from one file
into another, trace each variable involved:

1. **Where is it set?** — secrets manager, pipeline env, bootstrap
   script, calling tool, operator workflow.
2. **What code path sets it?** — and does that same path reach the new
   location?
3. **Does the value mean the same thing in the new context?** — same
   PR, same env, same caller? If not, the pattern needs to be adapted,
   not copied verbatim.

Cross-script copies (one `bin/` script to another) are especially
hazardous because each script tends to have a different invocation
environment. When a variable's provenance differs between source and
destination, ask or grep for setters before reusing the pattern.

### Two-sided flow survey

Before designing a new gate, filter, or guardrail, survey the codebase
and docs for related caller-side conditions on the same concept
(labels, flags, opt-in markers, conditions). Gates often have two
sides: a caller condition (who is allowed to trigger) and a callee
enforcement (what the callee accepts). The two sides must tell a
coherent story — which is authoritative, which is advisory, what
happens when they disagree. Surfacing the caller side late forces a
redesign mid-implementation; surfacing it first folds it into the
original design.

### Environment-variable provenance in docs

Whenever code or docs introduce or reference an environment variable,
the documentation must answer:

1. **Where is it stored?** — secrets manager path, pipeline config,
   shell profile, deploy manifest.
2. **Who can edit that store?**
3. **How does a change propagate?** — next build, runtime reload,
   redeploy.
4. **What is the default if unset?**

Operators reading the doc need to know how to change the value without
a code deploy. If any of these are unclear at write time, ask the user
before publishing the doc or the code path that consumes the variable.

---

## Phase 3: Test

Before moving to code review, verify comprehensive test coverage exists.

### Required Test Paths

Every task MUST have tests covering:

- **Happy path** — the expected, successful flow works end to end
- **Sad path** — failures, invalid input, missing data, and error conditions
  are handled gracefully
- **Edge cases** — boundary values, empty collections, null/undefined fields,
  concurrent access, large inputs, off-by-one errors, and any scenario that
  is easy to overlook

### Verification

- All tests MUST pass before proceeding to code review
- Each commit on the branch should pass tests independently — run the suite
  after each commit to confirm
- If the project has a linter or type checker, those must also pass

### Shell-script structure tests (awk/grep pitfalls)

When writing bats or grep/awk assertions against a shell script's source
(e.g., "does this branch contain a call to `X`?"), awk range patterns
(`/start/,/end/`) are **substring matches, not token matches**. Two
failure modes recur:

1. **End-range terminated inside a string literal.** Bare shell keywords
   like `fi`, `done`, or `esac` as end-range patterns will match any line
   containing that substring — including `"All CI checks passed after N
   fix retries"`. Always anchor end-ranges to a full line:

   ```bash
   awk '/RETRY_NOUN=/,/^[[:space:]]*fi[[:space:]]*$/'
   ```

2. **Duplicate branch labels match the wrong block.** When a script has
   multiple `case` statements with identical branch labels (e.g.,
   `failed)` in both an emoji-mapping case and a PR-comment case),
   single-stage awk matches the first occurrence. Use two-stage awk —
   outer stage scopes to the correct block via a unique anchor, inner
   stage scopes to the branch:

   ```bash
   awk '/Unique anchor comment/,/esac/' "$SCRIPT" \
       | awk '/failed\)/,/;;/' | grep -q 'THING'
   ```

Before writing any range-based assertion, scan the target script for
(a) string literals that contain the planned end-range keyword as a
substring, and (b) duplicate branch labels across case blocks. Anchor
or two-stage accordingly.

---

## Phase 4: Code Review

After all implementation is complete and tests pass, launch a **fresh
adversarial critique agent** to review the work on the current branch.

Use the `superpowers:requesting-code-review` skill or spawn a dedicated
code-review subagent. The reviewer operates on `git diff main...HEAD` and
must be:

- **Adversarial** — actively seek bugs, security issues, and design flaws
- **Unbiased** — treat the code as if written by a stranger
- **Critical** — flag real problems, not just style preferences
- **Objective** — judge against the diff, not assumptions about intent
- **Naming-aware** — scrutinize variable, function, class, and file names for
  clarity, consistency, and adherence to project conventions. Flag vague names
  (`data`, `temp`, `result`), inconsistent casing, misleading names, and
  names that diverge from surrounding code style
- **Diff-sensitive** — stricter on net-new code and public API surfaces; verify
  renames/moves preserve behavior and update all references; confirm refactors
  don't alter semantics

The reviewer checks for: logic errors, missing error handling, security
vulnerabilities, test coverage gaps, documentation inconsistencies,
regressions, naming violations, and mismatches between names and intent.

### After Review

If the review surfaces issues:

1. Fix each issue (committing each fix individually via `wk:commit`)
2. Re-run the review until clean
3. Only proceed to PR after a clean review

---

## Phase 5: PR

**HARD RULE: every push to a branch that has no open PR invokes
`wk:pr` automatically.** No size exemption — a one-line fix is the
same as a 500-line feature for this rule. Phrases like "this is
small," "this doesn't need a PR," or "just a quick fix" are red
flags; if the rule applies, execute it. If the user pushes back
asking why no PR was created, **open it without asking** — the
Autonomy Rules table forbids the "would you like a PR?" question.

After code review passes, invoke `wk:pr` automatically. Do not ask for
permission — the workflow prescribes it. **Never use raw `gh pr create`
or any other method.** This is non-negotiable. `wk:pr` handles:

- Draft creation (always starts as draft)
- Stacked PRs when the diff exceeds ~30 lines
- CI polling (waits for green before proceeding)
- Self-review via `wk:self-review` — posts inline comments on **critical
  changes only**: design decisions, non-obvious logic, security-sensitive
  paths, behavioral changes. No noise, no trivial comments. Self-review
  is a **pending review** even when there is only one comment to make —
  never substitute raw `gh api .../comments` calls (those publish
  immediately and skip the human-in-the-loop checkpoint)
- Automated review feedback triage
- Marking ready for review

### PR Description Maintenance

**After EVERY push to a branch with an existing PR, the PR description MUST
be updated to reflect the current state of the branch.** The description
always matches what's on the branch — never stale. `wk:pr` handles this
automatically for pushes within its workflow. For pushes outside of `wk:pr`,
manually update with `gh pr edit`.

### Post-Push on Existing PR

When pushing new commits to a branch that already has a PR:

1. Update the PR description (`gh pr edit`)
2. Enter the CI fix loop (Phase 6)
3. Update or resolve stale self-review comments
4. Address new automated feedback

### Pre-rework fetch (HARD RULE)

Before any **rework** of a PR's branch — force-push, restructure,
content rewrite, big rebase, scope change — fetch and reconcile
against the PR's actual base **and** the default branch:

```bash
PR_NUM=$(gh pr view --json number --jq .number)
BASE=$(gh pr view "$PR_NUM" --json baseRefName --jq .baseRefName)
DEFAULT=$(git symbolic-ref refs/remotes/origin/HEAD --short \
          | sed 's@^origin/@@')

git fetch origin "$BASE" "$DEFAULT" --quiet

# If the resolved base advanced, integrate before reworking
LOCAL_MB=$(git merge-base HEAD "origin/$BASE")
REMOTE_TIP=$(git rev-parse "origin/$BASE")
if [ "$LOCAL_MB" != "$REMOTE_TIP" ]; then
  Skill(wk:pr-update, args="$BASE")
fi
```

Reworking on a stale base produces conflicts that are 100%
predictable from remote state and 100% avoidable with the fetch.
The cost is a few seconds; the cost of a force-push that
immediately reports `CONFLICTING` is a forced second cycle plus
visible churn. Never assume `main` is the relevant upstream — for
stacked PRs the base is a non-default branch that mutates
independently.

---

## Phase 6: CI Fix Loop

After the PR is created (or after any push to a PR branch), enter an
automated monitor-diagnose-fix loop. **Do not mark the PR ready or proceed
to self-review until this loop exits green.**

```
┌─────────────────────────────────────────────┐
│              CI FIX LOOP                    │
│                                             │
│  Poll CI ──► Green? ──yes──► Exit loop      │
│     │                                       │
│     └─ Failing? ──► Diagnose ──► Fix ──►    │
│         │            (wk:buildkite)   │     │
│         │                             │     │
│         │    ◄── commit (wk:commit) ◄─┘     │
│         │    ◄── push                       │
│         │    ◄── update PR description      │
│         │                                   │
│         └─ Re-enter loop ───────────────────┘
│                                             │
│  Bail after MAX_ATTEMPTS (3) ──► ask user   │
└─────────────────────────────────────────────┘
```

### Step 1: Poll CI Status

After each push, poll the CI status for the PR's HEAD commit. Use the
GitHub checks API or `wk:buildkite` depending on the project's CI system:

```bash
# GitHub Actions / generic checks
gh pr checks --watch --fail-fast

# Buildkite (if applicable)
# Use wk:buildkite to check build status
```

**Run watch commands in the background.** Any CI poll that may block for
more than ~30 seconds (`gh pr checks --watch`, `bk build watch`, similar
loops) MUST be issued as a backgrounded Bash tool call
(`run_in_background: true`). The orchestrator continues with other plan
steps — self-review preparation, docs audit, retro setup — in parallel.
The runtime sends a completion notification when the watch exits. Only
foreground a status check when the next step genuinely depends on the
result (e.g., immediately before `gh pr ready`). Do not stall the rest
of the workflow on a foregrounded watch.

### Step 2: Diagnose Failures

When CI fails:

1. **Read the actual logs** — invoke `wk:buildkite` for Buildkite projects
   or fetch GitHub Actions logs via `gh run view --log-failed`. Never guess
   at the cause
2. **Identify the root cause** — distinguish between:
   - **Code failures** — test failures, lint errors, type errors, build
     errors caused by the PR's changes
   - **Flaky tests** — failures unrelated to the PR (check if the same test
     fails on the base branch)
   - **Infrastructure issues** — timeout, OOM, runner unavailable, network
     errors
3. **For flaky tests**: re-trigger the build once. If it fails again on the
   same test, treat as a real failure
4. **For infrastructure issues**: re-trigger the build. If persistent, inform
   the user — do not attempt code fixes for infra problems

### Diagnosis discipline

Before generating fix candidates, cross-reference the failure surface
against the repo's own rulebook and runtime constraints. Most CI
failures are first violations of a standard the repo already documents.

**Cross-reference repo standards.** Re-read the repo's `CLAUDE.md`,
`AGENTS.md`, and any `docs/conventions/`-style files when the error
message contains any of these signals:

| Error signal | Rule to re-check |
|--------------|------------------|
| `no version is set`, `couldn't resolve latest`, `version not found`, `unknown tag` | Version-pinning rule (any `latest`/unpinned dep is suspect) |
| `auth failed`, `unauthorized`, `bad credentials`, `expired token` | Env-var / secrets provenance docs |
| `permission denied` on a script | File-permissions rule (`chmod +x` on executables) |
| `command not found` on a tool the project uses | Tool-version manifest (`mise.toml`, `.tool-versions`) |

If the error matches a rule the repo already states, the **first** fix
candidate must be "make the repo comply with its own rule" — not a
backend change, installer rewrite, or workaround.

**Respect runner constraints.** When the workflow uses an
organization-managed runner group (`runs-on: group: <org>-*-default` or
similar), assume the runner enforces an action allowlist and other
policy that's invisible from the workflow file alone. Before
introducing a new third-party GitHub Action on such a runner:

1. Prefer `actions/*` first-party actions, or any third-party action
   already used elsewhere in the same workflow set.
2. Prefer non-action approaches (curl install, package manager, mise)
   when a first-party action does not exist.
3. If a new third-party action is genuinely the right answer, ask the
   user before pushing: "Does `<action@SHA>` need allowlisting on the
   `<runner-group>` runner?" The round-trip cost of asking is much
   smaller than a blocked CI run + revert.

### Step 3: Fix and Re-push

For code failures:

1. **Fix the issue** — apply the minimal, targeted fix (see ordering below)
2. **Run tests locally** — verify the fix passes before pushing
3. **Commit via `wk:commit`** — one fix per commit, conventional format
4. **Push** — regular `git push`, never force-push
5. **Update PR description** — `gh pr edit` to reflect the fix
6. **Re-enter the loop** — go back to Step 1

#### Fix-candidate ordering

"Minimal" is not just smallest diff — it's smallest change to the part
of the system the user did not explicitly choose. Order candidates from
"smallest input change" to "largest stack change":

1. **Smallest version regression.** When a dependency upgrade is the
   proximate cause of the failure, try downgrading that dependency by
   one minor or patch version before changing build/install machinery,
   switching backends, or rewriting workflow steps. Two-version-down
   beats N-tool-changes-deep almost every time, and it preserves the
   rest of the user's setup. A version pin is also a smaller diff than
   a backend swap.
2. **Repo-rule compliance.** If Diagnosis discipline surfaced a violated
   repo rule (e.g., unpinned version), the fix is "comply with the
   rule" — usually a one-line config change.
3. **Same-tool config tweak.** Adjust the existing tool's config
   (`mise.toml`, `.lychee.toml`, `tsconfig.json`) before swapping the
   tool out.
4. **Same-tool backend/option change.** Switch backend, installer
   flag, or runner option within the user's chosen tool.
5. **Tool-stack change.** Removing or replacing a tool the user named.

**Coupled config travels with version changes.** When a fix changes a
tool's version (bump or downgrade), list the config files that tool
reads (`.lychee.toml`, `.rubocop.yml`, `tsconfig.json`, `mise.toml`,
package-manager lockfiles, etc.) and treat them as a coupled set. A
version change without a coupled-config check often produces a fix that
ships fine in isolation but breaks the next run. When **reverting** a
version, also revert any config changes that were made for the
abandoned version — unless the new syntax is forwards-compatible. A
one-line check ("did I change config files for this version?") at
version-revert time catches this; treat it as part of the fix, not as
follow-up work.

**Hard rule: do not bypass a user-named tool without explicit
confirmation.** When the user has explicitly named the tool stack they
want (`mise-action`, `actions/setup-node`, a specific package manager,
etc.), do not silently rewrite the workflow to skip that tool because
the obvious fixes proved hard. A property of a tool's behavior
("auto-install off", "no caching") is not the same as the tool itself
("mise", "setup-node"). Before any change at level 5 above, stop and
ask:

> "<Tool>'s <backend/config> is failing on <version>. Options:
> (a) downgrade <dep> to <prior-version>, (b) switch to <alternative
> backend within the same tool>, (c) drop <tool> from this workflow.
> Which do you want?"

Even in auto mode, removing a named tool from the user's stack is a
design decision that exceeds the autonomy budget — it is not "make
reasonable assumptions on routine work."

### Loop Limits

- **Maximum 3 fix attempts** per CI run. After 3 consecutive failures, stop
  and ask the user:
  > "CI has failed 3 times after fixes. Here's what I've tried:
  > 1. {fix 1 — what and why}
  > 2. {fix 2 — what and why}
  > 3. {fix 3 — what and why}
  >
  > The current failure is: {description}. How would you like to proceed?"
- **Do not loop indefinitely.** Three targeted attempts is enough to surface
  whether the issue is fixable by the agent or needs human judgment
- **Each attempt must be different.** Never retry the exact same fix. If
  the same failure persists after a fix, the diagnosis was wrong — re-read
  the logs and try a different approach
- **Axis-of-variation check before attempt 3.** Before pushing the third
  fix attempt, write a one-line restatement of the axis being varied
  (e.g., "I'm varying the install backend", "I'm varying the binary
  path"). If attempts 1 and 2 are on the same axis, **broaden** — try a
  different axis on attempt 3 (version regression, tool choice,
  dependency removal), not "the same thing harder." Different surface
  errors on the same axis are still the same axis. A genuinely
  different axis is the only thing that converts the 3-attempt limit
  into a useful bailout instead of three wasted CI runs.

### Exit Conditions

The loop exits when:

1. **All checks pass** — proceed to self-review and marking ready
2. **Max attempts reached** — hand off to user
3. **Infrastructure/flaky failure confirmed** — inform user, optionally
   re-trigger, do not block on it

After a green exit, resume the `wk:pr` post-creation workflow: self-review
(`wk:self-review`), automated feedback triage, and mark ready.

---

## Phase 7: Documentation Audit

Documentation is woven into every commit during Phase 2, but do a final audit
after all code is complete:

1. Invoke `wk:docs` for a full scan of affected documentation
2. Verify the README reflects any user-facing changes
3. Create or update ADRs for significant architectural decisions made
4. Update specs if behavior changed from what was originally specified
5. Ensure the `docs/` index (`docs/README.md`) is current
6. If the project has no `docs/` folder, `wk:docs` bootstraps one with:
   `plans/`, `specs/`, `adr/`, `tutorials/`, `examples/`

---

## Phase 8: Session Retro — NON-NEGOTIABLE

**At the end of EVERY session, invoke `wk:retro`.** No exceptions. This is
mandatory regardless of whether the task completed, partially completed,
failed, or was abandoned.

The retro:
- Reviews what happened across 5 lenses (mistakes, corrections, gaps,
  decisions, successes)
- Writes a dated entry to the global retro log
- Distills findings into actionable rules and promotes them globally to
  `~/.claude/memory/` so ALL future sessions benefit

There is no "the session was too short" or "nothing interesting happened."
Run the retro.

---

## Environment Guardrails

### AWS / ECR

When encountering `authorization failed`, `no basic auth credentials`,
`ExpiredToken`, or `Unable to locate credentials`: prompt the user to run
`aws sso login` to refresh credentials. Do not retry without valid creds.

### Docker

When encountering `Cannot connect to the Docker daemon`, `docker.sock: no
such file or directory`, or `Is the docker daemon running?`: prompt the user
to start Docker Desktop or Colima (`colima start`). Use `wk:docker` for
Docker-related work.

### Configuration

Always add permission rules, settings, and MCP servers to
`~/.claude/settings.json` (global), not `.claude/settings.local.json`
(project-scoped), unless intentionally local. For MCP servers, use
`--scope user`. Never add MCPs to `~/.claude.json` (the state file).

### CI Failures

Use `wk:buildkite` when investigating CI failures. Do not guess at CI
issues — read the actual logs.

---

## Skill Reference

All `wk:*` skills and when to invoke them during this workflow:

| Skill | When | Phase |
|-------|------|-------|
| `wk:commit` | After completing each implementation step; CI fix commits | 2, 6 |
| `wk:docs` | With each commit and during final audit | 2, 7 |
| `wk:pr` | When creating or updating a pull request | 5 |
| `wk:self-review` | Invoked automatically by `wk:pr` after CI passes | 5 |
| `wk:buildkite` | Diagnosing CI failures in the fix loop | 6 |
| `wk:pr-review` | When reviewing someone else's PR | — |
| `wk:pr-resolve` | When addressing review feedback on your PR | — |
| `wk:retro` | End of every session (mandatory) | 8 |
| `wk:docker` | When working with Docker/containers | any |
| `wk:datadog` | When managing observability resources | any |
| `wk:worktree-cleanup` | When cleaning up merged worktrees | any |

---

## Checklist

Use this as a final gate before claiming work is complete:

- [ ] Every commit is atomic and passes tests/CI independently
- [ ] Documentation updated alongside each code change
- [ ] Tests cover happy path, sad path, and edge cases
- [ ] Adversarial code review passed with no open issues
- [ ] CI fix loop exited green (all checks passing)
- [ ] PR description reflects current branch state
- [ ] Self-review posted highlighting critical changes only
- [ ] Version pins are exact (no `latest`, `^`, `~`)
- [ ] Scripts have correct file permissions
- [ ] Diagrams use Mermaid, not ASCII art
- [ ] Regex uses named capture groups
- [ ] ADRs created for significant architectural decisions
- [ ] Session retro completed via `wk:retro`
- [ ] Every numbered plan step is finished or explicitly deferred — not "most" or "the important ones"

---

## Post-Completion: Learning Capture

**After this skill finishes its primary work**, capture what happened
before returning control.

### Check environment

```bash
test -n "$WK_SKILLS_HOME" && echo "OK: $WK_SKILLS_HOME" || echo "MISSING"
```

If `$WK_SKILLS_HOME` is not set, ask the user:

> "`$WK_SKILLS_HOME` is not set. Please add
> `export WK_SKILLS_HOME=/path/to/skills` to your shell profile and
> restart your terminal."

**Stop here if the variable is missing.** Do not guess or use a fallback.

### Reflect

Review what happened during this skill's execution:

1. **What went wrong?** — Errors, wrong assumptions, user corrections,
   API failures, unexpected behavior
2. **What was missing?** — Steps the skill should have included, edge
   cases not covered, tools not available
3. **What worked well?** — Approaches that succeeded, patterns worth
   reinforcing
4. **What surprised you?** — Non-obvious discoveries that future runs
   should know about

If ALL lenses are empty (routine execution, nothing notable), **skip
writing** — not every run produces a learning.

### Write the learning

```bash
mkdir -p "$WK_SKILLS_HOME/learnings/skills/workflow"
```

Write to
`$WK_SKILLS_HOME/learnings/skills/workflow/<YYYY-MM-DD>_<learning-slug>.md`:

```markdown
---
skill: wk:workflow
date: <YYYY-MM-DD>
type: <correction | gap | pattern | surprise>
severity: <low | medium | high>
---

<One-line summary>

**What happened:** <What the skill did or failed to do>

**Root cause:** <Why — missing instruction, wrong assumption, edge case>

**Suggested fix:** <What should change in the skill to prevent this>
```

Use a 2-4 word kebab-case slug (e.g., `missing-null-check`,
`wrong-api-endpoint`, `good-parallel-pattern`).

### Signal for distillation

After writing, note:

> "📝 Learning captured: `workflow/<date>_<slug>.md` — distill with
> `wk:sharpen` when ready."

Learnings accumulate in `$WK_SKILLS_HOME/learnings/skills/` and are
batch-distilled into skill improvements via `wk:sharpen`.
