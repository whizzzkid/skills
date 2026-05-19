---
name: wk-adversarial-review
description: >-
  Adversarial pre-flight review of the current branch before anything leaves the
  machine. Activates whenever the agent is about to push, mark a PR ready, or
  introduce new commits onto an existing PR. Spawns a fresh critique agent that
  treats the diff as a stranger's code, runs mechanical pre-push checks
  distilled from past reviewer/bot findings, validates assumptions in a
  playground, and refuses to clear the branch until every blocker is resolved.
  Auto-invoked from wk-workflow Phase 4, wk-pr before draft creation or push,
  and wk-pr-resolve before Step 8 push. No code, no commit, no PR transition
  leaves the machine without passing this skill.
argument-hint: '[optional: explicit base branch]'
allowed-tools:
  - "Bash(gh pr view:*)"
  - "Bash(gh pr diff:*)"
  - "Bash(gh pr list:*)"
  - "Bash(gh api repos:*)"
  - "Bash(gh api graphql:*)"
  - "Bash(git diff:*)"
  - "Bash(git log:*)"
  - "Bash(git status:*)"
  - "Bash(git merge-base:*)"
  - "Bash(git rev-parse:*)"
  - "Bash(git symbolic-ref:*)"
  - "Bash(git fetch:*)"
  - "Bash(grep:*)"
  - "Bash(rg:*)"
  - "Bash(awk:*)"
  - "Bash(sed:*)"
  - "Bash(find:*)"
  - Read
  - Grep
  - Glob
  - AskUserQuestion
  - Agent
model: opus
effort: high
model-invocable: true
user-invocable: true
license: MIT
group: pull-request
metadata:
  author: whizzzkid
  version: '2026.05.19-172503'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Adversarial Review

Pre-flight critique of the current branch. Catches the classes of issues
reviewers and bots historically flag, so the PR does not need a second cycle.

```
Resolve base -> Enumerate surface -> Mechanical sweeps
  -> Adversarial subagent -> Playground validation
  -> Verdict (clear / blockers) -> Fix loop -> Re-review
```

## Mandatory Activation

**This skill fires before any artifact leaves the machine:**

- Before the first push of a branch (`wk-workflow` Phase 4 -> here).
- Before `gh pr ready` flips a draft to ready (`wk-pr` Step 5 -> here).
- Before every subsequent push that introduces new code or doc changes on
  an existing PR (`wk-pr-resolve` Step 8, `wk-pr` re-runs).
- Before any force-push or rebase that rewrites pushed history.

**There is no opt-out.** "Small fix", "trivial", "just a comment tweak",
"only docs" are red flags, not exemptions. A docs-only commit can still
contradict an enumerated test count in a spec; run the skill anyway.

The skill is **idempotent within a session** — if no new commits have
landed since the last clear verdict, re-invocation is a no-op that
prints the prior verdict.

## Style Rules

- **Bullets, imperative voice.** Each rule is a verb the agent executes.
- **Mechanical first.** Greps and command audits run before any LLM reasoning.
- **Block before negotiate.** Blockers stop the push; severity downgrades
  require explicit user confirmation, not agent judgment.
- **Reproduce before claim.** Every finding that asserts runtime behavior
  must be reproduced in `.review-playground/` or rejected.

---

## Step 0: Resolve Context

Compute the inputs every later step needs. Hardcoding `main` is forbidden —
stacked PRs have non-default bases and the skill must work on them.

```bash
DEFAULT=$(git symbolic-ref refs/remotes/origin/HEAD --short 2>/dev/null \
          | sed 's@^origin/@@')
DEFAULT=${DEFAULT:-main}

PR_NUM=$(gh pr view --json number --jq .number 2>/dev/null || echo "")
if [ -n "$PR_NUM" ]; then
  BASE=$(gh pr view "$PR_NUM" --json baseRefName --jq .baseRefName)
else
  BASE="$DEFAULT"
fi

git fetch origin "$BASE" --quiet
MERGE_BASE=$(git merge-base HEAD "origin/$BASE")
```

`$BASE` is authoritative for every later diff command in this skill.

Refuse to proceed if `git status --short` shows uncommitted changes —
the diff sweeps must reflect the same tree that will leave the machine.

---

## Step 1: Enumerate Diff Surface

Build a structured map of what the branch changes. This map drives the
adversarial subagent's targets and the mechanical sweeps.

```bash
git diff "$BASE...HEAD" --stat
git diff "$BASE...HEAD" --name-status
git log "$BASE..HEAD" --oneline
```

