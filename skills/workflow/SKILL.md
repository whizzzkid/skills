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
  version: '2026.06.06-002242'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Workflow

Master orchestration for all development tasks. Every `wk-*` skill is invoked
from within this workflow at the prescribed point. Follow this sequence exactly.

```
Plan -> Implement (commit per step + docs) -> Test (happy/sad/edge)
  -> Refactor-Opportunity Scan -> Review (adversarial agent)
  -> PR (wk-pr) -> CI Fix Loop -> Self-Review -> Docs Audit -> Retro
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
| Ready to commit | Invoke `wk-commit` | Ask "shall I commit?" |
| Tests pass, review clean | Invoke `wk-pr` | Ask "would you like a PR?" |
| CI fails | Enter fix loop automatically | Ask "should I investigate?" |
| Adversarial review blocks | Fix blockers, re-invoke `wk-adversarial-review` | Ask "should I fix these?" |
| Docs need updating | Invoke `wk-docs` | Ask "should I update docs?" |
| Session ending | Invoke `wk-retro` | Ask "should I do a retro?" |

**Only stop and ask the user when:**
- The plan is ambiguous and multiple valid approaches exist
- A CI failure persists after 3 fix attempts
- A code review finding requires a design decision (not just a fix)
- The user explicitly said to pause or check in at a specific point
- Destructive or shared-state actions (force push, production deploy)

**Skill invocation is mandatory.** When this workflow says "invoke
`wk-commit`" or "invoke `wk-pr`", the agent MUST use the Skill tool to
call the skill — not approximate the behavior by running raw commands.
The skills contain rules, guards, and conventions that raw commands skip.

**Run the full skill flow.** When a skill is invoked — whether called
from this workflow or triggered directly by the user — execute the
skill's entire prescribed workflow in order. User prose in the same
message is additive context or a specific step adjustment; it is never
a license to run only part of the skill. Additional deliverables
(learnings, summaries, explanations) come after the skill completes its
full flow, not instead of it.

**Batch independent tool calls into one response.** When the next
several tool calls have no data dependency on each other, emit them in
a single response as parallel `tool_use` blocks — never serialize them
across turns.

- Before sending a response with a tool call, ask: "Which other calls
  will I need next that do not consume this call's output?" Batch all
  of them now.
- The recurring failure is probing variants one-at-a-time (two reads,
  two API calls, two greps that differ only by argument) across
  separate turns — each serialized call wastes a round-trip and prompt
  cache.
- The only exception is a genuine dependency: a later call's parameters
  come from an earlier call's result. Even then, batch every
  independent call within each step.

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
"the plan is done." Polish steps — `wk-self-review`, `wk-docs`,
`wk-retro`, the CI verification — are part of the contract; silently
skipping them is a violation even when they feel optional after a
successful merge.

If any step is ambiguous, ask the user before claiming completion.

---

## Phase 1: Plan

### Jira ticket pre-flight

Before any exploration — `Read`, `Grep`, or `Agent` dispatch —
check whether a Jira ticket exists for the work.

- If the user's prompt contains a Jira URL or key, treat that as
  yes and proceed.
- If yes, invoke `wk-jira` (Stage 0+1+2) before drafting the
  plan. Acceptance criteria and linked specs belong in the plan,
  not retrofitted after exploration starts.
- If unknown, ask the user once before spawning exploration.
- Surfacing the ticket after exploration is underway wastes the
  turn and risks a plan that contradicts acceptance criteria.

### Investigate user-provided artifacts first

Before spawning exploration `Agent` calls, scan the user's most recent
message for concrete references — URL, PR number, file path, error
message with line/column, build ID, stack frame.

- If any concrete artifact is present, fetch/read it directly first
  (`gh pr diff`, `Read`, `gh run view`, `bk build view`, etc.). The
  user has already scoped the investigation.
- For GitHub comment / review URLs specifically, fetch the comment
  body via `gh api repos/{owner}/{repo}/{pulls|issues}/comments/{id}`
  before any codebase grep. The comment text usually contains the
  exact diagnostic information needed; running grep first wastes a
  turn and signals inattention to user-supplied scope.
- Before writing any HTTP client, SDK wrapper, or API integration
  for a third-party service, survey the available MCP tools for
  that service name. If a matching MCP tool exists and the use
  case is interactive (not pipeline / CI / cron code that must run
  outside a Claude session), prefer the MCP. Only build a client
  when the call must run in a non-Claude environment, and document
  that reason explicitly in the plan.
- Spawn parallel exploration agents only when no concrete artifact
  exists or the artifact is exhausted and gaps remain.
- Treat parallel `Agent` dispatch as a higher-cost fallback, not the
  default — running it while a user-provided URL is unread signals
  inattention and wastes a turn.

Before writing any code, produce an explicitly numbered plan. Every plan MUST
contain these elements — if any are missing, add them before executing:

1. **Implementation steps** — what to build or change, broken into the smallest
   meaningful units
2. **Commit boundary after each step** — each step ends with `wk-commit`
3. **Documentation update with each step** — each step includes a `wk-docs`
   invocation for affected docs, README, specs, or ADRs
4. **Testing step** — covers happy path, sad path, and edge cases
5. **Adversarial review step** — invoke `wk-adversarial-review` to gate the push
6. **PR offer** — ask the user if they want a PR
7. **CI fix loop** — monitor CI, auto-diagnose and fix failures, re-push
8. **Session retro** — `wk-retro` at end of session (non-negotiable)

### Commit Granularity

Prefer the smallest possible commits. Each commit must:

- Do exactly one logical thing
- Pass all tests and CI in isolation — no commit may break the build
- Include documentation updates for any behavior it introduces or changes
- Be immediately committable via `wk-commit`

If a step is too large for a single commit, split it into sub-steps with their
own commit boundaries. When in doubt, split.

### Prefactor probe — lift before extending

Before writing a new caller of an existing pattern, lift the shared
logic and migrate the existing caller first. The new caller then
delegates to the helper plus its new behavior. Order: **lift →
migrate → extend**, not "extend now, refactor later" — once the
duplicated code lands working, it stops being a delta in the diff
and becomes "how the file looks," and consolidation cost goes up
with every test that accretes against both copies.

Trigger phrases / signals that should fire the probe during
planning:

- "another <X>", "similar to <X>", "like the <X> version"
- The new feature is a verb the codebase already implements:
  "post a comment", "validate <format>", "fetch <resource>",
  "open a build", "render <view>".
- The new caller will live in a different file from the existing
  one — duplication hides especially well across file boundaries.

When the probe fires:

1. **Grep** for the operation across the codebase. Read both call
   sites end-to-end, not just the function signatures.
2. **Identify the duplicated prologue/epilogue** — validation, error
   handling, logging, retries, formatting. The behavioral core is
   often small; the ceremony around it is what duplicates.
3. **Lift** the duplicated portion into a helper module/function in
   the same `lib/`-equivalent location, with **one** consolidated
   test file.
4. **Migrate** the existing caller onto the helper as a separate
   commit, with all existing tests still passing.
5. **Then extend** — implement the new caller as a thin wrapper
   that delegates to the helper plus its new behavior.

The plan must list these as numbered steps before the new-feature
step, not after. The migration commit on the existing caller is
reviewable in isolation; the new caller's diff ends up small and
reads as new behavior, not as duplicated prologue.

If grep returns no existing caller, the probe is a no-op — proceed
with the new feature directly.

### Intra-file duplication probe

The prefactor probe above targets cross-file duplication. A
separate failure mode is **intra-file duplication** — adding a
new function, event handler, or initialization block to a large
file that already contains a stale or partial version of the
same logic, silently shadowed.

Before adding any new block to a large mixed-content file
(>200 lines, especially `.erb`, `.html`, `.vue`, `.svelte`, or
any template that interleaves multiple languages), grep the
file itself for the function name, event name, selector, or
feature keyword first.

```bash
grep -nE '<feature-keyword>|<function-name>|<event-name>' "$FILE"
```

If a match exists, decide in the same commit whether to remove
the prior version, replace it, or merge — never add alongside.
Shadowed duplicates pass tests when the live copy is correct
and silently corrupt behavior when the stale copy wins.

### Spec pre-flight — extend an in-flight spec before creating a new one

Before producing a new spec/design doc, check for a related spec already
in flight on an open PR and extend it rather than landing a parallel file.

- Grep open PRs for specs in the same feature area before planning a new
  one:

  ```bash
  gh pr list --state open --json number,headRefName,files \
    --jq '.[] | select(.files[].path | test("docs/specs/")) | {number, files: [.files[].path]}'
  ```

- If a related spec exists in an open PR, stack on that branch and extend
  the existing doc. Only create a standalone spec when no related in-flight
  spec exists.
- Skipping this produces two parallel specs that the user later has to
  merge by hand — a doc merge plus a rebase.

### Rule-set doc sync probe

When the diff modifies a check / validator / rule file, find authoring
guides that enumerate the rule set by count and add them as explicit
sync targets in the plan — before implementation starts.

- Grep guides (README, `docs/how-to`, repository-check docs) for
  count-enumerations of the rules: `"N things"`, `"three items"`,
  numbered "you must include" lists.
- A new rule turns an "N things" list stale; add each matching guide as
  a numbered sync step so the count and the body stay aligned.
- Skipping this lets the adversarial sweep catch the drift later instead
  of the plan catching it up front.

### Plan Presentation

Present the plan to the user before executing. Number every step. Mark which
steps produce commits. Example:

```
1. Add auth middleware          -> commit
2. Add auth tests (happy/sad)  -> commit
3. Update docs/specs/ADR       -> commit (or fold into step 1/2 if small)
4. Run full test suite
5. Refactor-opportunity scan (Phase 3.5)
6. Adversarial review (`wk-adversarial-review`)
7. Offer to create PR
8. CI fix loop (auto-fix until green or bail after 3 attempts)
9. Session retro
```

---

## Phase 2: Implement

**Worktree preflight (before the first Edit/Write).** When sibling repo
directories or multiple worktrees share one repo, confirm the cwd is the
intended worktree before editing — an edit resolved against the wrong
worktree gets blocked by the main-branch protect hook, forcing a reset
and re-apply.

```bash
git rev-parse --abbrev-ref HEAD   # must equal the feature branch
```

If the current branch is not the intended feature branch, re-anchor to
the correct worktree path before proceeding.

Execute the plan step by step. After completing each step:

1. **Run tests** — verify the step doesn't break anything
2. **Invoke `wk-workstyle` — non-skippable commit gate (HARD RULE).**
   Before every `wk-commit` on a code diff, call `Skill(wk-workstyle)`
   to gate the commit on the code-quality pass (naming accuracy, docs,
   structure, async patterns, testing intent). Project settings are
   authoritative.
   - Treat this exactly like the Phase 4 adversarial-review gate: no
     size, scope, or "trivial fix" exemption. "Auto-invoked" in a
     skill's own description is aspirational — the enforceable rule is
     this explicit step in the calling workflow. A commit that skips
     the gate is a workflow violation, not a shortcut.
3. **Invoke `wk-docs`** — check for and update affected documentation (README,
   specs, ADRs, tutorials, reference docs). A feature commit without its
   documentation update is incomplete.
   - **Config-schema additions** (new YAML field, new env var, new JSON
     output field, new CLI flag) MUST land with a `docs/specs/` entry
     in the same or immediately following commit — never deferred.
     The entry covers context, decision, data flow, and a config
     reference. Reference docs that enumerate the schema get the new
     field in the same commit.
4. **Invoke `wk-commit`** — create a signed, conventional commit with emoji

Never batch multiple steps into one commit. Never defer documentation to the
end. Never skip tests between commits.

### Design pivots travel with their docs

**HARD RULE:** When a commit changes the **logical structure** of a feature —
not just a bug fix or polish, but a redirect of *how* the feature
works — the same commit MUST update every artifact that described
the old shape:

1. The design spec (`docs/specs/`-equivalent for the project).
2. The implementation plan (`docs/plans/`-equivalent).
3. Inline code comments referencing the old approach.
4. Test names / test file comments referencing the old approach.
5. Any ADR (`docs/adr/`) that captured the original decision —
   either update it or add a successor ADR superseding it.
6. Spec sections that **enumerate** tests by count, name, or
   bullet list. When a test is added, removed, or renamed, every
   spec/plan/README that quantifies or lists tests must be
   updated in the same commit so counts and bullets stay in sync
   with the test file.

### Test enumeration sync

**HARD RULE:** Whenever a commit adds, removes, or renames a test, before
committing run a grep for the test file or function name across
spec/plan/README artifacts:

```bash
grep -rn '<test_file_basename>\|<new_test_function_name>' \
  docs/ README.md 2>/dev/null
