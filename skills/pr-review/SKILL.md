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
  version: "2026.10.09-171327"
  model:
    openai: gpt-5.6-sol
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# PR Review

Gather context → delegate to [`wk-adversarial-review`](../adversarial-review/README.md) → post encouraging but critical inline comments as a pending GitHub review.

**HARD RULE:** All GitHub reads/writes follow [`wk-gh`](../gh/README.md). Invoke it (Skill tool) before drafting any review body or comment; footer goes on the body and every inline comment.

**HARD RULE — optional reviewers require current-task opt-in.** Never launch an optional local/external model reviewer unless the user requests it in this task; existing CI output is evidence, not authorization. Phase-owned dispatches remain mandatory: `wk-adversarial-review`, `wk-arch-review`, `wk-design-review`.

## Phase 1: Context

**On a PR branch:**

```bash
gh pr view --json number,title,body,baseRefName,headRefName,url,files,commits,reviews
```

**On main/no PR:** ask for number/URL, then `gh pr checkout`.

### Verify local HEAD

Compare `git rev-parse HEAD` vs `gh pr view --json headRefOid --jq '.headRefOid'`.
Mismatch → `git pull --ff-only`; pull fails → use `gh pr diff` as source of
truth; note desync in summary.

### Collect context

PR title, body, linked issues, full diff, changed files, commits, base, size.
Recommend stack when large or mixing concerns.

### Review focus

Parse description for explicit asks → `review_focus` list of `{topic, files,
question, severity-hint}`. Drop boilerplate. Thread through Phase 3 (prioritize)
and Phase 4 (answer every ask — unanswered = gap).

Announce: > "Reviewing PR #N: *title* — X files, Y commits. Base: `{base}`. Author asks: {k}."

### Architecture and design detection

**Architecture:** [`wk-arch-review`](../arch-review/README.md) detector over
`gh pr diff <n> --name-only`. Clearance at
`.review-playground/.arch-cleared-{SHA}.json` → consume; else
`Skill(wk-arch-review, args="<path | PR>")`. Fold findings into Phase 3/4.

**HARD RULE — spec-doc claims about existing code are Unverified.** Named structs/fields,
"reuses X", "~N-line port" → grep/read to confirm; delegate batch to one subagent.
Re-verify a posted finding the moment a later result contradicts it.

**Design:** diff touches styles/tokens/theme/components/stories/a11y →
`Skill(wk-design-review, args="consult <n>")` before Phase 3.

## Phase 2: Existing Review Comments

Fetch, classify stale threads, build Phase 3/4 exclusion list. Use
[`references/graphql-unresolved-threads.md`](references/graphql-unresolved-threads.md)
— REST for bodies, GraphQL for `isResolved`/`isOutdated`.

**Stale when:** `position` null; file changed after `updated_at`; line content
mismatches. Categorize: **stale (fixed)**, **stale (unclear)**, **active**.
Bodies referencing absent files → **stale (superseded)**.

**HARD RULE:** Never resolve threads without explicit user consent. Present list,
confirm, match each by `path`+`line`+`body`, resolve via GraphQL mutation.

**Build queues:** `bot_findings_to_validate` (active bot comments → Phase 3) and
exclusion list `(file, line_range, topic)` → prevents dupes. Re-scope bot
severity: grep trigger + one hop downstream.

### Re-review follow-up

Detect prior comments by current user (`gh api user --jq '.login'`). Close the
loop before investigating new issues:

- **Fix applied** → validate against current code, draft acknowledgment.
- **Wrong fix** → follow-up grounded in current code.
- **Deferred** → plus-one for low; nudge for concerns.
- **Pushback** → answer with evidence or restate.
- **No response / resolved** → skip.

Modified file proves attempt, not fix. Thread actions are live (not pending
review). Dedup against prior threads.

## Phase 3: Adversarial Investigation

Clearance at `.review-playground/.cleared-{HEAD_SHA}.json` → consume; else
dispatch `Skill(wk-adversarial-review)`. Returns structured findings + verdict.

On findings:
- Prioritize `review_focus` files/topics.
- Fold `wk-arch-review` findings from Phase 1.
- Mark exclusion-list overlaps `[COVERED]`.
- Map `blocker` → Phase 4 `concern`; `suggestion`/`question` pass through.
- Agent verdicts override static reasoning — drop/revise candidates the results
  refute.

**HARD RULE — logic-bearing findings need empirical proof.** Executable logic
(incl. `wk-arch-review` findings) → drive the real implementation or a faithful
harness with adversarial inputs; record PASS/FAIL before Phase 4. Never compose
comments from un-run reasoning.