For every changed file, extract:

- New / modified functions, methods, classes — `{name, file, line, signature}`.
- New / modified CLI flags, env vars, public API entries.
- New / modified test functions and fixture files.
- Removed lines (refactor delta — track separately; refactors must preserve
  behavior).
- Touched documentation paths (`docs/`, `README*`, in-code help strings).

Annotate the map with kind (`feature`, `bugfix`, `refactor`, `docs`,
`infra`) — kind biases which categories the subagent prioritises.

---

## Step 2: Mechanical Sweeps (run unconditionally)

Greps and command audits that catch known classes mechanically. Each sweep
is cheap; run all of them before invoking the adversarial agent.

### 2.1 Vulnerability-class sweep

For every fix in the diff, grep the **full diff** for the same pattern
class. Fixes applied to one site, with siblings left broken, are the
single highest-frequency reviewer flag.

- Credential / token / secret in `stderr|2>&1|>&2|cat.*ERR`.
- Null / sentinel guard added on one branch — every sibling branch.
- Input validation added at one entry point — every other entry point.

```bash
git diff "$BASE...HEAD" | grep -nE 'redact|mask|sanitize|escape|sanitis'
```

Every hit must be addressed or explicitly excluded in the verdict.

### 2.2 Sibling-script audit

For each changed `*.sh` / module / parallel-pipeline file, list its
directory siblings and grep them for the analogous code path. Each
sibling must be (a) already correct, (b) absent of the path, or
(c) also fixed in this branch.

```bash
for f in $(git diff "$BASE...HEAD" --name-only | grep -E '\.(sh|bash|py|rb|ts|js)$'); do
  dir=$(dirname "$f")
  find "$dir" -maxdepth 1 -type f
done | sort -u
```

### 2.3 Reachability trace on new guards

For each `if x == "X"`, `if x is None`, null-check, or defensive branch
added in the diff, trace upstream transforms (jq filters, trim, decode,
type coercion). If an upstream transform already eliminates the
sentinel, the guard is dead code. Flag the dead-code path **and** any
test fixture that simulates the impossible producer output.

### 2.4 Comment accuracy pass

Grep added or modified comments for two parallel classes:

- **Assertive behavioral claims:** `always`, `guaranteed`, `never`,
  `available`, `works`, `cannot`, `must`.
- **Descriptive intent phrases:** `treat .* as`, `interpret .* as`,
  `use .* to match`, `equivalent to`, `mirrors`, `behaves like`.

Mentally execute each claim against the current implementation. For
intent phrases, verify the described behavior still appears in the
same function body — refactors often remove the behavior but leave
the comment. Update or delete the comment if false; stale comments
asserting old behavior or describing removed intent are a top-3
reviewer flag.

### 2.5 Hardcoded base / branch sweep

```bash
git diff "$BASE...HEAD" | grep -nE '\bmain\.\.\.HEAD\b|origin/main\b|\bmaster\.\.\.HEAD\b'
```

Every hit must use the dynamic-base resolver (`gh pr view --json baseRefName`).

### 2.6 Version-pin sweep

```bash
git diff "$BASE...HEAD" -- 'Dockerfile*' '.tool-versions' 'mise.toml' \
  | grep -nE ':latest|:stable|:nightly|=[^"]*latest|^\+\s*[a-z]+\s*=\s*"latest"'
```

Every hit must be replaced with an exact pin. Apply the same rule to
GitHub Actions versions in `.github/workflows/*.yml`.

### 2.7 Signature widening pre-flight

For each function whose signature changed (added required param, added
required struct field, removed param, changed type), grep **every**
caller and initializer in the repo. Each call site must be updated in
the same branch or wrapped by a defaulted helper.

```bash
grep -rn '<FunctionName>(' src/ tests/
grep -rn '<TypeName>\s*{' src/ tests/
```

### 2.8 Cross-doc enumeration sync

Extract every new flag, symbol, error code, or test name from the diff.
Grep `docs/`, `README*`, in-code help strings, PR body. Every surface
that enumerates the set (counts, bullet lists, conflict matrices, format
lists) must match the new state. A mismatch caught locally is one
commit; deferred is a second cycle.

Test-count sync is mandatory: count test functions in changed
`*_spec.*` / `*.bats` / `*_test.*` files, grep specs for matching
count phrases (`"\d+ tests"`, `"covers \d+ scenarios"`), update every
mismatch in this branch.

### 2.9 Design-pivot doc audit