```

Also grep for **count phrases** that reference the test set
(e.g., `"\d+ tests"`, `"covers \w+ scenarios"`, or any phrasing
that quantifies the test surface) in the files that own the
test description. Any hit must be
updated in the same commit. The invariant is: spec test counts
and bullet lists always match the actual test file. A one-line
diff to the spec costs nothing now and saves a separate review
round later.

If the spec needs a major rewrite (pseudocode blocks, sequence
diagrams, etc.) and that rewrite would dwarf the code commit,
add a **STATUS UPDATE** banner to the top of the doc citing the
commit SHA and a one-paragraph summary of the redirect, then
schedule the full rewrite as a follow-up commit on the **same
branch** (not a follow-up PR). The banner keeps the doc honest
while the rewrite lands.

Triggers that mean "this is a design pivot, not a polish":

- A conditional became unconditional (or vice versa).
- A layered helper was lifted, inlined, or replaced by a
  different abstraction.
- Two paths merged into one, or one path split into two.
- An interface signature changed (params added/removed/reordered).
- A piece of state moved to a different lifecycle (per-request →
  global, per-call → cached, etc.).

Reviewers and bots reliably catch cross-doc inconsistency on the
next round and require a separate response commit. Folding the
doc update into the pivot commit is one round; deferring is two.

### External-call reproduction before fix and commit

**HARD RULE:** Before writing a fix for any failing external API or CLI
call, reproduce the failure locally and read the response body. Before
committing the fix, rerun the same call locally and confirm it now
returns success.

- Reproduce first. Construct a minimal local invocation (curl, equivalent CLI) using the exact parameters the failing call used.
- Read the response body — most APIs name the missing or invalid field directly.
- Reject status-code-only diagnosis. A 4xx attributed to one cause ("branch missing", "auth expired") is often a different cause ("required field absent"); guessing produces a second PR after the first fix lands on the wrong root cause.
- Rerun the local invocation with the fix applied before `wk-commit`. Only commit after the call returns 2xx.
- When the agent cannot reproduce locally (missing token, gated network, user-only credentials), pause before `wk-commit` and offer the user the exact command to run plus the success criterion. Commit after the user confirms — committing an unverified API-shape change forces a follow-up PR when the live call still fails.

### Signature widening pre-flight

When adding a non-optional parameter to a public function or a
required field to a public struct/type, grep every caller and
initializer **before** running tests. Compile errors from a
widened signature are deterministic and enumerable upfront — let
the test runner discover them and you waste a cycle per missed
site, plus any test that doesn't even reach the changed code.

```bash
grep -rn '<TypeName>\s*{'  src/ tests/   # struct/record initializers
grep -rn '<FunctionName>(' src/ tests/   # function/method calls
```

Fix every site in the same commit as the signature change, then
run tests once. This applies to any language where adding a
required field/param is a build-breaking change (Rust, Go, Kotlin,
TypeScript with strict types, etc.) — not just to the language
that surfaced the lesson.

### `replace_all` scope pre-flight

**HARD RULE:** Before using `replace_all: true` on an Edit, grep the
target string across the file and confirm every occurrence should
receive the same replacement.

- Run `grep -nE '<target>' <file>` and read every hit.
- If any occurrence requires a different value, a different surrounding
  context, or must remain unchanged (test stubs, fixture data, doc
  examples, commented-out reference), reject `replace_all` and use
  targeted single-occurrence edits instead.
- Same-string different-meaning is the recurring failure: production
  call sites and test stubs share a function name but expect different
  arg shapes; a blanket `replace_all` corrupts the test stub silently.
- The rule applies to any tooling equivalent (`sed -i`, IDE refactor
  across file, multi-cursor select-all) — verify the match set before
  letting the edit fire.

### Same-semantic-class audit on coercions

**HARD RULE:** When applying a coercion (`.to_s`, `.to_i`, `&.`, `String()`,
`Number()`, optional-chaining, null-coalescing, etc.) to one argument or
field, audit every argument of the same semantic class in the same pass.

- Semantic class = role + nullability + type shape (e.g., "external ID,
  nullable, string-or-int"; "count, non-nullable, int"; "timestamp,
  optional, string-or-Time").
- Grep the surrounding parameter list / constructor / call site for siblings
  matching the same class; apply the same coercion to all in the same commit.
- The recurring failure is fixing the immediately visible case while a
  sibling of the same class one line over still carries the original bug —
  adversarial review catches it pre-push, but only on the lucky pass.
- This rule applies to any "fix one of N similar things" edit, not just
  coercions: same-class guards, same-class redactions, same-class retry
  wrappers, same-class logging.

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

#### Layer responsibility — side effects live at the entrypoint

Before adding I/O (`puts`, `print`, `console.log`, file writes, env
reads, network calls) to a module, classify the module's
responsibility:

- **Decision / pure** — returns a value, no observable effect on the
  outside world. Library, model, calculator, mapper, validator,
  serializer, predicate.
- **Side-effecting / entrypoint** — CLI script, HTTP handler, job
  runner, controller, view. Owns rendering, logging, env access, and
  external calls.

Side effects belong only in entrypoint layers. When the data is
needed elsewhere, return it; do not log it from a decision module
and parse the log upstream. ENV reads in a decision module are the
same anti-pattern — the entrypoint reads ENV and passes the value
down.

Symptoms that signal the wrong layer: duplicated ENV reads across
sibling modules, `puts` in a function whose return value is what
callers actually consume, tests that have to capture stdout to
assert behaviour.

#### External-API field validation — reuse the library's schema

Before hardcoding an allowlist of an external API's field names (a
permission set, enum, or supported-flag list), check whether the client
library's types already encode it (struct tags, generated enums, schema
constants). A parallel hand-maintained list is a maintenance trap — it
silently drifts every time the upstream API adds or removes a field.

- Prefer the library's own validation: strict decoding that rejects
  unknown fields (`json.Decoder.DisallowUnknownFields` in Go, schema
  `strict`/`forbid` modes elsewhere). The type's tags become the
  allowlist, and upstream additions are picked up on dependency bump.
- Hardcode a list only when no library type encodes it; when you must,
  cite the upstream source and note the re-sync obligation on
  dependency updates.

#### Architecture Decision Records

When making a significant architectural decision (new dependency, pattern
change, technology choice, trade-off acceptance), create an ADR in
`docs/adr/` using the format: title, status, context, decision, consequences.

#### Content-lint hooks — scope to file class and diff

When writing a pre-commit hook that flags a content pattern (bare
references, banned tokens, style violations), scope it twice before
wiring it in:

- **File class.** Restrict to the file class the underlying rule
  actually governs; exclude every other class explicitly. A rule about
  navigable docs must not scan instruction files that use the flagged
  pattern by design.
- **Added lines only.** Prefer scanning `git diff --cached -U0` added
  lines, not the whole staged file. A hook that flags pre-existing
  content in a file the commit only touched once blocks unrelated work
  and trains the author to `--no-verify` — which defeats the hook.
- Smoke-test the new hook against a file that legitimately contains the
  pattern but is out of scope, and confirm it does NOT fire.

### Provenance checks

**Reuse hygiene.** Patterns lifted from neighboring files are not portable by default.
Before copying a fallback chain, default, or conditional, trace each variable:
1. **Where is it set?** — secrets manager, pipeline env, bootstrap script, calling tool.
2. **What code path sets it?** — does that path reach the new location?
3. **Does the value mean the same thing in the new context?** — if not, adapt; don't copy verbatim.

Cross-script copies are especially hazardous — each script tends to have a different invocation environment. Ask or grep for setters before reusing.

**Error-string discriminators.** When a fallback decides whether to recover by matching a specific error message (e.g., `grep -q "some error text"`), reproduce the failure against a real-enough fixture and capture the exact text before writing the catch. Error wording changes between tool versions; a stale discriminator either swallows real failures silently or never fires on the intended case. Use a minimal throwaway fixture (for git, prefer `file://` URIs over bare paths so network-protocol code paths actually run) and write the verification before writing the catch clause.

