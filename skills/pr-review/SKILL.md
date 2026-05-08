---
name: wk-pr-review
description: >-
  Thorough, critical code review of a GitHub pull request. Use when asked to
  review a PR, review code changes, help review this PR, create review comments,
  or investigate a pull request. Reads existing review comments, resolves stale
  threads, builds a playground to validate assumptions, runs experiments, and
  creates pending review comments via GitHub API.
argument-hint: '[PR number or URL]'
allowed-tools:
  - "Bash(gh pr view:*)"
  - "Bash(gh pr diff:*)"
  - "Bash(gh pr checkout:*)"
  - "Bash(gh api repos:*)"
  - "Bash(gh api graphql:*)"
  - "Bash(git rev-parse:*)"
  - "Bash(git pull:*)"
  - "Bash(grep:*)"
  - "Bash(.review-playground/:*)"
  - Read
  - Grep
  - Glob
  - Write
  - Edit
  - Agent
  - AskUserQuestion
model: opus
effort: high
model-invocable: true
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '2026.05.08-181958'
  model:
    openai: o3
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# PR Review

Automated, thorough code review that investigates changes deeply, builds a
playground to validate assumptions, and posts encouraging but critical review
comments as a pending GitHub review.

## Phase 1: Context

Determine the PR under review and gather all relevant context.

**If already on a PR branch:**

```bash
gh pr view --json number,title,body,baseRefName,headRefName,url,files,commits,reviews
```

**If on main/master or no PR is detected:** Ask the user for a PR number or URL,
then check out the branch:

```bash
gh pr checkout <number>
```

### Verify local HEAD matches PR HEAD

Before reading any files, confirm the local worktree is at the PR's HEAD:

```bash
LOCAL_HEAD=$(git rev-parse HEAD)
PR_HEAD=$(gh pr view --json headRefOid --jq '.headRefOid')
if [ "$LOCAL_HEAD" != "$PR_HEAD" ]; then
  echo "⚠ Local HEAD ($LOCAL_HEAD) ≠ PR HEAD ($PR_HEAD). Pulling..."
  git pull --ff-only || echo "Fast-forward failed — will use gh pr diff as source of truth"
fi
```

If the pull fails, use `gh pr diff` as the authoritative source for what
changed and `gh api repos/{owner}/{repo}/contents/{path}?ref={pr_head_sha}`
to read file contents at the PR HEAD instead of local `Read`. Note the desync
in the review summary so the user is aware.

### Collect context

Collect and internalize:
- PR title, description, and linked issues
- Full diff: `gh pr diff`
- List of changed files and their scope
- Commit history on this branch
- The base branch to understand what's being merged into

Before moving on, announce what you found:
> "Reviewing PR #N: *title* — X files changed, Y commits. Base: `main`. Let me dig in."

## Phase 2: Existing Review Comments

Fetch all existing review comments on the PR, identify stale threads, and
optionally resolve them before beginning investigation.

### Fetch comments

Retrieve all inline review comments from every reviewer:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments \
  --jq '.[] | {id, node_id, path, line, original_line, position, body, user: .user.login, updated_at, in_reply_to_id}'
```

Skip comments where `in_reply_to_id` is set — those are reply chains, not
top-level threads. Focus on root comments that anchor each conversation.

### Identify stale comments

A comment is **stale** when any of these are true:

- `position` is `null` — GitHub marks the diff position as outdated
- The file at `path` was modified in commits after the comment's `updated_at`
- The referenced line content no longer matches the current code

Read the current file and compare the line to confirm. Categorize each comment:

- **Stale (fixed):** The underlying issue is clearly resolved in the current code.
- **Stale (unclear):** The position is outdated but it is not obvious whether the
  issue was addressed. Leave these for the author or reviewer to handle.
- **Active:** Still applies to the current code.

### Present and ask before resolving

**HARD RULE:** Never resolve review threads without explicit user consent.
Present the categorized list and wait for confirmation.

```
Stale comments (resolved in code):
1. [stale] src/auth.ts:42 by @reviewer — "Session token not invalidated" → Fixed in abc123
2. [stale] src/utils.ts:18 by @reviewer — "Rename processData" → Renamed to transformPayload

Stale comments (unclear):
3. [stale?] src/api.ts:33 by @reviewer — "Is this timeout intentional?"

Active comments:
4. [active] src/cache.ts:91 by @reviewer — "LRU size should be configurable"