If the diff touches `docs/specs/` or removes pseudocode/sequence blocks,
verify the corresponding `docs/plans/`, `docs/adr/`, and in-code comment
references are updated in the same branch. Logical-shape changes
(conditional became unconditional, abstraction layer lifted, interface
signature widened, state moved lifecycles) trigger this audit.

### 2.10 PR metadata sync

If a PR exists for the branch:

- Fetch title and body (`gh pr view --json title,body`).
- Verify title still describes the behavior (verb matches —
  `allowlist` vs `denylist`, `enable` vs `disable`).
- Verify body's test counts, file lists, "remaining work" sections
  match HEAD.
- Verify metadata lines survive any planned body rewrite
  (`Closes #N`, `Co-authored-by:`, `**Build:**`, `<details>Prompt</details>`).
- Verify Jira key suffix `[BOARD-NUM]` is present when a Jira key is
  detectable from branch name or any commit message.

### 2.11 External-call reproduction gate

If the diff modifies any request payload, header construction, or CLI
invocation against an external API (`curl`, `gh api`, HTTP client
calls), require either:

- A recorded local reproduction with the new payload returning success.
- Explicit user opt-out citing why local reproduction is infeasible
  (gated network, user-only credentials).

Unverified API-shape changes are a recurring source of follow-up PRs.

### 2.12 Self-review surface check

If a prior self-review exists on the PR, fetch its threads. Any new
self-review comment that duplicates earlier rationale must be dropped
or rewritten as a cross-reference. Any thread whose rationale describes
a now-superseded approach must be resolved by the author before push.

### 2.13 Raw-API bypass detection

```bash
git diff "$BASE...HEAD" | grep -nE 'gh api .*/pulls/[0-9]+/comments\b'
```

Any direct comment-posting call that bypasses the pending-review flow is
a blocker — publishing review feedback outside the pending-review API
skips the human checkpoint.

### 2.14 Pre-push gate compliance

Inspect the repo's pre-push hook config (`.lefthook.yml`,
`.husky/pre-push`, `.git/hooks/pre-push`, `bin/ci`). Enumerate every
gate the hook runs. Confirm each has been run locally against the
current HEAD. Passing one suite does not imply the others pass.

### 2.15 Workstyle pass

Invoke `wk-workstyle check <path>` on every source file in the diff.
The pass runs in report-only mode during adversarial review — findings
are added to the verdict, not auto-fixed. Surface:

- Unnamed constants / magic numbers / magic strings.
- Nested ternaries.
- Undocumented public functions or methods added in the diff.
- Missing sad-path tests for new error-handling branches.
- Temporal dependencies in new async code.
- Stale comments adjacent to modified code.
- Empty `catch`/`rescue`/`except` blocks.

Project config is authoritative — suppress any finding that contradicts
an active linter config.

### 2.16 Plugin install portability

When the diff includes a `SKILL.md` or `.claude-plugin/plugin.json`,
scan the SKILL.md body for path references that resolve only in the
publishing repo.

- Flag `Read("skills/.../*.md")`, `cat skills/...`, or any relative
  path rooted at the publishing-repo layout. Paths that work in the
  authoring repo fail silently when the plugin is installed in a
  consumer repo.
- Require one of: a `${CLAUDE_PLUGIN_ROOT}/`-prefixed path, an inline
  fallback (the content embedded in SKILL.md), or a `WebFetch` of a
  pinned upstream URL.
- Blocker until resolved — install-time portability failures are
  invisible to the authoring repo's own CI and only surface in the
  consumer's session.

### 2.17 Dynamic-language call/definition cross-check

For dynamic-language source files in the diff (Ruby, Python, JS/TS,
Elixir, etc.), the compiler cannot catch a deleted helper whose callers
survive. Conflict-resolution merges and inline-refactor commits both
hit this. Tests fail at runtime; the file still loads.

- For each method call added or kept in the diff (`<name>(`, `.<name>`),
  grep the file and the module for a matching definition:

  ```bash
  grep -nE 'def +<name>\b|function +<name>\b|<name> *=' <file>
  ```

- Flag any call whose definition is absent from the file, module, or
  imported namespace.
- Pairs with sweep 2.7 (signature widening) — 2.7 covers added params,
  2.17 covers removed definitions still called.

### 2.18 Removed-constant magic-string scan

When a named constant is removed in the diff, its literal value often
gets inlined at multiple call-sites — re-introducing the duplication
the constant existed to prevent.