**Environment variables in docs.** Whenever code or docs introduce or reference an env var, document: where it is stored, who can edit that store, how a change propagates, and what the default is if unset. Operators need to know how to change the value without a code deploy.

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
- Run the **full pre-push gate the repo defines** before any `git push` —
  every test suite, lint, and type check the repo wires into pre-push
  (e.g., `lefthook run pre-push`, `bin/ci`, `make check`). Independent
  suites can assert on the same source with different matchers; passing
  one does not imply the others pass. Inspect the hook config to enumerate
  every gate, do not assume the suite you ran during dev is the full set.

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

3. **`grep -qv` is a false-positive trap for negative assertions.**
   `grep -qv 'pattern'` exits 0 when **any** line in the input does
   not match — which is almost always true for multi-line output.
   The assertion passes trivially and never fires on the intended
   case. Use `! grep -q 'pattern'` instead, which fails (non-zero)
   if the pattern appears anywhere.

   ```bash
   # WRONG — passes whenever any other line exists
   echo "$output" | grep -qv 'exit 1'

   # CORRECT — fails if exit 1 appears anywhere
   ! echo "$output" | grep -q 'exit 1'
   ```

   The same trap applies to two-stage pipelines like
   `grep -v X | grep -qv Y` — the second stage still passes
   trivially.

