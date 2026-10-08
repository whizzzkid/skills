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
  - Write
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
  version: "2026.08.20-190631"
  model:
    openai: gpt-5.6-sol
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

### HARD RULE — optional reviewers require current-task opt-in

- Never launch an optional local/external model reviewer unless the user
  requests it in this task. Existing CI output is evidence, not authorization
  for a fresh run.
- Phase-owned dispatches below remain mandatory: `wk-adversarial-review`,
  `wk-arch-review`, and `wk-design-review`.

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
base branch, change size. Recommend a PR stack in the body, sketching split lines,
when PR is large or mixes unrelated concerns.

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

**The trigger and the one-dispatch rule live in that skill's contract — apply it,
do not restate it.** Run its mechanical detector over `gh pr diff <number>
--name-only`; a hit means a review is required, doc-only diffs included.

- Record covering this HEAD (`.review-playground/.arch-cleared-{SHA}.json`) → consume
  it; never re-run what the author's gate already ran.
- No record → dispatch once, and only as
  `Skill(wk-arch-review, args="<changed-doc-path | PR number>")`; a general-purpose
  subagent does not satisfy the gate. Fold findings into Phase 3/4; high-severity
  become Phase 4 concerns.

**HARD RULE — spec-doc claims about existing code are Unverified until checked.**
Treat every claim about existing code (named structs/fields, "reuses X", "~N-line
port") as Unverified until grep/read confirms it — delegate the batch to one
subagent; re-verify a posted finding the moment a later result contradicts it.

### UX/design changes → consult [`wk-design-review`](../design-review/README.md)

When `gh pr diff <n> --name-only` matches a design surface (styles, `design`,
`tokens`, `theme`, `/components/`, `.stories.`, `a11y`) → `Skill(wk-design-review,
args="consult <n>")` before Phase 3; fold blocker/major findings into Phase 4. May
trigger alongside `wk-arch-review` (UX vs system layer).

## Phase 2: Existing Review Comments

Fetch existing review comments, classify stale threads, optionally close the loop
on your own prior comments, build the Phase 3/4 exclusion list.

### Fetch comments and resolution state

Use the shared queries from
[`references/graphql-unresolved-threads.md`](references/graphql-unresolved-threads.md)
— REST for comment bodies, GraphQL for `isResolved`/`isOutdated`. Skip
loop-closure for `isResolved: true` threads; reserve follow-up for open threads
or resolved threads whose fix does not hold after verifying current code.

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
confirmation, match each by `path` + `line` + `body`, then resolve using the
mutation in [`references/graphql-unresolved-threads.md`](references/graphql-unresolved-threads.md).

### Summarize and build queues

Announce intake state (active/stale counts, human/bot breakdown). Build:
- **`bot_findings_to_validate`:** active bot comments → Phase 3 classifies each.
- **Exclusion list:** `(file, line_range, topic)` → prevents Phase 3/4 dupes.

Re-scope bot severity: grep for trigger (absent → narrower); trace one hop
downstream for amplified impact (→ broader).

### Re-review follow-up

Detect prior comments by the current user (`gh api user --jq '.login'`). If
present, close the loop on those threads before investigating new issues.

- **Fix applied** (file changed, concern gone) → validate against current code,
  draft acknowledgment + queue plus-one reaction.
- **Fix attempted but wrong** (concern persists) → draft follow-up grounded in
  current code.
- **Deferred to ticket** → plus-one for low severity; nudge in-PR for concerns.
- **Author question/pushback** → answer with concrete action or restate with
  evidence.
- **No response / Already resolved** → leave as-is / skip.

**Validate before acknowledging** — a modified file proves an attempt, not a fix.
Reproduce the concern against current code. Present follow-ups for approval, then
post via `POST /pulls/{n}/comments/{id}/replies`. Add plus-one reactions
(fire-and-forget). Resolve fix threads only with user consent.

**Thread actions are live** — replies/reactions/resolutions post immediately, not
in a pending review (`in_reply_to` on draft comments → 422). Honor "let me post
it myself". Dedup new findings against prior threads.

## Phase 3: Adversarial Investigation — delegate to [`wk-adversarial-review`](../adversarial-review/README.md)

**Read before dispatching.** A clearance record covering this HEAD
(`.review-playground/.cleared-{HEAD_SHA}.json`) → consume it; never re-run what the
author's completion gate already ran. No record — the usual case when reviewing
someone else's PR — dispatch once:

```
Skill(wk-adversarial-review)
```

It resolves the base from the PR, runs its full sweep catalog, dispatches a fresh
adversarial subagent over the complete diff, validates runtime claims in
`.review-playground/`, and returns structured findings (`severity`, `file`, `line`,
`category`, `finding`, `rationale`, `fix-sketch`) plus a verdict — substituting
read-based analysis for docs/prose/compression diffs.

On the returned findings:

- Prioritize `review_focus` files/topics; ensure every focus item is investigated.
- Fold in any `wk-arch-review` findings from Phase 1.
- Annotate findings overlapping the Phase 2 exclusion list as `[COVERED]` so
  Phase 4 does not duplicate them.
- Map adversarial-review `blocker` findings to Phase 4 `concern` candidates;
  `suggestion` / `question` pass through unchanged.
- Reconcile bidirectionally: drop or revise own pre-assembled candidates the agent's results refute — agent verdicts override static reasoning.

Verdict is advisory here: pr-review always proceeds to compose comments — never
blocks the author or posts from the gate.

**HARD RULE — logic-bearing findings need an empirical pass.** When the change
contains executable logic (matcher, grader, parser, state machine, algorithm) —
including findings returned from the Phase 1 `wk-arch-review` path — drive the real
implementation or a minimal faithful harness with adversarial/edge inputs and
record PASS/FAIL before Phase 4. Never compose comments from un-run reasoning; a
finding you could have executed but only argued is unverified.

**HARD RULE — check a figure's derivation before contradicting it.** Grep the
artifact for derivation rules; read timing constants' full comment blocks. Refuted
but derivation unstated → clarity suggestion, not a drop.

**Environmental vs PR failures:** failing line not in the diff → environmental.
Re-run under the project's pinned interpreter.

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

**HARD RULE — attribute agent evidence explicitly.** Use "My agent verified/ran
`<X>` and found `<Y>`", never bare "I verified" — the reviewer posts on the
user's identity.

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

- **Human duplicate:** validate against current code; skip when it holds; reply
  only with new information or evidenced disagreement.
- **Bot duplicate:** drive from Phase 3 outcome per
  [`references/bot-finding-validation.md`](references/bot-finding-validation.md).
  Key rule: only reply with *new evidence* beyond confirming the bot's claim;
  pure Confirmed → silent skip.

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

### Recheck the reviewed head

- Immediately before each review create/recreate POST, fetch `headRefOid`; compare with Phase 1 `PR_HEAD`.
- Mismatch → do not post; resolve anchors from PR-HEAD blob (`git show <PR_HEAD>:file`), never the working tree; revalidate findings, refresh `PR_HEAD`, rebuild full payload.
- Set payload `commit_id` to `PR_HEAD`; never rely on latest-commit default.

### Create the pending review

Write the payload with the **Write tool**, never a heredoc (`wk-self-review` Step 0.5):

```json
{
  "commit_id": "<PR_HEAD>",
  "body": "<composed verdict ending with the canonical footer>",
  "comments": [
    { "path": "src/file.ts", "line": 42, "side": "RIGHT",
      "body": "**suggestion:** Extract into a helper." }
  ]
}
```

```bash
gh api repos/{owner}/{repo}/pulls/{n}/reviews --method POST --input <file>
```
Every `comments[]` entry must be top-level with `path`, `line`, `side`.

### Add comments to an existing pending review

- `POST /pulls/{n}/comments` on an existing pending review fails with 422 "user_id can only have one pending review per pull request" — GitHub allows no append.
- Delete the pending review, then recreate with the full comment set in one `reviews` POST:

  ```bash
  gh api repos/{owner}/{repo}/pulls/{number}/reviews/{review_id} --method DELETE
  ```

- Rebuild every comment from scratch — pending-review comments return `line: null` and cannot be round-tripped.

### Follow-up finding after a review is posted

Gate the mechanism on review state. No review yet → pending draft (above). A review
already posted/submitted + a new finding → post a **direct live** inline comment
(`POST /pulls/{n}/comments` with commit_id + path + line) or a thread reply
(`/comments/{id}/replies`); never open a second pending review for one incremental
finding. Reserve a fresh pending review for an explicitly requested new complete pass.

**HARD RULE — a distinct finding anchors at its own line.** Post it as its own
comment on the diff line its subject lives on — never buried in a reply on a
thematically-adjacent thread (thread-relatedness ≠ line-relatedness; a buried
finding has no discoverable anchor). Reserve replies for continuing the *same*
finding's thread (adding evidence to it).

### Compose the review body

The body is the verdict on the change as a whole, not an investigation log.

- **HARD RULE — verdict-first opener.** `LGTM 🚀` (clean, one line + footer),
  `LGTM, one minor nit`, or `Approving with concerns — <risk>`. Ban
  praise-adjective openers ("Solid", "great") — reads as AI filler.
- **Body must not restate inline findings.** Carry verdict + change-spanning
  concerns only; at most a one-line pointer to a key thread.
- Apply `wk-gh` footer at render time. Fold bot counter-evidence before footer.
- Never emit: blast-radius pre-judgment, process meta-commentary, diff narration,
  bot re-narration, structurally-obvious findings for doc-only diffs.

### After posting

**HARD RULE — `open` on every create/recreate**, even if the POST response fails
to parse (re-query `html_url`). Print the URL; browser failures are non-fatal.

**Pending-review verification:** trust `path` + `body`, not `line` — GitHub
returns `line: null` for pending comments until submission.

Confirm success:

> "Pending review created with N comments — opened at {html_url}. Submit on GitHub when ready."

## Requirements

- `gh` CLI authenticated with repo access
- Git repository with a GitHub remote
- `wk-adversarial-review` available (owns investigation + playground)

---
