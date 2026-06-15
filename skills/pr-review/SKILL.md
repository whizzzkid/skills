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
  - Skill
  - AskUserQuestion
model: opus
effort: high
model-invocable: true
user-invocable: true
license: MIT
group: pull-request
metadata:
  author: whizzzkid
  version: '2026.06.14-193553'
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

## GitHub interaction routing

**HARD RULE:** Every `gh` read and GitHub write follows `wk-gh`:

- Scope reads per `wk-gh` Step 1–2.
- Append the canonical outbound footer from `wk-gh` Step 4 to the review body
  and every inline comment; do not invent one.

## Phase 1: Context

Determine the PR and gather context before reading files.

**If already on a PR branch:**

```bash
gh pr view --json number,title,body,baseRefName,headRefName,url,files,commits,reviews
```

**If on main/master or no PR is detected:** ask for a PR number or URL, then:

```bash
gh pr checkout <number>
```

### Verify local HEAD matches PR HEAD

Before reading files:

```bash
LOCAL_HEAD=$(git rev-parse HEAD)
PR_HEAD=$(gh pr view --json headRefOid --jq '.headRefOid')
if [ "$LOCAL_HEAD" != "$PR_HEAD" ]; then
  echo "⚠ Local HEAD ($LOCAL_HEAD) ≠ PR HEAD ($PR_HEAD). Pulling..."
  git pull --ff-only || echo "Fast-forward failed — will use gh pr diff as source of truth"
fi
```

If pull fails, use `gh pr diff` and the PR-head contents API as source of truth;
note the desync in the review summary.

### Collect context

Collect the PR title, body, linked issues, full diff, changed files, commit
history, base branch, and change size. Recommend a PR stack in the body when
the PR is large or mixes unrelated concerns.

### Extract author review focus

Parse the PR description before investigation and turn explicit asks into a
`review_focus` list:

- Capture headings/labels, direct reviewer questions, path markers, and
  self-flagged uncertainty.
- Store each ask as `{topic, files, question, severity-hint}`; use `concern`
  when the author flags correctness/security, otherwise `suggestion`.
- Drop boilerplate that is not a review ask: test-plan checkboxes, rollout
  notes, "closes #N" lines, screenshots, and automation blocks.
- If there are no asks, record `review_focus: []`.

Thread `review_focus` through later phases:

- **Phase 3:** prioritize named files/topics first while covering the full diff.
- **Phase 4:** add a runnable playground experiment per answerable ask.
- **Phase 5:** answer every ask inline or in the review body; unanswered asks
  are a review gap.

Announce before moving on:

> "Reviewing PR #N: *title* — X files changed, Y commits. Base: `{base_branch}`. Author asks: {k} focus item(s). Let me dig in."

### Detect architecture-level changes → invoke [`wk-arch-review`](../arch-review/README.md)

Run `wk-arch-review` before Phase 3 when the diff changes architecture or
design. Fold its findings into Phase 3 prioritisation, Phase 5 comments, and
the summary.

**HARD RULE — spec/design docs are unconditional triggers.** Any changed file
matching `docs/(specs|adr|arch|design|rfc)/` invokes `wk-arch-review` before
Phase 3, even for a doc-only diff.

Trigger when any holds:

- A path is an architecture/design doc: `docs/(specs|adr|arch|design|rfc)/`,
  or a filename containing `architecture`, `design`, `spec`, `rfc`, `adr`,
  `hld`, `lld`, or `tech-spec`.
- The diff adds infrastructure/topology: new service, datastore, queue/cache,
  external hot-path dependency, IaC, or deploy/runtime topology.
- The diff changes a trust boundary, auth flow, public API/contract, or a
  migration that reshapes ownership or consistency.

Invoke with the changed doc path when one changed; otherwise pass the PR number:

```
Skill(wk-arch-review, args="<changed-doc-path | PR number>")
```

Treat arch-review's high-severity findings as concerns in Phase 5, attached to
the relevant file/line or the review body when they span the change.