---

## Phase 3.5: Refactor-Opportunity Scan

After tests pass and before invoking `wk-adversarial-review`, scan the
diff and its neighbouring code for refactor and reuse opportunities.
This is a deliberate readability/dedup pass, not a behavior change —
catch the duplication and clarity wins while the diff is fresh, not
on a follow-up PR.

- Re-read the full diff once: `git diff $(git merge-base HEAD "$(gh pr view --json baseRefName --jq .baseRefName 2>/dev/null || echo origin/HEAD)")...HEAD`.
- For every new/modified function, helper, constant, or block, scan
  the **neighbouring surface** — the same file, sibling files in the
  same directory, and any module the diff imports from. Grep for:
  - Existing helpers, constants, or types that already do what the
    new code does (reuse candidate).
  - Repeated literals (strings, numbers, regexes) that should be a
    named constant.
  - Near-duplicate blocks (≥ 3 similar lines) within the diff or
    against neighbours — candidates for extraction.
  - Long conditional chains or nested blocks that an early return,
    guard clause, or lookup table would flatten.
  - Re-implemented patterns the language/framework already provides
    (stdlib utility, builtin, idiom).
- For each opportunity, classify:
  - **Apply now** — reuse an existing helper, replace a literal with
    an existing constant, lift a near-duplicate into a helper that
    both sites can call. Land as one commit before Phase 4.
  - **Defer with note** — refactor is real but expands scope beyond
    the current change; capture as a TODO in the PR description's
    "Follow-ups" section and move on.
  - **Skip** — no real win, or the abstraction would be premature
    (`Rule of Three`: don't extract on the second occurrence alone
    unless the duplication is load-bearing).