- For each removed `const X = "..."` / `X = "..."` / `<X> = "..."` (any
  language), grep the post-rebase diff for the literal value:

  ```bash
  git diff "$BASE...HEAD" | grep -nF '<literal-value>'
  ```

- Flag as `suggestion` (not blocker) when the literal appears at 2+
  non-comment sites. Recommend extracting a helper or restoring the
  named constant.

---

## Step 3: Spawn Adversarial Subagent

After mechanical sweeps land their findings, dispatch a fresh subagent
with no prior context to critique the diff. The subagent operates only
on `git diff "$BASE...HEAD"` and the surface map from Step 1.

The subagent must be:

- **Adversarial.** Actively hunt bugs, security issues, design flaws.
- **Unbiased.** Treat the diff as a stranger's code.
- **Critical.** Flag real problems, not style preferences.
- **Objective.** Judge against the diff, not assumed intent.
- **Naming-aware.** Vague names (`data`, `temp`, `result`), inconsistent
  casing, misleading names, names diverging from surrounding style.
- **Diff-sensitive.** Stricter on net-new code and public API surfaces.
- **Refactor-aware.** For movement-dominated diffs, demand a
  removed-line audit — every removed line must have a corresponding
  relocated line or an explicit "intentionally dropped" rationale.

### Categories to hunt

| Category | Example failure modes |
|----------|----------------------|
| Logic / arithmetic | Off-by-one, first/last/one-past-end, pagination edges |
| Type coercion | `"0"` vs `0` vs `false`, `[]` vs `{}`, semantic-violation values |
| State / ordering | Use-before-init, use-after-close, double-init, async interleaving |
| Concurrency | Races, lock asymmetry, shared-state parallel callers |
| Contract changes | Modified signatures — consumer sweep, old-shape→new-code and new-shape→old-consumer |
| Cross-system flow | Producer layout ≠ consumer scan, recursion depth mismatch, destructive cleanup before verify |
| Runtime portability | bash 3.2 vs 4+, `mapfile`, `declare -A`; Python/Node/Ruby matrix from `.tool-versions` |
| Refactor-removed behavior | Validation / recursion / error handling silently dropped during port |
| Test quality | Tautological tests, missing assertions, no failure path, no test for new function |
| Security | Injection, secret leakage in stderr/logs, redaction gaps, traversal |
| Data loss | Unprotected writes, race-prone cleanups, missing rollback |
| Error handling | Swallowed errors, generic catches, wrong error class |
| Performance | Quadratic scans on hot paths, missing indexes, repeated I/O |

### Findings format

Each finding emitted by the subagent must be:

```
severity:   blocker | suggestion | question
file:       path
line:       N (must exist in the diff's commentable set)
category:   one of the above
finding:    one sentence
rationale:  one to three sentences, citing the exact diff lines
fix-sketch: concrete code or command, not narrative
```

- `blocker` is reserved for correctness, security, data loss, or a
  documented HARD RULE violation. Style and naming default to
  `suggestion`. Genuine uncertainty is `question`.
- Hedging, filler, praise inline are forbidden. Restating the diff is
  forbidden.

---

## Step 4: Playground Validation

Every finding that asserts runtime behavior — "this races", "this
mutates", "this regex misses X", "this script doesn't run under bash
3.2" — must be reproduced before clearing or escalating.

- Create `.review-playground/` (gitignored). Writes from this skill
  are confined to that directory.
- **HARD RULE — never commit the gitignore entry.** `.review-playground/`
  is a local, ephemeral scratch dir. Keep it in `~/.gitignore_global`
  or rely on the user's per-repo opt-in. Never `git add .gitignore`
  to introduce a `.review-playground/` line on the branch under
  review — skill scratch dirs are not repo state.
- One script per finding. Drive with the runtime the production code
  uses. If the project supports a matrix, run each interpreter — do
  not silently skip uninstalled runtimes; flag the gap.
- Mutation test for each new test in the diff: flip a conditional,
  hardcode a return, swap arg order, remove an assertion, re-run.
  If green, the test is fake — `blocker`.
- Standalone playground when the app cannot boot (broken bundle,
  missing DB): fetch upstream framework source via
  `gh api repos/{owner}/{repo}/contents/{path}?ref={tag}` and
  replicate the method signatures verbatim. Cite the upstream SHA.
- Cross-system layout repro: when the diff changes a
  producer/consumer pairing, populate a staging dir with the real
  producer layout and run the consumer end-to-end.