Would you like me to resolve threads 1 and 2?
(Thread 3 will be left for manual review.)
```

### Resolve confirmed threads

After the user confirms, query for thread node IDs via GraphQL
(follows the `reviewThreads` pattern from wk-pr-resolve Step 3 —
this variant fetches only the fields needed for matching and resolving):

```bash
gh api graphql -f query='
  query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            comments(first: 1) {
              nodes { body path line }
            }
          }
        }
      }
    }
  }
' -f owner="{owner}" -f repo="{repo}" -F number={number}
```

Match each confirmed stale comment to its thread by `path` + `line` + `body`,
then resolve:

```bash
gh api graphql -f query='
  mutation($threadId: ID!) {
    resolveReviewThread(input: {threadId: $threadId}) {
      thread { isResolved }
    }
  }
' -f threadId="THREAD_NODE_ID"
```

### Summarize

Announce what was found before moving on, broken down by commenter
type so the dedup and validation strategy is planned upfront:

> "Found X existing review comments (Y active, Z resolved as stale).
> Active breakdown: A from human reviewers, B from bot reviewers
> ({bot_logins}). Carrying N active comments forward into
> investigation; B bot findings queued for Phase 4 validation."

### Build the bot-findings validation queue

Every active comment whose author is a bot (`user.type == "Bot"` or
login ending in `[bot]`) goes into a `bot_findings_to_validate`
queue. Phase 4 reproduces each in the playground; Phase 5 posts a
typed reply driven by the validation outcome (see "Validate bot
findings in the playground" in Phase 4).

This is in addition to — not instead of — the exclusion list below.
The exclusion list still prevents the agent from posting parallel
top-level comments on the same line; the validation queue is the
mechanism by which bot findings get either confirmed (with a
suggestion fix) or refuted (with counter-evidence) instead of being
silently ignored.

### Build exclusion list

From the active comments, build a structured exclusion list keyed by
`(file, line_range, topic)`. This list is the deduplication mechanism for
Phase 3 and Phase 5 — it prevents you from independently rediscovering and
re-posting issues that another reviewer already raised.

### Re-review follow-up

Detect if the current user has previously posted review comments on this
PR. If so, this is a **re-review** — the agent must close the loop on
existing discussions before investigating new issues.

**Identify the user's own prior comments:**

Filter the fetched comments for those where `user` matches the current
GitHub user (from `gh api user --jq '.login'`). For each, fetch the full
reply chain — all comments with `in_reply_to_id` pointing to the root.

**Classify each thread the user participated in:**

| Status | How to detect | Action |
|--------|--------------|--------|
| **Fix applied** | The file was modified after the comment, AND the concern raised in the comment is no longer present in the current code | Draft a follow-up: "Looks good — thanks for addressing this." |
| **Fix attempted, still wrong** | The file was modified but the concern persists or was only partially addressed | Draft a follow-up explaining what's still off, referencing the current code |
| **Author asked a question** | The last reply in the thread is from the PR author (not the user), AND it contains a question or request for clarification | Draft a response answering the question based on investigation of the current code |
| **Author pushed back** | The last reply is from the author disagreeing or proposing an alternative | Draft a response acknowledging the pushback and either agreeing with reasoning or reiterating the concern with evidence |
| **No response** | No replies from the author, no code changes addressing it | Leave as-is — the comment still stands |
| **Already resolved** | Thread is marked resolved | Skip — no action needed |

**Present follow-ups for approval:**

```
Re-review: You have {N} prior comment threads with updates:

1. [fix applied] src/auth.ts:42 — "Session token not invalidated"
   → Author fixed in commit abc123. Drafting acknowledgment.

2. [question from author] src/api.ts:33 — "Is this timeout intentional?"
   → Author replied: "We need 30s for the upstream call. Is that OK?"
   → Drafting response based on current code analysis.

3. [fix attempted] src/utils.ts:18 — "Rename processData"
   → Author renamed to `process` but the suggestion was a more specific name.
   → Drafting follow-up with clarification.

4. [no response] src/cache.ts:91 — "LRU size should be configurable"
   → No changes or replies. Comment still stands.
```

Wait for user approval, then post approved follow-up replies sequentially
using the same reply API as `wk-pr-resolve`:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies \
  --method POST -f body="{follow_up_text}"
```

Resolve threads where fixes were acknowledged (with user consent per the
existing hard rule). Leave all other threads open.

**After follow-ups are posted, proceed to Phase 3** to investigate new
issues.

## Phase 3: Investigation

Read every changed file in full — not just the diff hunks. Understand the
surrounding code, call sites, downstream consumers, and existing test coverage.