- Behavior-preservation rule: a refactor commit lands only when tests
  still pass against the post-refactor code. Re-run the suite after
  every Apply-now change.
- The scan is mandatory but its **output** is not — a clean diff with
  zero opportunities is a valid outcome. Record "refactor scan: no
  opportunities" in the Phase 8 retro so the audit happened on paper.

## Phase 4: Adversarial Review

After implementation is complete, tests pass, and the Phase 3.5
refactor scan has landed (or recorded "no opportunities"), invoke
`wk-adversarial-review`.
The skill is the **sole authority** for pre-push critique — do not approximate
it with an inline subagent, ad-hoc grep pass, or "quick check".

`wk-adversarial-review` runs mechanical sweeps for the issue classes
reviewers and bots historically flag (vulnerability-class fixes left on
one site, sibling-script drift, dead defensive guards, comment-accuracy,
hardcoded base branches, version pins, signature widening, cross-doc
enumeration sync, design-pivot doc drift, PR-metadata drift,
external-call reproduction, raw-API bypass, pre-push gate compliance),
then spawns a fresh adversarial subagent, then validates runtime claims
in a playground. It returns one of three verdicts: **clear**, **blocked**,
or **suggestions-only**.

### After Verdict

- **Clear** — proceed to Phase 5 (PR).
- **Blocked** — fix each blocker (one commit per fix via `wk-commit`),
  then re-invoke `wk-adversarial-review`. Loop until clear. Never push,
  never `gh pr ready`, never `gh pr create` on a blocked verdict.