## Phase 2: Existing Review Comments

Fetch existing review comments, classify stale threads, optionally close the
loop on your own prior comments, and build the Phase 3/5 exclusion list.

### Fetch comments and resolution state

Retrieve root inline comments only:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments \
  --jq '.[] | {id, node_id, path, line, original_line, position, body, user: .user.login, updated_at, in_reply_to_id}'
```

Skip comments with `in_reply_to_id` set; they are replies, not thread anchors.

The REST comments endpoint carries no resolution state. On re-review, query each
thread's `isResolved` / `isOutdated` before planning loop-closure work:

```bash
gh api graphql -f query='
{ repository(owner:"{owner}", name:"{repo}") {
    pullRequest(number:{number}) {
      reviewThreads(first:100) {
        nodes { id isResolved isOutdated comments(first:1){ nodes{ path body } } }
} } } }'
```

- Annotate each thread with `isResolved` / `isOutdated`.
- Skip loop-closure work for threads already `isResolved: true`.
- Reserve follow-up for open threads, or resolved threads whose fix does not
  hold after you verify the current code.

### Identify stale comments and review bodies

A comment is stale when any holds:

- `position` is `null`.
- The file at `path` changed after the comment's `updated_at`.
- The referenced line content no longer matches the current code.

Read the current file when needed and categorize:

- **Stale (fixed):** the issue is clearly resolved.
- **Stale (unclear):** the position is outdated but the fix is not obvious.
- **Active:** the concern still applies.

Cross-check top-level review bodies against the current diff. Mark a body
`stale (superseded)` when it references files absent from the current diff or an
approach the PR no longer takes; do not carry that framing into the verdict.

### Present and resolve stale threads

**HARD RULE:** Never resolve review threads without explicit user consent.

Present the categorized list and ask which stale-fixed threads to resolve:

```
Stale comments (resolved in code):
1. [stale] src/auth.ts:42 by @reviewer — "Session token not invalidated" → Fixed in abc123

Stale comments (unclear):
2. [stale?] src/api.ts:33 by @reviewer — "Is this timeout intentional?"

Active comments:
3. [active] src/cache.ts:91 by @reviewer — "LRU size should be configurable"

Would you like me to resolve threads marked stale-fixed?
(Thread 2 will be left for manual review.)
```

After confirmation, match each thread by `path` + `line` + `body`, then resolve:

```bash
gh api graphql -f query='
  mutation($threadId: ID!) {
    resolveReviewThread(input: {threadId: $threadId}) {
      thread { isResolved }
    }
  }
' -f threadId="THREAD_NODE_ID"
```

### Summarize and build queues

Announce the intake state before investigation:

> "Found X existing review comments (Y active, Z resolved as stale). Active breakdown: A human, B bot ({bot_logins}). Carrying N active comments forward; B bot findings queued for validation."

Build two structures from active comments:

- **`bot_findings_to_validate`:** every active bot comment (`user.type == "Bot"`
  or login ending in `[bot]`). Phase 4 classifies each as `Confirmed`,
  `Refuted`, or `Inconclusive`; Phase 5 drives replies from that outcome.
- **Exclusion list:** active comments keyed by `(file, line_range, topic)` so
  Phase 3/5 do not duplicate existing concerns.

**Verify trigger wiring before accepting a bot's severity.** A mechanically
correct finding on an unwired path is not a live concern. For each bot finding,
also grep for the trigger that activates the affected path (env var, live
caller, production config, compose/CI wiring). Trigger present keeps the bot's
severity; trigger absent downgrades to "Confirmed but narrower than stated."

### Re-review follow-up

Detect if the current user has prior comments on the PR (`gh api user --jq
'.login'`). If yes, close the loop on those threads before investigating new
issues.

Classify each prior thread:

| Status | Detect | Action |
|---|---|---|
| **Fix applied** | File changed and the concern is gone | Validate in playground or by current-code reread, then draft acknowledgment and queue a plus-one reaction. |
| **Fix attempted, still wrong** | File changed but concern persists | Draft follow-up grounded in current code. |
| **Deferred to future ticket** | Author links ticket or says follow-up/separate PR/next sprint | Queue plus-one for low severity; nudge politely in this PR for concern-severity correctness/security/data-loss risks. |
| **Author asked a question** | Last reply is the author's question | Draft an answer that states the concrete decision/action required. |
| **Author pushed back** | Author disagrees or proposes an alternative | Acknowledge, agree if warranted, or restate the concern with evidence. |
| **No response** | No author reply and no code change | Leave as-is. |
| **Already resolved** | `isResolved: true` | Skip. |

**Validate claimed fixes before acknowledging.** A modified file proves an
attempt, not a fix. Reproduce the original concern against current code or
re-read the changed code until the named failure mode is gone. If the author's
reply asserts surrounding system behavior, verify that claim in source, not PR
prose.

Present follow-ups for approval, then post approved replies sequentially:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies \
  --method POST -f body="{follow_up_text}"
```