**Carry forward existing comments.** Be aware of active unresolved review
comments from Phase 2. Do not duplicate comments that already exist. If you
find an issue that relates to an existing comment thread, reference it rather
than creating a separate observation. Focus on finding **new** issues that no
existing reviewer has raised.

**Identify new and modified surface area.** Scan the diff for:

- **New** functions, methods, classes, interfaces, and public APIs — code
  that didn't exist before has had the least scrutiny.
- **Modified** functions and methods — changed signatures, altered logic
  branches, updated return types. Existing callers may silently accept
  wrong results.
- **Changed interfaces, types, and contracts** — any modification to a
  type definition, protocol, abstract class, or API response shape.
  Downstream consumers that weren't updated are a high-severity risk.

Build a list of `{name, file, line, signature, parameters, status}` where
status is `new` or `modified` for each. These become the targets for
adversarial playground testing in Phase 4.

**Be adversarial.** Your job is to find what the author missed:
- Bugs and logic errors
- Missed edge cases and failure modes
- Security vulnerabilities
- Performance regressions
- Broken contracts or API changes
- Race conditions and concurrency issues
- Missing or inadequate error handling
- Inconsistencies with existing patterns

There is no fixed checklist. You decide what matters based on the actual changes.
Follow the code wherever it leads — if a changed function is called from 5
places, read all 5. If a new dependency is added, evaluate it.

**Audit test quality.** If the PR includes test files, verify they actually
test the change surface — not just pad coverage numbers. For each test file
in the diff, check for these red flags:

- **No failure path:** Tests only cover the happy path. No tests for
  invalid input, error conditions, or edge cases the implementation
  handles.
- **Unfailable assertions:** Tests that assert on mocked return values,
  trivial getters/setters, or constants — they pass regardless of whether
  the implementation is correct.
- **Missing assertions:** Test functions that call code but never assert
  on the result (`expect`/`assert` count is zero or suspiciously low).
- **Incomplete surface:** New functions or branches introduced in the PR
  that have no corresponding test at all. Cross-reference the list of
  new methods from above — every new public function should have at
  least one test exercising it.
- **Tautological tests:** Tests that verify the mock was called rather
  than verifying behavior. Tests where the setup guarantees the
  assertion (e.g., inserting a value and asserting it exists without
  testing deletion, update, or conflict).
- **Copy-paste tests:** Multiple tests with identical structure and only
  trivially different inputs, suggesting the author generated tests
  mechanically without thinking about meaningful scenarios.
- **Mutation-surviving tests:** Tests that still pass when the
  implementation is intentionally broken (e.g., flipping a conditional,
  returning a hardcoded value, removing a validation check). If breaking
  the code doesn't break the test, the test is not testing behavior —
  it's testing setup. Flag these for playground verification in Phase 4.

For each gap found, note **what's missing** and **what a useful test
would look like** — this feeds into the playground (Phase 4) and review
comments (Phase 5). A comment about missing test coverage is more
actionable when it includes a concrete example of what to test.

Take notes as you go. For each finding, annotate whether it overlaps an entry
in the exclusion list from Phase 2. Mark overlapping findings as `[COVERED]`
immediately — do not wait until Phase 5 to discover duplicates.

## File Access Rules

**HARD RULE:** Write and Edit tools may ONLY target files under
`.review-playground/` in the project root. Never write or edit files
outside of `.review-playground/`. Never commit playground files.

Read, Glob, and Grep may access any path (read-only) for code investigation.

## Phase 4: Playground

Create a `.review-playground/` directory at the repository root. This is your
workspace for experiments — **never commit these files**.

Ensure `.review-playground/` is in `.gitignore`:

```bash
if ! grep -qxF '.review-playground/' .gitignore 2>/dev/null; then
  echo '.review-playground/' >> .gitignore
fi
```

Build whatever combination the changes call for:

### Scratch scripts

Executable scripts that exercise changed code paths. Run them and observe
behavior. Example: a script that calls the modified function with various inputs
to see how it behaves at boundaries.

### Adversarial testing of new and modified functions

For every new or modified method/function identified in Phase 3, **launch
parallel experiments** that try to break it. Use the Agent tool to run
these concurrently — each agent writes its own script under
`.review-playground/` and reports back.

