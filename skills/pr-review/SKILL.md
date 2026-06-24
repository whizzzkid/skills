---
name: wk-pr-review
description: >-
  Thorough, critical code review of a GitHub pull request. Use when asked to
  review a PR, review code changes, help review this PR, create review comments,
  or investigate a pull request. Reads existing review comments, resolves stale
  threads, delegates deep investigation to wk-adversarial-review, and creates
  pending review comments via GitHub API.
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
  - Read
  - Grep
  - Glob
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
  version: '2026.06.24-202743'
  model:
    openai: o3
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# PR Review

Thorough code review of a GitHub PR → gather context + existing-comment state →
delegate deep adversarial investigation and playground validation to
[`wk-adversarial-review`](../adversarial-review/README.md) → map returned findings
into encouraging but critical inline comments posted as a pending GitHub review.

## GitHub interaction routing

**HARD RULE:** Every `gh` read and GitHub write follows `wk-gh`:

- Scope reads per `wk-gh` Step 1–2.
- **Invoke `wk-gh` (Skill tool) before drafting any review body or inline
  comment.** The footer text lives in its Step 4 and is not reproducible from
  memory — load the skill to extract it. "Do not invent one" means load `wk-gh`,
  **not** skip the footer; omitting the footer is a rule violation, not a fallback.
- Append the extracted canonical outbound footer to the review body and every
  inline comment.

## Phase 1: Context

Determine PR and gather context before reading files.

**If already on a PR branch:**

```bash
gh pr view --json number,title,body,baseRefName,headRefName,url,files,commits,reviews
```

**If on main/master or no PR is detected:** ask for a PR number or URL, then
`gh pr checkout <number>`.

### Verify local HEAD matches PR HEAD

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

Collect PR title, body, linked issues, full diff, changed files, commit history,
base branch, change size. Recommend a PR stack in the body when PR is large or
mixes unrelated concerns.

### Extract author review focus

Parse PR description before investigation → turn explicit asks into a
`review_focus` list:

- Capture headings/labels, direct reviewer questions, path markers, self-flagged
  uncertainty as `{topic, files, question, severity-hint}`; use `concern` when
  author flags correctness/security, else `suggestion`.
- Drop boilerplate that is not a review ask: test-plan checkboxes, rollout notes,
  "closes #N" lines, screenshots, automation blocks.
- No asks → record `review_focus: []`.

Thread `review_focus` through later phases: Phase 3 prioritizes named files/topics
first; Phase 4 answers every ask inline or in body — unanswered asks are a review
gap.

Announce before moving on:

> "Reviewing PR #N: *title* — X files changed, Y commits. Base: `{base_branch}`. Author asks: {k} focus item(s). Let me dig in."

### Detect architecture-level changes → invoke [`wk-arch-review`](../arch-review/README.md)

Run `wk-arch-review` before Phase 3 when diff changes architecture or design →
fold findings into Phase 3 prioritisation, Phase 4 comments, and summary.

**HARD RULE — spec/design docs are unconditional triggers.** Any changed file
matching `docs/(specs|adr|arch|design|rfc)/` invokes `wk-arch-review` before
Phase 3, even for a doc-only diff.

Also trigger when any holds:

- Filename contains `architecture`, `design`, `spec`, `rfc`, `adr`, `hld`, `lld`,
  or `tech-spec`.
- Diff adds infrastructure/topology: new service, datastore, queue/cache, external
  hot-path dependency, IaC, or deploy/runtime topology.
- Diff changes a trust boundary, auth flow, public API/contract, or a migration
  that reshapes ownership or consistency.

Invoke with changed doc path when one changed; else pass PR number:
`Skill(wk-arch-review, args="<changed-doc-path | PR number>")`. Treat high-severity
findings as Phase 4 concerns.

## Phase 2: Existing Review Comments

Fetch existing review comments, classify stale threads, optionally close the loop
on your own prior comments, build the Phase 3/4 exclusion list.

### Fetch comments and resolution state

Retrieve root inline comments only (skip entries with `in_reply_to_id` — replies,
not thread anchors):

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments \
  --jq '.[] | {id, node_id, path, line, original_line, position, body, user: .user.login, updated_at, in_reply_to_id}'