- **Suggestions only** — follow the skill's A/B/C prompt; auto mode
  defaults per the skill.

#### Findings are incorporated, never offered

**HARD RULE: Pre-flight review findings are mandatory actions, not options.**
This applies to every gate that produces findings — `wk-adversarial-review`
on code and `wk-arch-review` on specs, design docs, plans, or estimates.
Once a gate returns findings, the agent acts on them; it does not ask the
user "should I incorporate these?"

- **Blockers** — fix immediately, commit each fix via `wk-commit`, then
  re-run the same gate. Loop until the gate clears.
- **Improvements / gaps** — incorporate into the artifact it concerns
  (code for `wk-adversarial-review`, the doc for `wk-arch-review`), then
  commit. Do not defer, downgrade, or surface them as an optional menu.
- **Design-ambiguous findings** — when a finding turns on a genuine design
  decision only the user can make, present that one specific design
  question, wait for the answer, then act. Ask the design question — never
  the meta-question "should I update this?".
- The only pause is a real design decision the user owns. "Should I apply
  the review's suggestions?" is not a design decision; framing
  incorporation as user-gated is a workflow violation, the same class as
  asking "should I commit?" or "would you like a PR?".

**HARD RULE:** Every push, every PR transition (`gh pr create`,
`gh pr ready`), and every force-push that leaves this machine runs
`wk-adversarial-review` first. There is no size, scope, or "docs-only"
exemption.

---

## Phase 5: PR

**HARD RULE:** Every push to a branch that has no open PR invokes
`wk-pr` automatically. No size exemption — a one-line fix is the
same as a 500-line feature for this rule. Phrases like "this is
small," "this doesn't need a PR," or "just a quick fix" are red
flags; if the rule applies, execute it. If the user pushes back
asking why no PR was created, **open it without asking** — the
Autonomy Rules table forbids the "would you like a PR?" question.

### Detect repo convention before branching

**"Branch first on the default branch" is a DEFAULT, not an absolute
rule.** Some repos (solo-maintained, no review gate) commit straight to
their default branch; auto-creating a feature branch there causes
friction. Probe the repo's actual convention before branching:

- Resolve the default branch dynamically; never assume a literal name:

  ```bash
  DEFAULT=$(git symbolic-ref refs/remotes/origin/HEAD --short | sed 's@^origin/@@')
  REPO=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
  ```

- Gather evidence the repo is PR-gated vs commit-to-default:
  - Branch protection (`gh api "repos/$REPO/branches/$DEFAULT/protection"`
    — a 404 means no protection).
  - `CODEOWNERS` present (`.github/`, repo root, or `docs/`) → review gate.
  - Recent merge commits from feature branches
    (`git log --oneline --merges -20` — near-empty flat history signals
    direct-to-default commits).
- **Branch only when evidence points to a PR-gated workflow** (protection,
  CODEOWNERS, or a history of merged feature branches). Otherwise commit
  straight to the default branch and skip the auto-branch + PR flow.
- When signals conflict or are absent and the change is non-trivial,
  branching is the safer default — but say why in one line rather than
  branching silently.

After code review passes, invoke `wk-pr` automatically. Do not ask for
permission — the workflow prescribes it. **Never use raw `gh pr create`
or any other method.** This is non-negotiable. `wk-pr` handles:

- Draft creation (always starts as draft)
- Stacked PRs when the diff exceeds ~30 lines
- CI polling (waits for green before proceeding)
- Self-review via `wk-self-review` — posts inline comments on **critical
  changes only**: design decisions, non-obvious logic, security-sensitive
  paths, behavioral changes. No noise, no trivial comments. Self-review
  is a **pending review** even when there is only one comment to make —
  never substitute raw `gh api .../comments` calls (those publish
  immediately and skip the human-in-the-loop checkpoint)
- Automated review feedback triage
- Marking ready for review

### Post-push sync

`wk-commit` handles PR description sync and stale comment resolution after every push. See `wk-commit` for the full Post-Push PR Sync rules.

**HARD RULE: Auto-sync drifted artifacts — never ask permission to
fix obvious drift.** After any push, significant code change, or
approach pivot, audit every dependent artifact (PR title/body,
self-review comments, ticket description, related docs) and update
it in the same turn — without a "want me to update X?" prompt.

- Asking permission to fix obvious drift wastes a turn and
  surfaces decision fatigue for a non-decision.
- Confirm only when the **content** of the sync is genuinely
  ambiguous (e.g., the new description requires a judgment call
  the user has not made yet). Never confirm the **decision** to
  sync.