- **Edge cases:** boundary values, empty inputs, null/undefined/nil, zero, negative, max-size collections, single vs many, unicode, special characters, whitespace-only, very long strings
- **Boundary arithmetic:** off-by-one, fence-post, integer overflow/underflow, floating-point precision, array index bounds (first/last/one-past-end), loop termination, pagination (page 0 vs 1, last page, beyond last)
- **Type confusion:** wrong types per parameter; implicit coercion traps (`"0"` vs `0` vs `false`, empty string vs null, `[]` vs `{}`); values that satisfy the type but violate semantic constraints (negative age, future birth date, email without `@`)
- **Input mutation:** valid inputs with one field mutated — wrong type, missing field, extra field, swapped arguments, out-of-range; confirm graceful failure rather than silent wrong output
- **State and ordering:** stateful code — call methods out of order (use-before-init, double-init, use-after-close, concurrent callers); async code — test interleaving and cancellation
- **Fuzz:** randomized inputs (strings, numbers, nested objects) in a loop; vary volume (1, 10, 1000 calls) to expose resource leaks or accumulation bugs
- **Output:** return values match expected types and contracts; mutate output in downstream consumers to verify callers validate what they receive; existing callers still receive the expected shape

**Interpreter / runtime portability:** When the diff touches scripts
or modules that target multiple runtime environments (Linux CI vs
macOS dev, multiple Node versions, Python 3.x vs 3.y), run the
playground tests under **each runtime explicitly** — not just
whatever is first on `PATH`. Static review cannot catch
version-specific syntax; only runtime execution under the older or
stricter interpreter can.

| Diff includes | Run playground/tests under |
|---------------|---------------------------|
| `*.sh`, `*.bash`, `Brewfile`, shebanged shell | both `/bin/bash` (macOS bash 3.2) **and** the modern bash on `PATH`; flag bash 4+ idioms: `${var,,}`, `${var^^}`, `${var^}`, `${var,}`, `declare -A`, `mapfile`, `readarray`, `\|&`, `coproc` |
| `*.py` | each Python version in the project's support matrix (`pyproject.toml [project] requires-python` or CI matrix) |
| `*.js`, `*.ts`, `package.json` engines change | each Node version in `engines.node` / `.nvmrc` / CI matrix |
| `*.rb`, `Gemfile.lock` | each Ruby version in `.ruby-version` / CI matrix |
| `Dockerfile`, GH Actions matrix | each `runs-on` / base image listed |