```

REST comments endpoint carries no resolution state. On re-review, query each
thread's `isResolved` / `isOutdated` before planning loop-closure work:

```bash
gh api graphql -f query='
{ repository(owner:"{owner}", name:"{repo}") {
    pullRequest(number:{number}) {
      reviewThreads(first:100) {
        nodes { id isResolved isOutdated comments(first:1){ nodes{ path body } } }
} } } }'
```

Skip loop-closure for threads already `isResolved: true`. Reserve follow-up for
open threads, or resolved threads whose fix does not hold after verifying current
code.

### Identify stale comments and review bodies

A comment is stale when any holds: `position` is `null`; file at `path` changed
after comment's `updated_at`; or referenced line content no longer matches current
code. Read the current file when needed and categorize as **stale (fixed)**,
**stale (unclear)**, or **active**.

Cross-check top-level review bodies against current diff. Mark a body `stale
(superseded)` when it references absent files or an abandoned approach; do not
carry that framing into the verdict.

### Present and resolve stale threads

**HARD RULE:** Never resolve review threads without explicit user consent.

Present the categorized list and ask which stale-fixed threads to resolve. After
confirmation, match each by `path` + `line` + `body`, then resolve:

```bash
gh api graphql -f query='
  mutation($threadId: ID!) {
    resolveReviewThread(input: {threadId: $threadId}) { thread { isResolved } }
  }
' -f threadId="THREAD_NODE_ID"
```

### Summarize and build queues

Announce the intake state:

> "Found X existing review comments (Y active, Z resolved as stale). Active breakdown: A human, B bot ({bot_logins}). Carrying N active comments forward; B bot findings queued for validation."

Build two structures from active comments:

- **`bot_findings_to_validate`:** every active bot comment (`user.type == "Bot"`
  or login ending in `[bot]`). Phase 3 classifies each `Confirmed` / `Refuted` /
  `Inconclusive`; Phase 4 drives replies from that outcome.
- **Exclusion list:** active comments keyed by `(file, line_range, topic)` so
  Phase 3/4 do not duplicate existing concerns.

**Re-scope a bot's severity in both directions.** A mechanically correct finding
on an unwired path is not a live concern: grep for the trigger that activates the
affected path (env var, live caller, production config, compose/CI wiring); trigger
absent → downgrade to "Confirmed but narrower than stated." Conversely, trace one
hop downstream for amplified impact — a referenced file/URL/symbol that does not
resolve, a value that reaches a user-facing surface — since the bot's own test gap
can hide it; impact beyond the bot's framing → upgrade to "Confirmed but broader."

### Re-review follow-up

Detect prior comments by the current user (`gh api user --jq '.login'`). If
present, close the loop on those threads before investigating new issues.

| Status | Detect | Action |
|---|---|---|
| **Fix applied** | File changed, concern gone | Validate, then draft acknowledgment + queue a plus-one reaction. |
| **Fix attempted, still wrong** | File changed, concern persists | Draft follow-up grounded in current code. |
| **Deferred to ticket** | Author links ticket / says follow-up | Queue plus-one for low severity; nudge in-PR for concern-severity risks. |
| **Author asked a question** | Last reply is author's question | Draft an answer stating the concrete action required. |
| **Author pushed back** | Author disagrees / proposes alternative | Acknowledge, agree if warranted, or restate with evidence. |
| **No response** | No reply, no code change | Leave as-is. |
| **Already resolved** | `isResolved: true` | Skip. |

**Validate claimed fixes before acknowledging.** A modified file proves an
attempt, not a fix. Reproduce the original concern against current code until the
named failure mode is gone. Verify any asserted system behavior in source, not PR
prose.

Present follow-ups for approval, then post approved replies sequentially:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies \
  --method POST -f body="{follow_up_text}"
```

After each reply, add the queued plus-one reaction to the root comment; log and
skip reaction failures (fire-and-forget). Resolve acknowledged-fix threads only
with user consent.

**Thread actions are live.** Replies, reactions, resolutions post immediately and
cannot ride in a pending review; `in_reply_to` on draft-review comments returns
422. Honor "let me post it myself" by drafting the full set and posting only after
approval. New holistic findings still enter the pending review in Phase 5. Dedup
new findings against your own prior threads: overlapping findings become follow-up
replies, not new top-level comments.

## Phase 3: Adversarial Investigation — delegate to [`wk-adversarial-review`](../adversarial-review/README.md)

Hand the checked-out PR to the adversarial-review engine and consume its findings
rather than re-deriving them:

```
Skill(wk-adversarial-review)
```

It resolves the base from the PR, runs the full mechanical sweep catalog,
dispatches a fresh adversarial subagent over the complete diff, validates
runtime-behavior claims in `.review-playground/` (runtime matrix, mutation tests,
standalone upstream-source harness, specialized producer/consumer, cluster,
interface-contract, and allowlist checks), and returns structured findings
(`severity`, `file`, `line`, `category`, `finding`, `rationale`, `fix-sketch`)
plus a verdict. For docs/prose/compression diffs it substitutes read-based
analysis (gate-survival-by-substance, count cross-checks, relocation portability).