- Applies to PR body (`wk-commit §Post-Push PR Sync`), self-review
  comments (`wk-self-review` on approach pivots), Jira ticket
  descriptions (`wk-jira`), and docs (`wk-docs`).

### Self-review sync on approach pivots

**HARD RULE:** After any push that changes the implementation **approach**
(not just polish), resolve pending self-review threads that reference
the old design and post fresh self-review comments for the new design
via `wk-self-review` before returning control.

- "Approach pivot" = the mechanism, API, data flow, or abstraction
  changed — not a rename, comment tweak, or formatting pass.
- Self-review comments rationalising the old design mislead
  reviewers exactly as a stale PR body does. PR-body sync alone is
  insufficient on a pivot.
- Resolve the stale threads explicitly (do not just let them
  scroll off); post the replacement comments in the same
  `wk-self-review` invocation.

### Pre-rework fetch

**HARD RULE:** Before any **rework** of a PR's branch — force-push, restructure,
content rewrite, big rebase, scope change — fetch and reconcile
against the PR's actual base **and** the default branch:

```bash
PR_NUM=$(gh pr view --json number --jq .number)
BASE=$(gh pr view "$PR_NUM" --json baseRefName --jq .baseRefName)
DEFAULT=$(git symbolic-ref refs/remotes/origin/HEAD --short \
          | sed 's@^origin/@@')

git fetch origin "$BASE" "$DEFAULT" --quiet

# If the resolved base advanced, integrate before reworking
LOCAL_MB=$(git merge-base HEAD "origin/$BASE")  # $BASE resolved from PR above
REMOTE_TIP=$(git rev-parse "origin/$BASE")
if [ "$LOCAL_MB" != "$REMOTE_TIP" ]; then
  Skill(wk-pr-update, args="$BASE")
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
│         │            (wk-buildkite)   │     │
│         │                             │     │
│         │    ◄── commit (wk-commit) ◄─┘     │
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
GitHub checks API or `wk-buildkite` depending on the project's CI system:

```bash
# GitHub Actions / generic checks
gh pr checks --watch --fail-fast

# Buildkite (if applicable)
# Use wk-buildkite to check build status
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

**Never end a turn announcing a holding pattern.** After issuing a
backgrounded watch, return control immediately with the next concrete
step or a question — never close out with "CI watch running, will
continue when green." The runtime fires a completion notification
when the watch exits; a holding-pattern sign-off forces the user to
re-prompt and defeats the purpose of running in the background.

### Step 2: Diagnose Failures

When CI fails, read the actual logs first — use `wk-buildkite` for Buildkite or `gh run view --log-failed` for GitHub Actions. Never guess.

**Classify the failure before generating fix candidates:**

| Failure type | Action |
|--------------|--------|
| Code failure (test/lint/type/build) | Diagnose root cause; apply fix-candidate ordering below |
| Flaky test (unrelated to PR) | Re-trigger once; if same test fails again, treat as real |
| Infrastructure (timeout/OOM/runner down) | Re-trigger; if persistent, inform user — no code fix |

**Diagnosis discipline — cross-reference repo standards first:**

| Error signal | Check this rule |
|--------------|----------------|
| `no version is set`, `couldn't resolve latest`, `unknown tag` | Version-pinning (`latest`/unpinned dep) |
| `auth failed`, `unauthorized`, `expired token` | Env-var / secrets provenance docs |
| `permission denied` on a script | File-permissions (`chmod +x` on executables) |
| `command not found` for a project tool | Tool-version manifest (`mise.toml`, `.tool-versions`) |
| New third-party Action on org-managed runner | Prefer `actions/*` or non-action install; ask user before adding new third-party action |

If the error matches a repo rule, the first fix candidate is "comply with that rule" — not a backend change or workaround.

### Step 3: Fix and Re-push

For code failures:

1. **Fix the issue** — apply the minimal, targeted fix (see ordering below)
2. **Run tests locally** — verify the fix passes before pushing
3. **Commit via `wk-commit`** — one fix per commit, conventional format
4. **Push** — regular `git push`, never force-push
5. **Update PR description** — `gh pr edit` to reflect the fix
6. **Re-enter the loop** — go back to Step 1

#### Fix-candidate ordering

Order fixes from smallest input change to largest stack change:

| Priority | Candidate | Notes |
|----------|-----------|-------|
| 1 | Version downgrade (one minor/patch) | When dep upgrade is proximate cause; smaller diff than backend swap |
| 2 | Repo-rule compliance | Comply with the violated rule — usually a one-line config change |
| 3 | Same-tool config tweak | Adjust `mise.toml`, `.lychee.toml`, `tsconfig.json` before swapping tools |
| 4 | Same-tool backend/option change | Switch backend, installer flag, or runner option within existing tool |
| 5 | Tool-stack change | Removing/replacing a user-named tool — **requires explicit confirmation** |

**Coupled config rule:** When changing a tool's version (bump or revert), audit all config files that tool reads (`.rubocop.yml`, `tsconfig.json`, lockfiles, etc.) in the same commit. A version change without a coupled-config check ships fine in isolation and breaks the next run.