After each reply, add the queued plus-one reaction to the root comment via the
canonical reactions API. Log and skip reaction failures; they are fire-and-forget.
Resolve acknowledged-fix threads only with user consent per the hard rule above.

**Thread actions are live.** Replies, reactions, and resolutions post
immediately and cannot ride in a pending review; `in_reply_to` on draft-review
comments returns 422. Honor "let me post it myself" by drafting the full set and
posting only after explicit approval. New holistic findings still enter the
pending review in Phase 6.

After follow-ups, run the complete holistic review on the current PR state.
Dedup new findings against your own prior threads: overlapping findings become
follow-up replies, not new top-level comments.

## Phase 3: Investigation

Read every changed file in full — not just diff hunks. Understand surrounding
code, call sites, downstream consumers, and existing tests. Carry Phase 2
comments forward; annotate overlapping findings as `[COVERED]` immediately.

Identify the new and modified surface area:

- New functions, methods, classes, interfaces, and public APIs.
- Modified functions, methods, signatures, branches, return types, and callers.
- Changed interfaces, types, protocols, and API response shapes.

Build `{name, file, line, signature, parameters, status}` for each new or
modified function/method; these become Phase 4 adversarial test targets.

Be adversarial. Follow code wherever it leads: read all callers of a changed
function, evaluate new dependencies, and look for bugs, missed edge cases,
security issues, performance regressions, broken contracts, race conditions,
and inadequate error handling.

### Allowlist and privilege changes — compare against siblings

When the diff adds a security allowlist entry, permission list item, firewall
rule, capability grant, or similar privilege, compare it against existing
siblings — not against an empty list. If the new entry is strictly less
privileged than an already-present entry, say so in the review body to anchor
the security verdict in evidence.

### Read framework source when local install is unavailable

When local dependencies are missing but framework/library source is needed:

- Identify the package and exact version from the lockfile or dependency file.
- Fetch the upstream source via the GitHub contents API and base64-decode it:

  ```bash
  gh api "repos/{owner}/{repo}/contents/{path}?ref={tag-or-sha}" \
    --jq '.content' | base64 -d
  ```

- Read the fetched source like local code and quote exact lines in comments.

Do not abandon a review path because the worktree cannot install dependencies;
upstream source is authoritative.

### Audit tests and PR claims

For each test file in the diff, check whether it tests the change surface:

- Missing failure paths, invalid inputs, error conditions, or edge cases.
- Unfailable assertions on mocks, trivial getters/setters, or constants.
- Missing assertions or suspiciously low assertion counts.
- New public functions or branches with no test.
- Tautological or copy-paste tests that verify setup rather than behavior.
- Mutation-surviving tests that pass after a conditional flip, hardcoded return,
  or removed validation check.

For each gap, note what is missing and what a useful test would exercise.