**HARD RULE — check derivation before contradicting a figure.** Grep the
artifact for its derivation rule; read a timing constant's whole comment block
before replacing it. Refuted but
derivation unstated → clarity suggestion, not drop. Failing line not in diff →
environmental.

**Bot findings:** route each through same engine → `Confirmed` / `Refuted` /
`Inconclusive`. Silent skip forbidden.

## Phase 4: Review Comments

No comment cap — surface every actionable finding. Inline: bugs, suggestions,
genuine intent/behavior questions. Not: narration, generic praise, bot agreements
(body only). Default approve-with-concerns; never "blocker" in author-facing
text — use "concern"/"limitation". One to two sentences.

Severity: **`concern:`** critical/security/data-loss (sparingly);
**`suggestion:`** style/naming/refactoring (default); **`question:`** genuine
uncertainty; **`praise:`** non-obvious patterns (generic → body).

### Comment format

Body: `**{severity}:** {observation}` + optional context/evidence/fix.

**HARD RULE — attribute agent evidence:** "My agent ran `<X>` and found `<Y>`",
never bare "I verified" — in inline comments and body. Bare first-person only
for the human's own posture.

Prefer ` ```suggestion ` fences for concrete replacements on diff lines:
- Match exact whitespace — verify with `cat -A`.
- One fence = one contiguous range; split non-adjacent fixes.
- Lines outside diff → anchor nearby diff line, plain example, note manual apply.

### Dedup and position validation

**HARD RULE — no duplicates** (same file/line range + same concern). Check
Phase 2 exclusion list. Human dup → skip if holds; reply only with new info or
evidenced disagreement. Bot dup → Phase 3 outcome per
[`references/bot-finding-validation.md`](references/bot-finding-validation.md);
Confirmed → silent skip.

**HARD RULE — valid positions.** Every comment targets a diff line. `+` and
context = valid `RIGHT`; removed = not. ±5 same hunk → move; else file-level
or body.

### Review focus and presentation

Answer every `review_focus` item inline or body `Re: <question>`. Mark each
`answered: inline | body | open`.

Present numbered summary: `1. [concern] src/auth.ts:42 — description`. Wait for
user approval.

## Phase 5: Post Review

**HARD RULE:** Auto-create pending review after Phase 4 unless user said "don't
post"/"wait"/"let me review first". User submits from GitHub UI; never call
submit/approve/request-changes. Omit `event` entirely (422
on `"PENDING"`).

### Recheck reviewed head

Before each POST, fetch `headRefOid` vs Phase 1 `PR_HEAD`. Mismatch → do not
post; resolve anchors from `git show <PR_HEAD>:file`; revalidate; rebuild. Set
`commit_id` to `PR_HEAD`.

### Create pending review

Write payload with **Write tool** (never heredoc, per `wk-self-review` Step 0.5):

```json
{
  "commit_id": "<PR_HEAD>",
  "body": "<verdict ending with canonical footer>",
  "comments": [
    { "path": "src/file.ts", "line": 42, "side": "RIGHT",
      "body": "**suggestion:** Extract into a helper." }
  ]
}
```

```bash
gh api repos/{owner}/{repo}/pulls/{n}/reviews --method POST --input <file>
```

### Append to existing pending review

GitHub allows no append — delete review, recreate with full comment set. Pending
comments return `line: null`; rebuild from scratch.

### Follow-up after posted review

Live inline comment (`POST /pulls/{n}/comments`) or thread reply
(`/comments/{id}/replies`). Never second pending review for one finding.
**HARD RULE — distinct findings anchor at their own line** — own comment on
the subject's diff line, never buried in a reply on an adjacent thread. Replies
only continue the *same* finding.

### Review body

**HARD RULE — verdict-first opener.** `LGTM 🚀` (clean), `LGTM, one minor nit`,
or `Approving with concerns — <risk>`. Ban praise-adjective openers.
**HARD RULE — LGTM is one line:** no concerns → one-line body plus footer. Body must
not restate inline findings. Apply `wk-gh` footer. Never emit: process
meta-commentary, diff narration, bot re-narration.

### After posting

**HARD RULE — open URL on every create/recreate**, whether or not the POST
response parsed; parse failure → re-query for `html_url`, never drop the open. Trust `path`+`body`, not
`line` for verification.

> "Pending review with N comments — {html_url}. Submit on GitHub when ready."

## Requirements

- `gh` CLI authenticated with repo access
- Git repository with a GitHub remote
- `wk-adversarial-review` available (owns investigation + playground)

---

## Post-Completion

Invoke `wk-learn pr-review`.