On the returned findings:

- Prioritize `review_focus` files/topics; ensure every focus item is investigated.
- Fold in any `wk-arch-review` findings from Phase 1.
- Annotate findings overlapping the Phase 2 exclusion list as `[COVERED]` so
  Phase 4 does not duplicate them.
- Map adversarial-review `blocker` findings to Phase 4 `concern` candidates;
  `suggestion` / `question` pass through unchanged.

Verdict is advisory here: pr-review always proceeds to compose comments — never
blocks the author or posts from the gate.

### Discriminate environmental failures from PR findings

Before treating a local test/command failure as a PR finding:

- Check whether the failing line is in the diff. A failure far from changed lines
  is a strong tell it is environmental, not PR-introduced.
- Confirm the interpreter/runtime matches the project's pinned version
  (`mise`/`.tool-versions`/CI config), not whatever is first on `PATH`; re-run under
  the pinned version before reporting (mirrors the `wk-adversarial-review` runtime
  matrix).

### Validate bot findings

Route each Phase 2 `bot_findings_to_validate` entry through the same engine: pass
the bot's claim and code pointers to the adversarial subagent (or a reading-based
analysis for prose/style-only claims) and classify the outcome `Confirmed` /
`Refuted` / `Inconclusive`. Phase 4 uses the outcome table; silent skip is not
allowed.

## Phase 4: Review Comments

Formulate actionable inline comments anchored to specific diff lines.

### Posture, tone, and severity

No comment cap. Surface every actionable finding; let the user prune in the GitHub
draft UI. Inline comments are for bugs, concrete suggestions, genuine
intent/behavior questions — not diff narration, generic praise, pure observations,
or bot agreements (those belong in the body).

Default to approving with concerns, not blocking. Never use "blocker" in
author-facing text; use "concern" or "limitation". Keep comments encouraging,
one to two sentences. Tag each with a severity prefix:

- **`concern:`** critical bugs, security, data loss, broken functionality. Use
  sparingly; frame as approve-with-concerns.
- **`suggestion:`** style, naming, refactoring, optimization. *(Default.)*
- **`question:`** genuine uncertainty about intent or behavior.
- **`praise:`** non-obvious patterns worth learning from; generic praise stays in
  the body.

### Comment format and suggestion blocks

Body shape: `**{severity}:** {observation}` then optional context/evidence/fix.