Treat PR description and commit-message accuracy as a separate review surface.
Verify specific claims about line ranges, paths, counts, attributes, before/after
framing, and rationale against the actual diff. Flag mismatches as
`suggestion`-severity body notes even when the code is correct.

### Check doc relocation portability

When the diff is a doc relocation from another repo or org with no code changed,
run an adversarial read-based pass:

- Replace org-specific tooling names, command aliases, internal scripts, task
  tracker IDs, short-link prefixes, memory file names, or source-only paths that
  do not exist in the destination repo.
- Fix back-references to files, paths, or sibling docs that were not imported.
- Flag each as a `suggestion`-severity inline comment so the author can rewrite,
  gloss, or knowingly preserve the reference.

## File Access Rules

**HARD RULE:** Write and Edit tools may only target files under
`.review-playground/` in the project root, except Bash may append
`.review-playground/` to `.gitignore`. Never commit playground files.

Read, Glob, and Grep may access any path (read-only) for code investigation.

## Phase 4: Playground

Create `.review-playground/` at the repository root as an internal experiment
workspace. Never commit it.

### Environment prerequisite gate

Before running any experiment, confirm the prerequisites the diff exercises are
available: container daemon, dependency install, database, and language runtime.

If any prerequisite fails:

- Stop immediately; do not continue to Phase 5/6 with degraded coverage.
- Ask the user to fix the local environment before rerunning.
- Never mention local environment failures in GitHub surfaces.
- Say "verified locally" or "verified against upstream source"; never mention
  `.review-playground/`, playground scripts, or experiments in author-facing
  comments.

### Documentation-only diff — substitute read-based analysis

When every changed file is documentation, prompt/rule text, or non-executable
fixture data, skip scratch scripts and mutation tests. Write a read-based
adversarial analysis under `.review-playground/` instead.

- Confirm there is no runnable code path before using this escape hatch; mixed
  diffs still run the full playground for executable portions.
- Cover ambiguity, contradictions, missing cases, edge-case prompts, and fixture
  matcher behavior.
- Cross-check numeric counts in tables/enumerated claims against actual items.
- Flag committed absolute paths, home/worktree references, local-only branches,
  or personal artifacts stated as permanent facts as `concern`; fix by dropping
  the path, using a repo-relative path, or replacing it with a generic
  description.
- When a doc/config names a live code file as authoritative, read that file and
  verify the stated constraints against the current branch, not a promised
  companion PR.

Ensure the playground is ignored:

```bash
if ! grep -qxF '.review-playground/' .gitignore 2>/dev/null; then
  echo '.review-playground/' >> .gitignore
fi
```

### Scratch scripts

Write short, focused executable scripts that exercise changed code paths and
boundary behavior. One script per function or concern.

### Adversarial testing of new and modified functions

For every new or modified method/function from Phase 3, launch parallel Agent
experiments under `.review-playground/` and report results.

Cover the relevant failure modes:

- Boundary values: empty, null/nil/undefined, zero, negative, max-size,
  single-vs-many, off-by-one, first/last/one-past-end, pagination edges.
- Type confusion: wrong types, implicit coercion traps, values that satisfy type
  but violate semantic constraints.
- Input mutation: wrong, missing, extra, swapped, or out-of-range fields.
- State and ordering: use-before-init, double-init, use-after-close, async
  interleaving, cancellation.
- Fuzz: randomized inputs at growing volume to expose leaks or accumulation.
- Output contracts: return types, downstream validation, and shared-state races.

Run supported runtime matrices explicitly, not whatever is first on `PATH`:

| Diff includes | Run under |
|---|---|
| `*.sh`, `*.bash`, `Brewfile`, shebanged shell | macOS bash 3.2 and modern bash; flag bash 4+ idioms. |
| `*.py` | each Python version in `requires-python` or CI. |
| `*.js`, `*.ts`, `package.json` engines change | each Node version in `engines.node`, `.nvmrc`, or CI. |
| `*.rb`, `Gemfile.lock` | each Ruby version in `.ruby-version` or CI. |
| `Dockerfile`, GH Actions matrix | each `runs-on` / base image listed. |