Findings that cannot be reproduced are downgraded from `blocker` to
`question` with the reproduction gap recorded.

---

## Step 5: Verdict

Aggregate mechanical-sweep findings and subagent findings. Deduplicate
by `(file, line, category)`.

- **Clear:** zero blockers, zero unverified high-confidence runtime
  claims. Print a one-line clear verdict citing the commit range and
  HEAD SHA. The caller (`wk-workflow`, `wk-pr`, `wk-pr-resolve`)
  proceeds with its next step.
- **Blocked:** any blocker. Print the blocker list with file:line,
  category, and fix sketch. Refuse to clear. The caller MUST loop back
  to Phase 2 (Implement) to fix each blocker before re-invoking this
  skill. Auto mode does not bypass this — pushing past a blocker is a
  workflow violation.
- **Suggestions only:** print the suggestion list, present an
  AskUserQuestion offering:
  - **A)** Fix all suggestions in-line, then re-review (recommended
    when count <= 3 and changes are mechanical).
  - **B)** Clear with suggestions noted as TODO comments / follow-up.
  - **C)** Defer all suggestions to a tracked ticket.

  Default to **A** in auto mode if every suggestion has a concrete
  fix-sketch under 10 lines; otherwise default to **B**.

### Note bot reviewers in the verdict

When the pre-push comment map contains bot reviewers (login matches
`*[bot]`), append to the verdict body:

- Post-push thread count may shrink — bots that recreate their entire
  review object on each push retract pre-push threads and may post a
  single replacement before their database catches up with HEAD.
- The caller MUST re-fetch threads after push (`wk-pr-resolve` Step 8.x
  refresh) and match findings by `(path, line, body_excerpt)`, not by
  REST comment ID.
- A reduced thread count is expected, not a regression signal.

### Clearance record

On a clear verdict, write `.review-playground/.cleared-{HEAD_SHA}.json`
recording: HEAD SHA, base, timestamp, finding counts, verdict. The
file lets the orchestrator skip re-invocation when no new commits land.

---

## Step 6: Fix Loop

On a blocked verdict:

1. Caller addresses each blocker, committing each fix individually
   via `wk-commit` (one fix per commit, atomic, conventional format).
2. Re-invoke `wk-adversarial-review`. The skill re-runs Steps 1–5
   against the new HEAD.
3. Loop until clear, max 3 cycles. After 3 cycles, stop and surface to
   the user — repeated blocker recurrence on the same axis means the
   diagnosis or design is off, not the fix.

---

## Step 7: Hand Back

Print the verdict line to the caller. Do not push, do not edit the PR,
do not post review comments — those actions belong to the calling
skill, not this one. This skill is a **gate**, not an actor.

---

## Hard Rules

1. **No push without clear verdict.** Every push, every `gh pr ready`,
   every force-push runs this skill first. Auto mode does not bypass.
2. **Mechanical sweeps run unconditionally.** Even on docs-only diffs.
   Test-count sync and cross-doc enumeration land most often there.
3. **Findings are diff-anchored.** Every comment must map to a line in
   the commentable set. Lines outside the diff become file-level or
   verdict-body notes — never silently dropped.
4. **Reproduce before claim.** Runtime-behavior findings must be
   exercised in `.review-playground/` or downgraded.
5. **No raw `gh api .../comments` from this skill.** Verdict output is
   text only — the caller decides what becomes a PR comment.
6. **Refactors get the removed-line audit.** When the diff is dominated
   by movement, every removed line must be accounted for.
7. **Severity ladder is non-negotiable.** `blocker` for
   correctness/security/data-loss/HARD-RULE violations only. Naming
   and style default to `suggestion`.

---

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| `wk-workflow` Phase 4 | Full flow on current branch before PR creation |
| `wk-pr` before first push | Full flow; blocks `gh pr create` on blockers |
| `wk-pr` before `gh pr ready` | Full flow against PR HEAD; blocks ready transition |
| `wk-pr-resolve` before Step 8 push | Full flow against new commits since last clear |
| User `/wk-adversarial-review` | Manual run on current branch |
| Re-invocation on same HEAD | No-op; prints prior clearance record |

## Requirements

- `gh` CLI authenticated.
- Repo with a base branch resolvable via `gh pr view` or
  `git symbolic-ref refs/remotes/origin/HEAD`.
- Write access to `.review-playground/` (gitignored).
- For matrix runtime checks: every interpreter in `.tool-versions` /
  CI matrix installed via `mise` or equivalent.

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn adversarial-review`).