When proposing a concrete replacement, prefer a GitHub ` ```suggestion ` fence
over a language fence, only for target lines inside the PR diff:

- Anchor on exact lines replaced; one-line fixes use `line` + `side: "RIGHT"`,
  multi-line use `start_line` + `line` + matching sides.
- Match exact existing whitespace — indentation drift silently breaks the apply
  button. Verify: `awk 'NR>=START && NR<=END' "$FILE" | cat -A` (shows tabs as `^I`).
- A single fence targets one contiguous range; split non-adjacent fixes into
  separate comments. Reply suggestions inherit the parent anchor.
- Target lines outside the diff → anchor a nearby diff-visible line, drop the
  fence, use a plain example, note manual application.

### Deduplicate against existing comments

**HARD RULE:** Never post a new top-level comment that duplicates an existing
review comment (same file/line range + same concern). Check the Phase 2 exclusion
list before drafting each comment.

- **Human duplicate:** validate against current code; skip a parallel comment when
  it holds (optionally annotate `Also fix concerns from @{reviewer}`); reply to
  the thread only with new information or evidenced disagreement.
- **Bot duplicate:** drive from the Phase 3 outcome:

| Phase 3 outcome | Phase 4 action |
|---|---|
| **Confirmed** | Silent skip at thread and body level. |
| **Confirmed but narrower** | Reply with a scope note bounding the reproduced case. |
| **Confirmed but broader** | Reply with the amplified impact as new evidence (e.g. a referenced target that 404s). |
| **Refuted** | Reply `**Could not reproduce** — <counter-evidence>` and what was tested. |
| **Inconclusive** + agent found it | Reply with the agent's evidence and fix. |
| **Inconclusive** + agent did not | Leave the thread; surface in the summary for override. |

**HARD RULE:** A per-thread bot reply or body anchor is justified only with new
evidence beyond confirming the bot's exact claim. Pure Confirmed outcomes get
silent skip; never narrate bot validation. Justified replies use one mechanism:
fold into the body as `Re: {bot} thread on {file}:{line} — …` (no extra call), or
a live `/comments/{id}/replies` post (requires explicit user opt-in — it bypasses
the pending-review checkpoint). `in_reply_to` is invalid on draft-review comments
(422); never embed bot replies in the pending `comments[]` payload.

### Validate comment positions against the diff

**HARD RULE:** Every inline comment must target a line that exists in the diff.
Lines not in the diff cause a 422 "Line could not be resolved" error.

Build commentable lines from `gh pr diff {number}`. Both `+` and context lines are
valid `RIGHT`-side targets; removed lines are not. Per proposed comment: keep on
exact match; move to the nearest matching line within ±5 in the same hunk; else
convert to a file-level comment (`"subject_type": "file"`, omit `line`/`side`) or
move to the body with a `file:line` reference.

### Answer author review-focus items

Per `review_focus` item: answer locally via an inline comment (a `question`
reframed as an answer, or `suggestion`/`concern` when an issue surfaces), add
`Re: <question>` to the body for cross-cutting answers, or ask a specific
clarifying question inline when unanswerable from the diff. Mark each `answered:
inline | body | open`.

### Present for approval

Show a numbered summary of all proposed comments:

```
1. [concern] src/auth.ts:42 — Session token not invalidated on logout
2. [suggestion] src/utils.ts:18 — Rename `processData` to something specific
3. [praise] src/cache.ts:91 — Nice use of LRU eviction here
4. [question] src/api.ts:33 — Is this timeout intentional?
```

Wait for the user to review. They may approve all, edit some, or skip individual
comments.

## Phase 5: Post Review

**HARD RULE:** Auto-create a pending (draft) review immediately after the Phase 4
summary unless the user explicitly said "don't post", "wait", or "let me review
first". The user submits the draft from the GitHub UI; never call an endpoint that
submits, approves, or requests changes.

- Omit `event` entirely. Do not send `event: "PENDING"`; REST rejects it with 422.
- Print the review `html_url` and `Submit on GitHub when ready.`
- Edits/skips after the summary happen in the GitHub draft UI.

### Create the pending review

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  --method POST \
  --input - <<'EOF'
{
  "body": "<composed verdict ending with the canonical footer>",
  "comments": [
    { "path": "src/file.ts", "line": 42, "side": "RIGHT",
      "body": "**suggestion:** Extract this into a helper — candidate for a follow-up." }
  ]
}
EOF
```

Every `comments[]` entry must be top-level with `path`, `line`, `side`.
`in_reply_to` is invalid on `DraftPullRequestReviewComment` (422); bot-thread
replies cannot ride in the pending payload (fold into the body, or live-post with
opt-in).

### Compose the review body

The body is the verdict on the change as a whole, not an investigation log.

- **HARD RULE — LGTM is one line.** No concerns → body is one line max (`LGTM 🚀`
  or equivalent) plus the footer.
- Recommend a PR stack and sketch split lines if PR is too large or mixes concerns.
- Describe change-spanning structural concerns in the body; leave instances inline.
- Always end with the canonical outbound footer from `wk-gh` Step 4; apply the same
  footer to every inline comment at payload-render time.
- Fold bot counter-evidence before the footer; only refuted/new-evidence cases earn
  a per-thread anchor.

Use emojis only where they aid scanning; outside LGTM, keep to one to three short
paragraphs. Never emit: blast-radius pre-judgment before `wk-arch-review` runs;
process meta-commentary about skills/tools; structurally-obvious findings ("no code
concerns" for doc-only diffs); diff narration; bot re-narration.

### After posting

Capture `html_url` from the POST response and open it:

```bash
case "$(uname -s)" in
  Darwin)  open "$HTML_URL" ;;
  Linux)   xdg-open "$HTML_URL" >/dev/null 2>&1 || true ;;
  MINGW*|MSYS*|CYGWIN*) start "" "$HTML_URL" ;;
esac
```

Always print the URL alongside the open call; browser-launch failures are
non-fatal.

**Pending-review verification: trust `path` + `body`, not `line`.** GitHub returns
`line: null` / `start_line: null` for pending-review inline comments until
submission — normal API behavior, not a payload error. Verify via `path` and a body
prefix match. After submission the same endpoint returns resolved lines.

Confirm success:

> "Pending review created with N comments — opened at {html_url}. Submit on GitHub when ready."

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| "review this PR" | Full review; delegates investigation to wk-adversarial-review; creates a pending draft after the summary unless the user pauses. |
| "re-review this PR" | Detects prior comments, follows up with consent, then reviews new issues. |
| "just investigate this PR" | Phases 1-3 only; no review comments created. |

## Requirements

- `gh` CLI authenticated with repo access
- Git repository with a GitHub remote
- `wk-adversarial-review` available (owns investigation + playground)

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn pr-review`).