If a required runtime is missing locally, do not silently skip it; note the gap
for reviewer/CI verification.

### Standalone playground when the app cannot boot

When the app cannot boot but the concern is pure framework/library logic, fetch
the upstream framework methods from GitHub, copy them verbatim into a single
script under `.review-playground/`, preserve signatures/control flow/sentinel
constants, and run the same adversarial cases with the system runtime. Cite the
upstream SHA/tag so the harness is auditable.

### Validate bot findings in the playground

Run every Phase 2 `bot_findings_to_validate` entry through a focused experiment
before replying:

1. Read the bot claim and code pointers.
2. Reproduce the exact code path in a playground script, or use reading-based
   analysis when the claim is prose/style-only.
3. Classify the outcome as `Confirmed`, `Refuted`, or `Inconclusive`.

Save scripts under `.review-playground/bot-findings/{bot_login}-{thread_id}.{ext}`.
Phase 5 uses the outcome table below; silent skip is not allowed.

### Validate PR tests via mutation

For each PR test file:

1. Copy the implementation file to `.review-playground/`.
2. Mutate the copy: flip a conditional, hardcode a return, remove validation, or
   swap arguments.
3. Run the PR's tests against the mutant.
4. Report surviving mutations as false-confidence candidates.

One mutation per experiment script. Log the mutation, result, and whether the
test correctly failed.

### Specialized validation checks

Apply these when the diff shape matches:

- **Producer→consumer artifact flow:** verify path/key match, recursion depth,
  fixture placement, cleanup-after-consume ordering, and run a layout-matching
  consumer experiment.
- **Cluster promotion/dedup:** test whether the guard checks the chosen
  representative, not just the iteration anchor; iterate in reverse and
  non-sequential order.
- **Interface contract changes:** identify consumers, then build scripts for old
  shapes through new code and new shapes through old consumers.
- **Runnable tests:** verify happy path, sad path, invalid input, missing data,
  boundaries, nulls, large inputs, and concurrency where relevant.
- **Visual explanations:** create optional HTML for UI changes, data flow, state
  transitions, or critical-change heatmaps.

### Report findings

Summarize confirmed behaviors, broken assumptions, surprising results, and
things that work but seem fragile.

> "Playground built at `.review-playground/`. Here's what I found: ..."

## Phase 5: Review Comments

Formulate actionable inline review comments anchored to specific diff lines.

### Comment posture, tone, and severity

There is no hard comment cap. Surface every actionable finding and let the user
prune in the GitHub draft UI.

Inline comments are for bugs, concrete suggestions, and genuine intent/behavior
questions. Do not inline diff narration, generic praise, pure observations, or
bot agreements. Praise and overall verdict belong in the review body.

Default to approving with concerns, not blocking. Never use "blocker" in
author-facing text; use "concern" or "limitation". Keep comments encouraging,
constructive, and one to two sentences.

Tag each comment with a severity prefix:

- **`concern:`** critical bugs, security issues, data loss risks, or broken
  functionality. Use sparingly; frame as approve-with-concerns, not a merge
  block.
- **`suggestion:`** follow-up style, naming, refactoring, pedantic, or
  optimization ideas.
- **`question:`** genuine uncertainty about intent or behavior.
- **`praise:`** non-obvious patterns worth learning from; generic praise stays
  in the body.

Default to `suggestion` unless something is genuinely critical.

### Comment format and suggestion blocks

Use this body shape:

```
**{severity}:** {The observation or concern}

{Optional: context, evidence, or suggested fix}
```