If a runtime listed above is not installed locally, do not silently
skip it — note the gap in the review report ("could not test under
bash 3.2; recommend reviewer or CI verify"). Authors and reviewers
running modern interpreters consistently miss old-runtime breakage.

Keep each experiment script short and focused — one script per function,
one concern per script. Log failures clearly with input/output pairs.

### Validate bot findings in the playground

Every entry in Phase 2's `bot_findings_to_validate` queue must run
through a reproduction experiment in the playground before Phase 5
posts replies. Bots fire on heuristics, so their findings range
from precise and actionable to false-positive noise — silent skip
either misses a real issue or wastes the author's time, and silent
agreement amplifies false positives. Validation in code is the
arbiter.

For each queued bot finding:

1. **Read the bot's claim** — the comment body plus any code
   pointers (file:line, snippets, "consider X" suggestions).
2. **Reproduce in a script** — write a focused playground experiment
   that exercises the exact code path the bot flagged. If the
   finding is "this function returns the wrong value when X," call
   the function with X and compare. If the finding is "this loop
   is O(n²)," time it at growing input sizes. If the finding is
   "this regex doesn't match Y," feed it Y. Use the same
   adversarial-testing patterns as the rest of Phase 4.
3. **Classify the outcome:**

| Outcome | Definition | Phase 5 action |
|---------|------------|----------------|
| **Confirmed** | The script reproduces the failure mode the bot described. | **Skip the reply.** The bot's thread already carries the finding; a "validated locally" pile-on is noise. Only reply if the playground surfaced **new evidence the bot missed** (different reproduction angle, broader blast radius, an additional failure mode). |
| **Refuted** | The script contradicts the bot's claim — the code behaves correctly under the inputs the bot flagged. | Reply with `**Could not reproduce** — <one-line counter-evidence>` and a brief explanation of what was tested. Do NOT silently leave the thread open; the author needs the counter-signal to dismiss confidently. |
| **Inconclusive** | The script can't decisively confirm or refute (missing fixtures, the failure mode requires production-only state, the claim is style/preference rather than behavior). | Leave the thread alone. Note "inconclusive" in the Phase 4 summary so the user can decide whether to investigate further or accept the bot's verdict. |

Save each validation script under
`.review-playground/bot-findings/{bot_login}-{thread_id}.{ext}` so
the user can inspect what was actually run.

If a bot finding is **out of scope for the playground** (e.g., a
documentation/style claim that requires reading prose, not running
code), skip the script step and use Phase 3 reading-based
investigation instead — but still classify outcome and reply
accordingly. The reply policy is the same regardless of how the
verdict was reached.

**Silent skip on agreement is the default for bot threads.** A confirmed
bot finding gets no reply — the bot's thread already carries the verdict
and a duplicate "validated locally" reply just adds noise. A refuted
finding always gets a reply with counter-evidence so the author can
dismiss the bot confidently. Inconclusive findings the agent
independently flagged get the agent's own evidence; otherwise leave the
thread alone.

### Validate PR tests via mutation

For each test file in the PR, verify the tests actually detect breakage:

1. **Copy** the implementation file to `.review-playground/`.
2. **Mutate** the copy — flip a conditional, hardcode a return value,
   remove a validation check, swap two arguments in a function call.
3. **Run the PR's tests** against the mutated copy. If the tests still
   pass, they are not testing the behavior they claim to test.
4. **Report** which tests survived mutation. These are candidates for
   review comments — a test that can't detect a broken implementation
   is worse than no test (it provides false confidence).

Focus mutations on the code paths the tests claim to cover. One mutation
per experiment script. Log the mutation, the test result, and whether the
test correctly failed.

### Cross-system artifact-flow validation

When the diff touches a flow where one system **produces** an
artifact and another system **consumes** it across a process or
network boundary — CI artifact upload/download, S3/GCS object
publish + fetch, queue producer/consumer, file drop + scanner —
verify the producer's output layout matches the consumer's read
strategy. Mismatches survive unit tests because each side is
tested against its own assumed layout, not the actual on-disk /
on-wire shape.

Checks to run for every producer→consumer pair in the diff:

1. **Compare the produced path/key against the consumed path/key
   exactly.** If the producer writes `prefix/foo.ext` and the
   consumer expects flat `foo.ext`, the consumer needs to either
   recurse or include the prefix. Most artifact systems
   (Buildkite artifacts, S3 sync, `cp -r`, `tar`) preserve
   sub-directory structure on the consuming side; flat scans miss
   nested files silently.
2. **Verify recursion depth.** If the producer writes nested
   paths and the consumer uses a non-recursive scan
   (`read_dir`, `ls`, `glob('*.ext')` without `**`), the nested
   files will never be found. Migrations that swap a recursive
   tool (`find -name`) for a non-recursive one (`read_dir`,
   `Path.glob('*')`) are a common silent regression.
3. **Check the test harness mirrors production layout, not the
   consumer's scan assumption.** Tests that place fixtures at
   the path the consumer happens to scan today will pass even
   when the producer writes somewhere else. Tests must populate
   fixtures at the **producer's actual output path** for the
   given environment.
4. **Detect destructive cleanup that runs after a missed read.**
   If the consumer wipes the staging directory after attempting
   to consume (`rm -rf`, `remove_dir_all`, `shutil.rmtree`) and
   the read missed the file, the data is gone before anyone
   notices. Flag any cleanup-after-consume path that doesn't
   first verify the consume succeeded.

Build a playground experiment that **populates the staging
location with the producer's actual layout** (including any
prefixes, nested directories, or naming conventions the
producer applies) and runs the consumer against it. Tests that
only exercise the consumer's scan in isolation cannot catch
layout mismatches.

### Interface contract violations

When the PR modifies a type, interface, or API contract:

1. **Identify all consumers** of the changed contract (callers, importers,
   downstream services).
2. **Build a script** that instantiates the old contract shape and passes
   it through the new code path. Does it fail fast, or silently corrupt?
3. **Build a script** that uses the new contract shape in old consumer
   code. Does the consumer handle it, or does it break at runtime?
4. **Report** any consumer that doesn't validate its inputs — these are
   latent bugs waiting for a deployment mismatch.

### Test cases

