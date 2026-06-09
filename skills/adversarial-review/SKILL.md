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
  version: '2026.06.09-172926'
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
- For movement / refactor diffs, annotate each changed line as
  **net-new** vs **relocated** — a relocated line is identical to a line
  present at `$MERGE_BASE` (the move changed its location, not its
  content). This annotation gates the relocation-aware severity rule the
  subagent applies below.
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

**Claim-without-pinning-test check.** A comment can be accurate yet
unverified. For each `always` / `only` / `never` / `must` claim — and
especially type-coercion claims (JSON `false` vs string `"false"`,
Ruby truthiness, Go `nil` vs zero-value, JS `0`/`""`/`null`) — grep the
test suite for an `it` / `test` / `assert` block that exercises the
exact condition the comment asserts. If none exists, flag
`suggestion`: the invariant is correct today but silently brittle, and
a reviewer bot will request the pinning test.

**Warn-without-mechanism check.** When a doc, comment, or instruction
claims it will "warn", "notify", or "alert" the user, confirm an explicit
output step backs the claim. A parenthetical "(warn the user)" with no
imperative output block reads as optional and is routinely omitted at
runtime. Flag `suggestion`: convert the claim into an explicit output
instruction or a required step.

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

Structural-contract widening: refactors that swap a constrained
shape (positional array, `"k:v"` string list) for an open
merge / spread / dict-update against a structural container hand
collision safety to the caller. Grep the diff for the pattern:

```bash
git diff "$BASE...HEAD" \
  | grep -nE '\.merge\(|\.update\(|Object\.assign\(|\{\.\.\.|\*\*[a-z_]+\b|hash\[\s*[a-z_]+\s*\]\s*='
```

For each hit, verify the same commit adds an allowlist / reserved-
key constant / collision guard. Flag missing guards as
`suggestion`; promote to `blocker` when the container has named
fields the caller could shadow.

### 2.8 Cross-doc enumeration sync

Extract every new flag, symbol, error code, or test name from the diff.
Grep `docs/`, `README*`, in-code help strings, PR body. Every surface
that enumerates the set (counts, bullet lists, conflict matrices, format
lists) must match the new state. A mismatch caught locally is one
commit; deferred is a second cycle.

**Synonym + casing sweep for removed terms.** When the diff removes a
term (rule, flag, instruction name), an exact-string grep misses
semantically-equivalent restatements elsewhere. Before declaring the
sweep clear:

- Generate a variant set for the removed term — at minimum: original,
  Title Case, sentence case, lower case, `space-to-dash`, `dash-to-space`,
  and any alternate phrasing visible in adjacent docs (skim one
  neighbor doc for the concept's other names).
- Run one grep per variant. A single hit in any variant is a stale-doc
  blocker.
- Treat **spec tables** as first-class sweep targets — terms often
  appear as row labels (`| Clean-state output line | … |`) that prose
  greps miss. Grep table-row syntax explicitly:

  ```bash
  grep -rnE "^\|[^|]*<variant>[^|]*\|" docs/ 2>/dev/null
  ```

- Named sweep targets for removed-rule audits: `docs/specs/`, validator
  / linter skill files under `skills/*/`, plugin `README*` and
  `SKILL.md` files — these are the most common homes for enumerated
  rule lists.
- Treat a **rename** — even a behavior-preserving local-variable rename —
  as a removed-term change. Run the variant grep across source, `docs/`,
  **and test files** (test-function names, comments, error-label /
  message strings), not just prose. The change most likely to skip this
  sweep ("just a local rename") is exactly the one that leaves stale
  spec mapping/word-choice tables and test labels referencing the old
  name.

Test-count sync is mandatory: count test functions in changed
`*_spec.*` / `*.bats` / `*_test.*` files, grep specs for matching
count phrases (`"\d+ tests"`, `"covers \d+ scenarios"`), update every
mismatch in this branch.

Cross-module filter parity: when a metric, counter, or summary
purports to count artifacts produced by another module, grep that
producer for the filter it applies. Flag any divergence between the
metric's filter and the producer's filter as a data-model mismatch —
"what counts as an X" must be defined in one place, not implicitly
split across modules.

Unverified test-claim audit: spec prose stating "tests verify X",
"a test confirms X", "unit tests assert X", "spec asserts X" must
map to an actual test function exercising X. Grep spec docs for
these phrases and cross-check against the relevant test files. Flag
any unverified claim as a blocker (spec was written ahead of the
test — or the test was never added):

```bash
grep -rnE "tests? (verify|confirm|assert|ensure)|spec (asserts|verifies|confirms)" \
  docs/ README* 2>/dev/null
```

For each hit, locate the named test file and grep for a function
name or `it`/`test` description that matches the claimed behavior.

Universality-claim verification: spec prose stating that a value is
"common to every / tagged on all / present in every / applies to
every" subject is a **hidden enumeration** — count/bullet greps miss
it. Extract the subject noun, grep the diff for every instantiation
of that class/function, and verify the claimed field is passed at
every site:

```bash
grep -rnE "common to (every|all)|tagged on (every|all)|present in (every|all)|applies to (every|all)" \
  docs/ README* 2>/dev/null
```

Flag any call site that omits the claimed field as a blocker
(spec-vs-implementation divergence).

### 2.9 Design-pivot doc audit

If the diff touches `docs/specs/` or removes pseudocode/sequence blocks,
verify the corresponding `docs/plans/`, `docs/adr/`, and in-code comment
references are updated in the same branch. Logical-shape changes
(conditional became unconditional, abstraction layer lifted, interface
signature widened, state moved lifecycles) trigger this audit.

### 2.9.1 Multi-mode interface smell (spec/interface diffs)

When a spec/interface diff defines a struct/union/record whose fields are
read by multiple distinct modes or consumer families — each consuming only
a subset — flag it for review.

- Trigger: a type with ≥4 fields where prose or comments tie subsets of
  fields to different modes/consumers (judgment, not a pure grep).
- Failure mode: as modes grow, every consumer accretes nil-guards for
  inapplicable fields and compatibility stays implicit.
- Raise as `suggestion`: ask whether compatibility should be explicit —
  the consumer declares the fields it requires, or the producer declares
  which consumers it supports — rather than every consumer tolerating
  missing fields.

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
- Rename audit: enumerate every symbol (path, class, method, flag,
  command) deleted in `git diff "$BASE...HEAD" --diff-filter=D` and
  grep the PR body for each. Any hit is a blocker until the body is
  updated to the replacement text — rename commits update code but
  leave the PR body stale because body edits are not part of the
  file diff.
- Enumerated-rule scope audit: when a commit narrows or expands an
  enumerated set (banned items, allowed items, supported flags), extract
  the tokens removed from the set and grep the PR body for each. Confirm
  the body's prose description of the set matches HEAD's current set. A
  "restrict/narrow/relax X to only Y" commit updates the code and
  reference docs but leaves the body's enumeration stale — the rename
  audit misses it because the token is removed from a list inside a
  surviving file, not via `--diff-filter=D`.
- Rollout / operations section: when the diff touches production-
  facing surfaces (observability backend, deployment pipeline,
  schema migration, public API version path, monitoring, paging),
  require the PR body to carry a rollout / rollback / monitoring
  section. Trigger via a path-pattern grep, then check the body:

  ```bash
  PROD='datadog|metrics|telemetry|deploy|migration|schema|api[_/]v[0-9]+|observability|prometheus|grafana|pager|on[-_]?call'
  if git diff "$BASE...HEAD" --name-only | grep -iE "$PROD" > /dev/null; then
    gh pr view --json body --jq .body \
      | grep -iE 'rollout|rollback|operations|migration|monitoring|on[-_]?call|deploy plan' \
      || echo "BLOCKER: prod-facing diff missing rollout/ops section"
  fi
  ```

  `suggestion` for internal-only telemetry; `blocker` when the
  change affects customer-visible behavior or dashboards owned
  by another team.

### 2.11 External-call reproduction gate

If the diff modifies any request payload, header construction, or CLI
invocation against an external API (`curl`, `gh api`, HTTP client
calls), require either:

- A recorded local reproduction with the new payload returning success.
- Explicit user opt-out citing why local reproduction is infeasible
  (gated network, user-only credentials).

Unverified API-shape changes are a recurring source of follow-up PRs.

**Error-schema verification.** When the diff adds a check for an
error-carrying key against an external API response, verify the API's
actual error schema before clearing it. Asserting the wrong key (checking
`error` when the API returns `{"message": ...}`) silently skips both the
success and the failure branch — no output renders, and the failure looks
like a no-op.

```bash
git diff "$BASE...HEAD" | grep -nE '"(error|err|errors|message)"'
```

Each hit must be backed by the API's documented error shape or a recorded
error response — never an assumed key name.

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

**Multi-phase wiring check.** When a hook-config command's tag or name
declares it runs in more than one hook phase (dual-phase enforcement,
e.g. pre-commit *and* pre-push), verify the config actually wires every
claimed phase — not just the one the command was authored under:

- Confirm the shared definition is anchored (YAML `&anchor`) under the
  phase it is defined in.
- Confirm every other claimed phase references that anchor (`*anchor`)
  or repeats the command.
- Flag as `blocker` when a phase named in the tag has no corresponding
  entry — the command claims enforcement it never delivers.

### 2.15 Workstyle pass

Invoke `wk-workstyle check <path>` on every source file in the diff.
The pass runs in report-only mode during adversarial review — findings
are added to the verdict, not auto-fixed. Surface:

- Unnamed constants / magic numbers / magic strings.
- Nested ternaries.
- Undocumented public functions or methods added in the diff.
- Missing sad-path tests for new error-handling branches.
- Branch-vs-test enumeration for every new multi-branch function (>2
  return paths). A green suite does not imply full branch coverage — do
  the math explicitly: count the function's distinct `return` / exit
  paths, then count the named test cases that exercise it. Flag any
  return path with no covering test.
  - `blocker` when an uncovered path changes observable behavior
    (different value, error, side effect); `suggestion` when paths are
    behaviorally equivalent.
  - Detection: count `return`/`raise`/`throw` statements in the new
    function, then grep test files for test-name variants targeting that
    function (`Test<Name>_*`, `describe('<Name>'`, `it '<case>'`) and
    confirm the count covers each path.
- Untested nil/blank branch in presence-guarded builder methods. For any
  new method that can return nil via `.presence` (or an equivalent
  build-then-return-empty pattern like `if x.present? ; h[k]=x ; end ;
  h.presence`), grep the spec for a test that stubs the controlling field
  to nil/blank and asserts the method (or its caller) receives `nil`. Flag
  `suggestion` when absent — the nil return path is behaviorally
  significant and silently brittle without coverage.
- Temporal dependencies in new async code.
- Stale comments adjacent to modified code.
- Empty `catch`/`rescue`/`except` blocks.
- Inline test helpers duplicating production source. For each new
  `let`, `before`, fixture, factory, or shell heredoc that defines a
  multi-line callable in a spec/test file, grep the production source
  in the diff for a function of the same name or an identical /
  near-identical block (threshold: >3 identical non-trivial lines).
  Flag as `test-tautology` — stubs applied to the copied body never
  exercise the real code, so the test passes regardless of production
  drift. Fix: extract the production code to a requireable / sourceable
  module and load it from both the production caller and the test.
  - **Escalate to `blocker` when the duplicated function carries
    security-sensitive logic** — symlink-escape guard, path-traversal
    check, credential/secret redaction, auth or permission check. A
    patch to the production guard then leaves the test validating stale
    logic: the suite stays green while the real guard regresses.
    Detection: grep test files for function definitions (`<name>()`,
    `def <name>`, heredoc-defined functions) whose name also appears in
    the diff's production source, then classify each duplicated body for
    security-sensitive operations.
- Bugfix-without-regression-test. For every commit whose subject
  matches `^(fix|bugfix|bug)[:(]`, enumerate the commit's changed
  files. If the source-side files changed without a paired
  test-side file in the **same commit**, flag the gap. Without a
  spec asserting the post-fix behavior, a future refactor can
  silently revert the fix:

  ```bash
  for sha in $(git log --format=%H "$BASE..HEAD" --grep='^fix\|^bugfix\|^bug:'); do
    src=$(git show --name-only --pretty=format: "$sha" | grep -vE '^(spec|test|tests)/')
    tst=$(git show --name-only --pretty=format: "$sha" | grep -E '^(spec|test|tests)/')
    [ -n "$src" ] && [ -z "$tst" ] && echo "BLOCKER: $sha changes source without test"
  done
  ```

  `suggestion` when the fix is a one-line defensive coercion and
  the existing spec has parallel structure; `blocker` when the fix
  introduces a new branch.

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

### 2.19a Struct/Record field-extension contract test

When the diff adds a field to a Struct/Record type — `Struct.new(...)`,
`@dataclass`, `attr_reader :foo` / `attr_accessor`, `field :foo`,
named tuple, TypeScript `interface` member, Go struct field, equivalent
in any language — require a direct assertion test on the new field's
concrete value. Transitive coverage through behavior tests passes today
but silently allows a future refactor to drop or mis-populate the
field.

- Grep the diff for added field names inside Struct/Record-extension
  patterns. Build the set of `(type, new-field)` pairs.
- For each pair, grep test/spec files for
  `expect(<instance>.<field>).to eq(...)` /
  `assert <instance>.<field> ==` / `expect(x.<field>).toBe(...)` /
  language-equivalent assertion.
- Flag as `blocker` when no direct assertion exists on the new field
  (a `respond_to?` / type check alone does not count — assert the
  value, not the presence).
- Pairs with sweep 2.7 (signature widening) — 2.7 covers function-
  parameter additions, 2.19a covers data-shape additions.

### 2.20 Env-var pipeline forwarding sweep

New env reads in application code that the CI pipeline never forwards
into the container produce **silent runtime null-reads** — build green,
feature never fires. Sibling to 2.7 (signature widening) but the caller
lives in YAML/DSL, not source. Code-to-pipeline interface drift is
invisible at every individual layer (secret set, agent dump shows it,
code reads with default) and breaks only at the agent→container
boundary.

Run unconditionally on every diff that touches application code in a
project with a CI pipeline.

1. Extract net-new env reads from the diff. Multi-language coverage:

   ```bash
   git diff "$BASE...HEAD" \
     | grep -nE '^\+.*(ENV\.fetch\(|ENV\[|os\.environ|os\.getenv|process\.env\.|os\.Getenv\()[ "'\''[\.]([A-Z][A-Z0-9_]+)' \
     | grep -oE '[A-Z][A-Z0-9_]{3,}' | sort -u
   ```

   Covers Ruby (`ENV.fetch`, `ENV[...]`), Python (`os.environ`,
   `os.getenv`), JS/TS (`process.env.X`), Go (`os.Getenv`), shell
   (`${X}` paired with a new export or `[ -z "${X:-}" ]` guard).

2. For each var, locate the entry-point script that reads it — grep
   `bin/`, `cmd/`, `scripts/`, `lib/`, `src/`.
3. For each entry-point script, locate the pipeline template / CI step
   that invokes it — grep `.buildkite/`, `.github/workflows/`,
   `.circleci/`, `azure-pipelines*`, `gitlab-ci*` for the script name.
4. For each invoking step, verify the var name appears in the step's
   env allowlist. Allowlist location varies:

   | Platform | Allowlist location |
   |---|---|
   | Buildkite + docker_compose plugin | plugin step's `env: [...]` array |
   | Buildkite native step | step `env:` block |
   | GitHub Actions | step or workflow `env:`; `secrets:` for reusable workflows |
   | docker-compose direct | `services.<svc>.environment:` |
   | Dockerfile runtime default | `ENV` |

5. Missing forwarding is a **blocker** — the symptom only surfaces when
   the feature is expected to fire (runtime null-read + default
   fallback). Build stays green.
6. Exempt env names matching the platform's auto-injection prefix
   (e.g., `BUILDKITE_*`, `GITHUB_*`, `CI_*`) — no explicit forwarding
   required.

One-liner detection sketch:

```bash
for V in $(git diff "$BASE...HEAD" | grep -nE '^\+.*(ENV\.fetch|ENV\[|os\.environ|os\.getenv|process\.env\.)[ "'\''[\.]([A-Z][A-Z0-9_]+)' | grep -oE '[A-Z][A-Z0-9_]{3,}' | sort -u); do
  for SCRIPT in $(grep -rl "$V" bin/ scripts/ src/ lib/ 2>/dev/null); do
    grep -rl "$(basename "$SCRIPT")" .buildkite/ .github/workflows/ 2>/dev/null | while read TEMPLATE; do
      grep -q "\"$V\"\|'$V'" "$TEMPLATE" || echo "BLOCKER: $V read by $SCRIPT but not forwarded in $TEMPLATE"
    done
  done
done
```

### 2.19 Tautological test assertion scan

Self-referential equality assertions pass regardless of behavior — both
sides derive from the same source, so the test would still pass if the
production code were inverted, deleted, or replaced with a no-op.

- Grep new and modified test/spec files for equality forms where both
  operands reference the same variable(s):

  ```bash
  grep -nE 'eq\(.*\.sort\)|expect\(([a-zA-Z_]+)\)\.to eq\(\1\)|assert.*==.*\.sort\b' \
    <(git diff "$BASE...HEAD" -- 'spec/**' 'test/**' '**/*.test.*' '**/*.spec.*')
  ```

- Generalize the pattern: any `expect(x).to eq(x[.method])` form, any
  `assertEqual(x, x.method())` form, any `expect(arr).toEqual(arr.sort())`
  form, any comparison where both sides reference the same variable
  passed through a transform.
- Blocker — the test provides zero coverage of the function under test.
- Fix: construct the expected value independently of the input (literal
  array, hand-written sequence, or a known-good fixture).

### 2.21 Numeric security-gate bounds sweep

A numeric config field that gates a security control (approval
threshold, LOC ceiling, rate limit, retry cap) with no upper bound lets
an operator set it arbitrarily high and bypass the gate entirely
(e.g., `max-lines: 999999` defeats a LOC-based approval gate).

- Grep the diff for new numeric config identifiers: `Max`, `Limit`,
  `Cap`, `Threshold`, `MaxLines`, `min`, `ceiling` introduced in a
  config struct, schema, or YAML key.
- For each, trace the consuming path and verify both: (a) a lower-bound
  check (positive integer), and (b) a hard ceiling constant enforced
  before the value gates the control.
- Missing ceiling on a security-gating field is a `blocker`; missing
  bound on a non-gating tunable is a `suggestion`.

### 2.22 Pass-through wiring integration test

When the diff changes a script or entrypoint to forward a new value
from a structured artifact to a downstream call
(`findings["x"]` → `run(param: findings["x"])`), unit tests on each end
(serialization at the source, behavior at the sink) do not cover the
wire itself — the key lookup and forward.

- Detect the pattern: a new `<collection>["<key>"]` or `.get(<key>)`
  read feeding a new argument to a downstream function/command in a
  script or entrypoint.
- Verify an integration/end-to-end test constructs a fixture with the
  key set and asserts the downstream behavior fires.
- Flag `suggestion` when both unit ends are covered but the wire is
  not; the forwarding line is new code and needs its own coverage.

### 2.23 Seed-before-empty-collapse sweep

A collection seeded or prepended with a non-empty value **before** an
emptiness guard that collapses to a compact / "nothing to show" form
silently defeats the guard. The seed alone makes the guard evaluate
false, so the full template renders carrying only the decorative seed
and no substantive content — the exact case the compact form existed to
handle.

- Grep the diff for a seed/prepend into a collection near an emptiness
  collapse on that same collection:

  ```bash
  git diff "$BASE...HEAD" \
    | grep -nE 'unshift|prepend|\.insert\(0,|^\+.*=\s*\[[^]]+\]\s*\+|\.all\?\s*\{.*empty\?|\.none\?|\.empty\?|\.blank\?'
  ```

- For each candidate, trace the path where no substantive content
  exists. Verify the guard decides on **substantive content only** —
  the seed / decoration must be added *after* the gate, not before it.
- Flag as `blocker` when the seed can drive a "no substantive content"
  path into rendering the full form instead of the compact one.

### 2.24 Argument-injection / missing `--` separator sweep

An external command invoked with a variable / array / glob expansion of
attacker-influenceable names, with no `--` option terminator before the
positional args, is an argument-injection (RCE) path: a basename like
`-I.jsonl` or `--use-compress-program=evil` is parsed as an option, not
a file. A realpath / symlink guard does **not** catch this — it
validates the path, not the basename's option-likeness.

- Grep the diff for option-parsing commands fed expanded names with no
  `--` terminator:

  ```bash
  git diff "$BASE...HEAD" \
    | grep -nE '\b(tar|rm|cp|mv|grep|chmod|chown|git|curl)\b[^|]*("\$\{[a-z_]+\[@\]|/\*)' \
    | grep -v ' -- '
  ```

- For each hit, trace whether the expanded values originate from an
  untrusted source (sandbox-writable dir, user upload, API payload).
- Flag as `blocker` when the source is untrusted and no `--` precedes
  the positional args; fix by inserting `--` before them.

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
- **Relocation-aware.** Before rating any finding a `blocker` in a
  movement-dominated diff, check whether the flagged line existed
  verbatim at `$MERGE_BASE`. A pre-existing issue carried unchanged by a
  pure move was accepted before this branch — downgrade it to
  `suggestion` or skip it. Do not bill the refactor for inherited debt.

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
| Test quality | Tautological tests, missing assertions, no failure path, no test for new function, **asymmetric coverage** of fields populated on both pass and fail return paths (assert the field's value on at least one example of each path) |
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
- Emit a `session_resolved_classes` set in the verdict — one entry
  per finding addressed this session, keyed by `(path_prefix,
  concern_class)`. Callers match incoming bot threads against this
  set by concern class **before** matching by exact `path:line`,
  tagging matches as `already-addressed` and skipping triage. Bots
  that re-evaluate from a stale post-push snapshot otherwise echo
  every prior finding as new.

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