**Hard rule:** Before any level-5 change, stop and ask the user — do not silently remove a named tool. Even in auto mode, dropping a user-named tool exceeds the autonomy budget.

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

After a green exit, resume the `wk-pr` post-creation workflow: self-review
(`wk-self-review`), automated feedback triage, and mark ready.

---

## Phase 7: Documentation Audit

Documentation is woven into every commit during Phase 2, but do a final audit
after all code is complete:

1. Invoke `wk-docs` for a full scan of affected documentation
2. Verify the README reflects any user-facing changes
3. Create or update ADRs for significant architectural decisions made
4. Update specs if behavior changed from what was originally specified
5. Ensure the `docs/` index (`docs/README.md`) is current
6. If the project has no `docs/` folder, `wk-docs` bootstraps one with:
   `plans/`, `specs/`, `adr/`, `tutorials/`, `examples/`

---

## Phase 8: Session Retro — NON-NEGOTIABLE

**HARD RULE: At the end of EVERY session, invoke `wk-retro`.** No
exceptions. Mandatory regardless of whether the task completed,
partially completed, failed, or was abandoned. Auto mode does not
exempt this phase. Skipping the retro is a workflow violation.

**HARD RULE: Never ask whether to capture learnings.** Invoke `wk-learn`
immediately after every skill run and after every user correction —
unconditionally, the same as committing after a code change. Surfacing it as a
question ("should I capture learnings for X?") is a violation; capture, don't ask.

**HARD RULE: `gh pr ready` is not a session terminus.** After every
`gh pr ready` succeeds, the very next action is `Skill(wk-retro)` — no user
prompt, no asking. Marking ready feels like the end; the workflow contract
says the retro is. Treat it like `wk-commit` after a code change: automatic,
non-negotiable. "Work is done" != "workflow is done".

The retro:
- Auto-invokes `wk-learn scan` to mine the session transcript for
  every user interruption / redirect, classify each by affected
  skill, and write per-skill learning files (Step 1.5 of `wk-retro`).
- Reviews what happened across 5 lenses (mistakes, corrections, gaps,
  decisions, successes), informed by the scan's findings.
- Writes a dated entry to the global retro log.
- Distills findings into actionable rules and promotes them globally
  to `~/.claude/memory/` so ALL future sessions benefit.

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
to start Docker Desktop or Colima (`colima start`). Use `wk-docker` for
Docker-related work.

### Configuration

Always add permission rules, settings, and MCP servers to
`~/.claude/settings.json` (global), not `.claude/settings.local.json`
(project-scoped), unless intentionally local. For MCP servers, use
`--scope user`. Never add MCPs to `~/.claude.json` (the state file).

### CI Failures

Use `wk-buildkite` when investigating CI failures. Do not guess at CI
issues — read the actual logs.

---

## Skill Reference

All `wk-*` skills and when to invoke them during this workflow:

| Skill | When | Phase |
|-------|------|-------|
| `wk-commit` | After completing each implementation step; CI fix commits | 2, 6 |
| `wk-workstyle` | Code-quality gate before every commit on a code diff | 2 |
| `wk-docs` | With each commit and during final audit | 2, 7 |
| `wk-pr` | When creating or updating a pull request | 5 |
| `wk-self-review` | Invoked automatically by `wk-pr` after CI passes | 5 |
| `wk-buildkite` | Diagnosing CI failures in the fix loop | 6 |
| `wk-adversarial-review` | Pre-flight gate before every push / PR transition | 4, 5, 6 |
| `wk-pr-update` | Rebasing / syncing a PR branch with its base | 5, 6 |
| `wk-pr-review` | When reviewing someone else's PR | — |
| `wk-pr-resolve` | When addressing review feedback on your PR | — |
| `wk-learn` | Post-completion learning capture (end of any skill run) | any |
| `wk-retro` | End of every session (mandatory) | 8 |
| `wk-docker` | When working with Docker/containers | any |
| `wk-datadog` | When managing observability resources | any |
| `wk-worktree-cleanup` | When cleaning up merged worktrees | any |

---

## Checklist

Use this as a final gate before claiming work is complete:

- [ ] Every commit is atomic and passes tests/CI independently
- [ ] `wk-workstyle` pass completed on all touched files (naming, docs, structure, coverage)
- [ ] Documentation updated alongside each code change
- [ ] Tests cover happy path, sad path, and edge cases
- [ ] `wk-adversarial-review` returned a clear verdict against current HEAD
- [ ] CI fix loop exited green (all checks passing)
- [ ] PR description reflects current branch state
- [ ] Self-review posted highlighting critical changes only
- [ ] Version pins are exact (no `latest`, `^`, `~`)
- [ ] Scripts have correct file permissions
- [ ] Diagrams use Mermaid, not ASCII art
- [ ] Regex uses named capture groups
- [ ] ADRs created for significant architectural decisions
- [ ] Session retro completed via `wk-retro`
- [ ] Every numbered plan step is finished or explicitly deferred — not "most" or "the important ones"

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn workflow`).