Runnable tests (in the project's test framework) that verify the PR's behavior.
Focus on:
- Happy path — does the change work as described?
- Sad path — how does it handle failure, invalid input, missing data?
- Edge cases — boundaries, empty collections, null values, large inputs, concurrency

### HTML visualizations

When changes benefit from visual explanation — UI changes, data flow
modifications, state transitions, or a critical-change heatmap — create an
HTML file in the playground that visualizes what's happening.

### Report findings

After running experiments, summarize what you discovered:
- Confirmed behaviors
- Broken assumptions
- Surprising or unexpected results
- Things that work but seem fragile

> "Playground built at `.review-playground/`. Here's what I found: ..."

## Phase 5: Review Comments

Formulate inline review comments anchored to specific lines in the diff.

### Stay focused — no comment cap, but every comment must be actionable

There is no hard cap on comment count. The user-approval gate (Phase 6)
is the safety net against over-commenting; surface every actionable
finding and let the user prune.

What stays inline:
- Bugs the author should fix
- Concrete suggestions with a `suggestion` block when applicable
- Genuine questions about intent or behavior

What does NOT go inline:
- Restating what the diff already shows
- Generic praise for routine correctness ("nice naming", "good test")
- Pure observations the author can't act on
- Bot agreements (see "Deduplicate against existing comments")

Praise and overall verdict belong in the **review body** (Phase 6), not
inline. Inline noise dilutes the actionable signal.

### Tone

Terse and constructive. Each comment is one or two sentences of
actionable feedback. No filler, no hedging, no restating the diff.
Frame non-blockers as "candidate for a follow-up" rather than demands.

### Severity

Tag each comment with a severity prefix:

- **`blocker:`** Must be fixed before merge. Reserve for critical bugs, security
  issues, data loss risks, or broken functionality. Use sparingly.
- **`suggestion:`** Good for a follow-up change. Style nits, naming improvements,
  refactoring ideas, pedantic observations, potential optimizations.
- **`question:`** Genuine uncertainty about intent or behavior. Ask the author
  to clarify.
- **`praise:`** Reserve for inline only when calling out a non-obvious
  pattern the reviewer should learn from. Generic praise belongs in the
  review body, not as an inline thread.

**Default to `suggestion` unless something is genuinely critical.** Frame
non-blocking items as "good candidate for a follow-up" or "something to
consider in a future pass."

### Comment format

Each comment body should follow this structure:

```
**{severity}:** {The observation or concern}

{Optional: context, evidence from playground experiments, or suggested fix}
```

### Use applicable `suggestion` blocks for actionable fixes

When a comment proposes a concrete code replacement, prefer a GitHub
` ```suggestion ` fence over a language fence (` ```go `, ` ```ts `,
etc.). Suggestion fences render as a one-click "Commit suggestion"
button in the GitHub UI; language fences render as read-only code
samples the author has to copy by hand.

Rules:

- Use ` ```suggestion ` fences only when the target lines are inside
  the PR diff. Suggestions outside the diff are not applicable —
  GitHub disables the apply button.
- Anchor the comment on the exact lines being replaced. One-line
  fix → `line: <N>` + `side: "RIGHT"`. Multi-line replacement →
  `start_line` + `line` + matching `start_side`/`side` to span the
  range; both endpoints must be in the diff.
- The suggestion body must match the **exact existing whitespace**
  (tabs vs spaces, depth). Indentation drift silently breaks the
  apply button. Pre-fetch the raw lines before drafting and visually
  verify:
  ```bash
  awk 'NR>=START && NR<=END' "$FILE" | cat -A   # shows tabs as ^I
  ```
- Multiple ` ```suggestion ` blocks per comment are allowed — each
  becomes its own commit when applied.
- Reply suggestions inherit the parent's anchor; they only apply to
  replacements at the parent's line. If the fix spans different
  lines, prefer a new top-level comment with the correct multi-line
  anchor (and reference the parent thread in the body) over a reply
  with an un-applicable suggestion.
- If the lines to replace are **outside** the diff: anchor the
  comment on a nearby diff-visible line, drop the suggestion fence,
  use a plain language fence as an example, and note that the change
  must be applied manually.
- Praise / questions / pure observations do not need suggestion
  blocks.

Capture the raw target lines with their original whitespace as a
**Phase 4 prerequisite** for any finding with a concrete fix —
getting indentation wrong only manifests after the comment is
posted, when the apply button silently fails.

### Deduplicate against existing comments

**HARD RULE:** Never post a new top-level comment that duplicates an existing
review comment. Before drafting each comment, check the exclusion list from
Phase 2. A comment is a duplicate if it targets the same file and line range
AND raises the same concern — even if you discovered it independently.

Treatment depends on the original commenter's type — bot reviewers
benefit from independent verification, human reviewers do not.

**Duplicate of a human reviewer's comment:**

- **Skip it.** The existing thread already carries the human's
  voice; a second voice agreeing is noise.
- If your investigation adds **new information** the original
  reviewer missed, reply to the existing thread instead of creating
  a new comment.
- If the existing comment is **wrong or incomplete**, reply with a
  correction rather than posting a parallel comment.

**Bot reviewer comments** (commenter `user.type` == `Bot`, or login
ends in `[bot]`):

Every active bot comment was queued in Phase 2 and run through
Phase 4's "Validate bot findings in the playground" step. The
validation outcome decides the reply, not the fact of duplication:

| Phase 4 outcome | Phase 5 action |
|-----------------|----------------|
| **Confirmed** | **Skip.** Bot has it covered; a duplicate reply is noise. Reply only if the playground surfaced new evidence the bot missed. |
| **Refuted** | Reply with `**Could not reproduce** — <counter-evidence>` + brief description of what was tested. Always reply — silent skip leaves the author guessing. |
| **Inconclusive** AND agent independently flagged the same issue | Reply with the agent's own evidence + suggestion fix (the agent's verdict carries the thread). |
| **Inconclusive** AND agent did not flag it | Leave the thread alone. Note in the Phase 5 summary so the user can override. |
| **Out of scope for code validation** (style/prose claim) | Use Phase 3 reading-based verdict; reply only on refute. |

Bot-thread replies (when one is needed — refuted or new-evidence cases)
are delivered via one of the two mechanisms in Phase 6 ("Creating the
pending review"):

- **(a) folded into the review body** with an anchor reference — zero
  extra API calls; stays inside the pending checkpoint.
- **(b) live `/comments/{id}/replies` post** — requires explicit user
  opt-in at the Phase 6 prompt because it bypasses the pending-review
  checkpoint.

`in_reply_to` is **not** a valid field on draft-review comments,
so a bot reply cannot be embedded as a `comments[]` entry in the
pending-review payload. Never attempt that — it returns 422.

Never post a parallel top-level comment on the same line — the
reply (via either mechanism) preserves the no-duplicates rule
while adding the validation verdict.

When presenting the comment summary, group entries as
**Bot-validation: confirmed / refuted / inconclusive** plus
**Skipped (human duplicates)** so the user sees the full strategy
and can override individual entries.

### Validate comment positions against the diff

**HARD RULE:** Every inline comment must target a line that exists in the diff.
Lines not in the diff (unchanged code, code from merge commits) will cause a
422 "Line could not be resolved" error from the GitHub API.

Before presenting comments, parse `gh pr diff` to build the set of commentable
lines:

```bash
gh pr diff {number} > /tmp/pr-diff.txt
```

Walk the diff output to extract every `(file_path, new_file_line_number)` pair
that appears in a hunk — both `+` (added) and ` ` (context) lines are valid
targets. `-` (removed) lines are not commentable on the `RIGHT` side.

For each proposed comment, check that `(path, line)` is in the commentable set:

- **Match found:** keep the comment as-is.
- **No match, nearby line (±5) in the same hunk matches:** move the comment to
  the nearest matching line.
- **No match at all:** convert to a file-level comment using
  `"subject_type": "file"` (omit `line` and `side`), or move the observation
  into the review body with a `file:line` reference.

### Present for approval

Show a numbered summary of all proposed comments:

```
1. [blocker] src/auth.ts:42 — Session token not invalidated on logout
2. [suggestion] src/utils.ts:18 — Consider renaming `processData` to something more specific
3. [praise] src/cache.ts:91 — Nice use of LRU eviction here
4. [question] src/api.ts:33 — Is this timeout intentional or a leftover from debugging?
```

Wait for the user to review. They may approve all, edit some, or skip
individual comments.

## Phase 6: Post Review

**HARD RULE:** Never post the review on your own. The user must always either:
1. Post the review themselves from GitHub, or
2. Explicitly confirm in the conversation that they want you to post it.

Do not assume consent. Do not infer consent from earlier instructions. Every
time you are about to post, ask first and wait for explicit confirmation.

### Present and wait

After presenting the comment summary, ask with literal A/B/C labels:

> "Here are the proposed review comments. Choose:
>
> **A)** Post the pending review now (I create it; you submit on GitHub).
> **B)** Edit one or more comments — say which numbers and what to change.
> **C)** Skip one or more comments — say which numbers to drop.
>
> Reply `A` / `B` / `C` (or combine, e.g. `C: skip 2, then A`)."

Use the labels verbatim. Do not improvise alternative phrasings,
free-form bullets, or different orderings — labeled options keep
the choice unambiguous and prevent the agent from drifting into
prose alternatives. The HARD RULE above still applies: the user
must explicitly pick `A` (or its equivalent) before posting.

Wait for the user's explicit response before taking any action.

### Creating the pending review (only after user confirms)

Build the review payload and post via `gh api`:

**Important:** Do NOT include `"event": "PENDING"` in the payload — the REST
API rejects `PENDING` as an event value (422 error). Omitting `event` entirely
creates a pending (draft) review by default.

**Important:** `in_reply_to` is **not a valid field** on
`DraftPullRequestReviewComment`. The REST API rejects it with 422
(`Field is not defined on DraftPullRequestReviewComment`). Every
entry in `comments[]` must be a top-level comment with `path`,
`line`, and `side`. Bot-thread replies (per Phase 5's
"Validate bot findings" outcome) cannot ride along in the pending
review payload — choose one of:

- **(a) Inline in the review body** — add the counter-evidence note to
  the top-level review `body` referencing the bot's anchor:
  `Re: {bot} thread on {file}:{line} — Could not reproduce; <evidence>`.
  Zero extra API calls; stays inside the pending checkpoint.
- **(b) Live reply via `/comments/{id}/replies`** — posts immediately
  (not draft); requires explicit user authorization in Phase 6's prompt
  because it's a live action outside the pending review. Format:
  `gh api repos/{owner}/{repo}/pulls/{n}/comments/{parent_id}/replies --method POST -f body="..."`.

Default to (a) unless the user opted into (b) when picking option
A in the present-and-wait prompt.

### Compose the review body

The review body is **the agent's verdict on the change as a whole**, not
a summary of the inline comments. Write a concise impression of the PR,
keyed to the change's overall shape:

- **Clean, focused PR with no glaring issues:** praise the author and
  write `LGTM 🚀`. Be specific about what's strong (clear naming, tight
  tests, well-scoped change) — generic praise is worse than no praise.
- **PR is too large or mixes concerns:** call it out and recommend
  splitting into smaller PRs. Sketch the natural split lines.
- **PR has structural concerns spanning the whole change:** describe the
  pattern, not the individual instances (those go inline). E.g.,
  "logging is inconsistent across the new modules" goes in the body;
  individual missing log lines go inline.

Use emojis where they aid scanning (✅ 🚀 🛠️ 🧪 ⚠️ 📦 🎯). Keep the body
short — one to three short paragraphs.

**Always end the body with this footer (verbatim):**

```
---
This review was generated with the help of an Agent. If you find it noisy or annoying, please DM me your feedback.
```

Bot-thread counter-evidence notes (option (a) above) are folded in
before the footer, anchored as `Re: {bot} thread on {file}:{line} — …`.

### Build the payload

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  --method POST \
  --input - <<'EOF'
{
  "body": "<composed verdict — see 'Compose the review body' above — ending with the footer>",
  "comments": [
    {
      "path": "src/file.ts",
      "line": 42,
      "side": "RIGHT",
      "body": "**suggestion:** Extract this into a helper — candidate for a follow-up."
    }
  ]
}
EOF
```

Replace `{owner}/{repo}` with the actual repository and `{number}` with
the PR number.

The review stays **pending** (draft) — it is not visible to others until the
user clicks "Submit review" on GitHub or explicitly asks the agent to submit.

### After posting

Capture the `html_url` from the POST response (it points at the
pending review on GitHub) and open it in the user's browser so
they can review and submit without copy-pasting:

```bash
HTML_URL=$(gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  --method POST --input - <<'EOF'
{ ... }
EOF
  --jq .html_url)

case "$(uname -s)" in
  Darwin)  open "$HTML_URL" ;;
  Linux)   xdg-open "$HTML_URL" >/dev/null 2>&1 || true ;;
  MINGW*|MSYS*|CYGWIN*) start "" "$HTML_URL" ;;
esac
```

Always print the URL alongside the open call — terminal scrollback
and remote sessions where the browser can't launch still need the
text. Open failures are non-fatal; never block the workflow on a
browser-launch hiccup.

Confirm success:
> "Pending review created with N comments — opened at {html_url}.
> Submit on GitHub when ready."

Remind the user:
> "The `.review-playground/` directory has your experiments and test files.
> Feel free to keep exploring. Clean it up after the PR merges."

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| "review this PR" | Full 6-phase review, always asks before posting |
| "re-review this PR" | Detects prior comments, follows up on threads, then reviews new issues |
| "just investigate this PR" | Phases 1-4 only, no comments posted |

## Requirements

- `gh` CLI authenticated with repo access
- Git repository with a GitHub remote
- Shell access for running playground experiments

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn pr-review`).