When proposing a concrete code replacement, prefer a GitHub ` ```suggestion `
fence over a language fence. Use suggestion fences only for target lines inside
the PR diff.

- Anchor on the exact lines being replaced; one-line fixes use `line` +
  `side: "RIGHT"`, multi-line fixes use `start_line` + `line` + matching sides.
- Match exact existing whitespace; indentation drift silently breaks the apply
  button. Pre-fetch raw target lines and verify:

  ```bash
  awk 'NR>=START && NR<=END' "$FILE" | cat -A   # shows tabs as ^I
  ```

- Multiple suggestion fences per comment are allowed; each becomes its own
  commit when applied.
- A single suggestion fence must target one contiguous range. Split non-adjacent
  fixes into separate comments.
- Reply suggestions inherit the parent anchor; use a new top-level comment when
  the fix spans different lines.
- If target lines are outside the diff, anchor on a nearby diff-visible line,
  drop the suggestion fence, use a plain language example, and note manual
  application.
- Praise, questions, and pure observations do not need suggestion blocks.

### Deduplicate against existing comments

**HARD RULE:** Never post a new top-level comment that duplicates an existing
review comment. Before drafting each comment, check the Phase 2 exclusion list.
A duplicate targets the same file/line range and raises the same concern.

Human duplicate handling:

- Validate the human concern against current code.
- Skip a parallel comment when it holds; annotate your related comment with
  `Also fix concerns from @{reviewer}` when useful.
- Reply to the existing thread when you add new information or disagree with
  evidence.

Bot duplicate handling:

| Phase 4 outcome | Phase 5 action |
|---|---|
| **Confirmed** | Silent skip at thread and body level. The bot thread already stands; do not narrate validation. |
| **Confirmed but narrower than stated** | Reply with a scope note bounding the reproduced case versus the bot's broader claim. |
| **Refuted** | Reply with `**Could not reproduce** — <counter-evidence>` and what was tested. |
| **Inconclusive** + agent found same issue | Reply with the agent's evidence and suggested fix. |
| **Inconclusive** + agent did not flag it | Leave the thread alone and surface it in the summary for override. |
| **Out of scope for code validation** | Use reading-based verdict; reply only on refute. |

**HARD RULE:** A per-thread bot reply or body anchor is justified only when you
have new evidence beyond confirming the bot's exact claim. Pure Confirmed
outcomes get silent skip.

Do not narrate bot validation in the body. If a confirmed bot finding matters,
address its substance, not the fact of confirmation. Reserve body anchors and
live replies for refuted, narrowed, or agent-backed inconclusive cases.

Use one mechanism for justified bot replies:

- Fold into the review body with `Re: {bot} thread on {file}:{line} — …`; no
  extra API call.
- Live `/comments/{id}/replies` post; requires explicit user opt-in because it
  bypasses the pending-review checkpoint.

`in_reply_to` is not valid on draft-review comments and returns 422. Never embed
bot replies in the pending-review `comments[]` payload.

### Validate comment positions against the diff

**HARD RULE:** Every inline comment must target a line that exists in the diff.
Lines not in the diff cause a 422 "Line could not be resolved" error.

Before presenting comments, parse `gh pr diff` to build commentable lines:

```bash
gh pr diff {number} > /tmp/pr-diff.txt
```

Both `+` and context lines are valid targets; removed lines are not commentable
on the `RIGHT` side. For each proposed comment:

- **Match found:** keep the comment.
- **Nearby line (±5) in the same hunk:** move to the nearest matching line.
- **No match:** convert to a file-level comment (`"subject_type": "file"`, omit
  `line` and `side`) or move the observation to the review body with a
  `file:line` reference.

### Answer author review-focus items

For each `review_focus` item from Phase 1, address it before presenting comments:

- Local answer: inline comment with `question` reframed as an answer, or
  `suggestion` / `concern` when an issue surfaces.
- Cross-cutting answer: add `Re: <author's question>` to the review body with
  verdict and evidence.
- Unanswerable from the diff: ask the specific clarifying question inline.

Mark each item as `answered: inline | body | open` for the approval summary.

### Present for approval

Show a numbered summary of all proposed comments:

```
1. [concern] src/auth.ts:42 — Session token not invalidated on logout
2. [suggestion] src/utils.ts:18 — Consider renaming `processData` to something more specific
3. [praise] src/cache.ts:91 — Nice use of LRU eviction here
4. [question] src/api.ts:33 — Is this timeout intentional or a leftover from debugging?
```

Wait for the user to review. They may approve all, edit some, or skip individual
comments.

## Phase 6: Post Review

**HARD RULE:** Auto-create a pending (draft) review immediately after the Phase 5
summary unless the user explicitly said "don't post", "wait", or "let me review
first" before posting. The user submits the draft from the GitHub UI; never call
an endpoint that submits, approves, or requests changes.

- Omit `event` entirely. Do not send `event: "PENDING"`; REST rejects it with
  422.
- Print the review `html_url` and `Submit on GitHub when ready.`
- Edits/skips after the summary happen in the GitHub draft UI, not via another
  terminal gate.

### Creating the pending review

Build the payload and post via `gh api`:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  --method POST \
  --input - <<'EOF'
{
  "body": "<composed verdict ending with the canonical footer>",
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

Every `comments[]` entry must be top-level with `path`, `line`, and `side`.
`in_reply_to` is not valid on `DraftPullRequestReviewComment`; REST rejects it
with 422. Bot-thread replies cannot ride in the pending payload. Use one of:

- Fold into the review body before the footer:
  `Re: {bot} thread on {file}:{line} — Could not reproduce; <evidence>`.
- Live `/comments/{id}/replies` post; requires explicit user opt-in before the
  summary because it posts immediately.

### Compose the review body

The body is the verdict on the change as a whole, not an investigation log or a
summary of inline comments. Keep verification rationale in terminal output.

- **HARD RULE — LGTM is one line.** When there are no concerns, the body is one
  line max (`LGTM 🚀` or equivalent) followed only by the footer.
- If the PR is too large or mixes concerns, recommend a PR stack and sketch the
  natural split lines.
- If structural concerns span the change, describe the pattern in the body and
  leave individual instances inline.
- Always end with the canonical outbound footer from `wk-gh` Step 4. Apply the
  same footer to every inline comment at payload-render time.
- Fold bot-thread counter-evidence before the footer; only refuted or new
  evidence cases earn a per-thread anchor.

Use emojis only where they aid scanning. Outside the one-line LGTM case, keep
the body to one to three short paragraphs.

Never emit these review-body antipatterns:

- Blast-radius pre-judgment before `wk-arch-review` runs.
- Process meta-commentary about skills or tools invoked.
- Structurally-obvious findings such as "no code concerns" for doc-only diffs.
- Diff narration that restates visible test counts, names, regexes, or lists.
- Bot re-narration such as "Validated N findings from {bot} — all reproduced."

### After posting

Capture `html_url` from the POST response and open it in the user's browser:

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

Always print the URL alongside the open call; browser launch failures are
non-fatal.

**Pending-review verification: trust `path` + `body`, not `line`.** GitHub
returns `line: null` and `start_line: null` for inline comments on pending
reviews until submission. This is normal API behavior, not a payload error.

- Verify pending-review comments via `path` and a body prefix match.
- Do not treat `line: null` from `/pulls/{n}/reviews/{id}/comments` as failure.
- After user submission, the same endpoint returns resolved line values.

Confirm success:

> "Pending review created with N comments — opened at {html_url}.
> Submit on GitHub when ready."

Remind the user:

> "The `.review-playground/` directory has your experiments and test files.
> Feel free to keep exploring. Clean it up after the PR merges."

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| "review this PR" | Full 6-phase review; creates a pending draft after the summary unless the user explicitly pauses. |
| "re-review this PR" | Detects prior comments, follows up with consent, then reviews new issues. |
| "just investigate this PR" | Phases 1-4 only; no review comments created. |

## Requirements

- `gh` CLI authenticated with repo access
- Git repository with a GitHub remote
- Shell access for running playground experiments

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn pr-review`).
