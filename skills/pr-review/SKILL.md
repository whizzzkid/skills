---
name: wk:pr-review
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
  version: '1.7.0'
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

**HARD RULE: Never resolve review threads without explicit user consent.**
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

After the user confirms, query for thread node IDs via GraphQL:

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

Announce what was found before moving on:

> "Found X existing review comments (Y active, Z resolved as stale). Carrying
> N active comments forward into investigation."

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
using the same reply API as `wk:pr-resolve`:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies \
  --method POST -f body="{follow_up_text}"
```

Resolve threads where fixes were acknowledged (with user consent per the
existing hard rule). Leave all other threads open.

**After follow-ups are posted, proceed to Phase 3** to investigate new
issues. The follow-up replies count toward the 6-comment cap in Phase 5.

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

**HARD RULE: Write and Edit tools may ONLY target files under
`.review-playground/` in the project root. Never write or edit files
outside of `.review-playground/`. Never commit playground files.**

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

**Edge cases:** Boundary values, empty inputs, null/undefined/nil, zero,
negative numbers, max-size collections, single-element vs many, unicode,
special characters, whitespace-only strings, very long strings.

**Boundary arithmetic:** Off-by-one errors, fence-post problems, integer
overflow/underflow, floating-point precision loss, array index bounds
(first, last, one-past-end), loop termination conditions, pagination
boundaries (page 0 vs page 1, last page, beyond last page).

**Type confusion and coercion:** Pass wrong types to every parameter —
string where number expected, array where object expected, number where
boolean expected, null where non-nullable expected. Test implicit
coercion traps: `"0"` vs `0` vs `false`, empty string vs null, `[]` vs
`{}`. For typed languages, test with values that satisfy the type but
violate semantic constraints (e.g., negative age, future birth date,
email without `@`).

**Input mutation:** Take valid inputs and mutate one field at a time —
wrong type, missing field, extra field, swapped arguments, out-of-range
values. Confirm the function fails gracefully rather than silently
producing wrong output.

**State and ordering:** For stateful code (classes, modules with
initialization, connection pools, caches), call methods in wrong order —
use before init, double-init, use after close, concurrent access from
multiple callers. For async code, test interleaving and cancellation.

**Fuzz testing:** Generate randomized inputs (random strings, numbers,
nested objects, deeply nested structures) and call the function in a loop.
Look for crashes, hangs, uncaught exceptions, or inconsistent results.
Vary the volume — 1 call, 10 calls, 1000 calls — to expose resource
leaks or accumulation bugs.

**Output validation:** Verify return values match expected types and
contracts. Mutate the function's output in downstream consumers to see
if callers validate what they receive. For modified functions, verify
that existing callers still receive the shape they expect.

Keep each experiment script short and focused — one script per function,
one concern per script. Log failures clearly with input/output pairs.

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

### Comment cap

**HARD RULE: Limit each review pass to a maximum of 6 comments.** If
investigation and playground testing surface more than 6 distinct issues,
stop experimenting. Rank findings by severity (blockers first, then
suggestions, then questions) and post only the top 6. Mention in the
review body that additional issues were found and will be covered in a
follow-up review after this round is addressed.

This prevents overwhelming the author. Short, focused reviews get faster
turnaround. Multiple passes are better than one massive dump.

### Tone

Be encouraging and constructive. The goal is to help the author improve the
code, not to block the PR. Acknowledge good work. Frame suggestions as
opportunities, not demands.

### Severity

Tag each comment with a severity prefix:

- **`blocker:`** Must be fixed before merge. Reserve for critical bugs, security
  issues, data loss risks, or broken functionality. Use sparingly.
- **`suggestion:`** Good for a follow-up change. Style nits, naming improvements,
  refactoring ideas, pedantic observations, potential optimizations.
- **`question:`** Genuine uncertainty about intent or behavior. Ask the author
  to clarify.
- **`praise:`** Call out good patterns, clever solutions, or well-handled edge
  cases. Reinforce good work.

**Default to `suggestion` unless something is genuinely critical.** Frame
non-blocking items as "good candidate for a follow-up" or "something to
consider in a future pass."

### Comment format

Each comment body should follow this structure:

```
**{severity}:** {The observation or concern}

{Optional: context, evidence from playground experiments, or suggested fix}
```

### Deduplicate against existing comments

**HARD RULE: Never post a new top-level comment that duplicates an existing
review comment.** Before drafting each comment, check the exclusion list from
Phase 2. A comment is a duplicate if it targets the same file and line range
AND raises the same concern — even if you discovered it independently.

For duplicates:
- **Skip it.** The existing thread already covers the issue.
- If your investigation adds **new information** the original reviewer missed,
  reply to the existing thread instead of creating a new comment.
- If the existing comment is **wrong or incomplete**, reply with a correction
  rather than posting a parallel comment.

When presenting the comment summary, include a "Skipped" section listing
intentionally omitted duplicates so the user can override if needed.

### Validate comment positions against the diff

**HARD RULE: Every inline comment must target a line that exists in the diff.**
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

**HARD RULE: Never post the review on your own.** The user must always either:
1. Post the review themselves from GitHub, or
2. Explicitly confirm in the conversation that they want you to post it.

Do not assume consent. Do not infer consent from earlier instructions. Every
time you are about to post, ask first and wait for explicit confirmation.

### Present and wait

After presenting the comment summary, ask:
> "Here are the proposed review comments. You can:
> - Edit or skip individual comments
> - Post the review yourself from GitHub after I create it as pending
> - Tell me to 'post it' and I'll create the pending review for you
>
> What would you like to do?"

Wait for the user's explicit response before taking any action.

### Creating the pending review (only after user confirms)

Build the review payload and post via `gh api`:

**Important:** Do NOT include `"event": "PENDING"` in the payload — the REST
API rejects `PENDING` as an event value (422 error). Omitting `event` entirely
creates a pending (draft) review by default.

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  --method POST \
  --input - <<'EOF'
{
  "body": "Reviewing with the help of {agent-name}, please let me know if it's annoying or noisy or not useful.",
  "comments": [
    {
      "path": "src/file.ts",
      "line": 42,
      "side": "RIGHT",
      "body": "**suggestion:** Consider extracting this into a helper — good candidate for a follow-up."
    }
  ]
}
EOF
```

Replace `{owner}/{repo}` with the actual repository, `{number}` with the PR
number, and `{agent-name}` with the name of the agent in use (e.g., "Claude
Code", "Cursor"). If unknown, use "an AI coding assistant."

The review stays **pending** (draft) — it is not visible to others until the
user clicks "Submit review" on GitHub or explicitly asks the agent to submit.

### After posting

Confirm success:
> "Pending review created with N comments. Go to {pr-url} to review and
> submit when ready."

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
