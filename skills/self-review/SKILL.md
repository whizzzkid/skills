---
name: wk-self-review
description: >-
  Post inline self-review comments on your own PR to document design decisions,
  non-obvious choices, and critical context for human reviewers. Use when a PR
  is ready for self-review or when wk-pr invokes this skill before its CI poll.
allowed-tools:
  - "Bash(gh pr view:*)"
  - "Bash(gh pr diff:*)"
  - "Bash(gh api repos:*)"
  - Read
  - Grep
  - Glob
  - AskUserQuestion
  - Write
  - Skill
model: sonnet
effort: medium
model-invocable: true
user-invocable: true
license: MIT
group: pull-request
metadata:
  author: whizzzkid
  version: "2026.08.28-023637"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# Self-Review

Post inline review comments on your own PR → help human reviewers understand
design decisions, non-obvious logic, critical context. Not an adversarial bug
hunt — documentation for reviewers.

## GitHub interaction routing

**HARD RULE:** All GitHub reads/writes follow `wk-gh`:

- Read-side: org scoping per `wk-gh` Step 1–2.
- Write-side: append canonical outbound footer per `wk-gh` Step 4 to every
  inline comment body posted via the pending review. Inject at payload-render
  time → no `comments[]` entry ships footer-less.

## Pending review only

**HARD RULE:** Self-review is always a pending review — multiple inline comments
batched under a single GitHub review the user submits manually after inspection.

- Never use direct `gh api repos/.../pulls/{n}/comments`. The raw comments
  endpoint publishes immediately → skips the human-in-the-loop checkpoint that
  is the entire point of this skill.
- Holds even for a single note. One design-note comment still goes through the
  pending-review flow.
- If reaching for `gh api .../comments` (or any equivalent that publishes), stop
  → invoke this skill from the top → stage via `/pulls/{n}/reviews` with `event`
  omitted (pending state).
- "make a note in self-review" / "leave a quick comment on the PR" → still a
  self-review, still goes through this flow.

## Step 0: Route GitHub I/O through `wk-gh` (MANDATORY)

Invoke `wk-gh` before any `gh` command or GitHub API call. Do not proceed to
Step 1 until `wk-gh` confirms org scoping + canonical outbound footer staged for
payload-render.

```
Skill(wk-gh)
```

- Skipping violates the GitHub-routing HARD RULE → posts ship without org
  scoping and without the canonical footer.
- The prose HARD RULE does not gate execution; this numbered step does. Step 0
  is a precondition for Step 1, not advice.

## Step 0.5: Pre-flight the pending-review POST permission

Check `gh api repos/.*/pulls/.*/reviews` in settings before building the payload.
No match → warn early. **HARD RULE: author the payload with the Write tool** to
`/tmp/agent/gh/{owner}/{repo}/pulls/{n}/self-review.json`, never inline review
prose in a bash command. Blocked POST → hand the user the one-line `gh api …
--input <file>`. See [permission-preflight](references/permission-preflight.md).

## Step 1: Gather Context

```bash
gh pr view --json number,title,url,baseRefName,headRefName
gh pr diff
```

Read every changed file in full — not just diff hunks. Understand what changed,
why, and what alternatives existed.

## Step 2: Identify Comment-Worthy Changes

**DO comment on:**

- New logic and non-obvious decisions
- Security-sensitive code paths
- Behavioral changes and potential gotchas
- Design decisions where alternatives were rejected
- Performance implications that aren't obvious from the diff
- Tradeoffs accepted (and why)

**Do NOT comment on:**

- Formatting or linting fixes
- Renames or structural moves
- Boilerplate or configuration
- Anything a reviewer can understand at a glance

Goal is signal, not noise. Fewer high-quality comments beat many trivial ones.

**HARD RULE — never fabricate a quantitative claim.** A comment that justifies a
threshold (timeout, buffer size, retry count, dimension) with a specific size,
latency, or performance figure must cite a verifiable source (a benchmark,
release artifact, CI log, or measurement in the repo) or state the value is
conservative without inventing a number. A plausible-sounding figure with no
source behind it is fabrication — drop the number, keep the rationale.
"Conservative for any reasonable response" is honest; an invented range is not.

### Markdown preview link for large diffs

**Important:** Changed file with `.md` extension AND diff adds >50 lines → stage
an inline comment on the first in-hunk line with a clickable markdown link:

> Rendered preview — easier to read than the diff for large markdown changes:
> [`{path}`](https://github.com/{owner}/{repo}/blob/{branch}/{path})

- Resolve `{branch}` from `gh pr view --json headRefName --jq .headRefName`.
- Snap `line` to a hunk-valid position per Step 3.5 before POSTing.
- Immediately before Step 4's POST, reject any final payload containing a
  backtick-wrapped URL:

  ```bash
  if command grep -nE '`https?://|https?://[^`[:space:]]+`' "{payload-file}"; then
    echo "BLOCKED: preview URL wrapped in backticks" >&2
    exit 1
  fi
  ```

  Any match blocks the POST; keep backticks in the link label only.

### Architecture-level change → invoke [`wk-arch-review`](../arch-review/README.md)

Diff introduces/alters the project's architecture → seed self-review context with
arch-review findings. The human reviewer needs design rationale + known gotchas up
front.

- **Trigger and one-dispatch rule: apply that skill's contract**, including its
  mechanical detector — authored docs and doc-only diffs both count.
- **Read, do not dispatch.** Consume the recorded verdict
  (`.review-playground/.arch-cleared-{SHA}.json`). No record → the artifact has not
  reached its gate: note it for the gate rather than starting a run here.
- Fold the result in: post a top-level self-review note linking the design
  rationale; add inline comments on the components arch-review flagged (SPOFs,
  unhappy paths, risky assumptions) so reviewers see them in context.
- Skip silently when no trigger matches.

## Steps 2.5–2.7: Pre-post audits

Three audits run between identifying comment-worthy changes and presenting them.
See [pre-post-audit](references/pre-post-audit.md) for full details.

- **2.5 Reconcile against existing self-review** — dedupe against prior self-review
  threads; drop or cross-reference overlapping rationale. Audit stale threads after
  approach pivots.
- **2.6 Parallel-path completeness** — scan sibling code paths for the same flaw
  class; fold fixes into the same commit or note the audit was performed.
- **2.7 Verify code-comment claims** — check inline comments/docstrings making
  behavioral claims against the current implementation; fix stale comments in this
  PR rather than leaving review notes.

## Step 3: Present Comments

Show a numbered summary of proposed comments:

```
1. <module>/handler.ts:42 — Chose HMAC over RSA here because tokens are short-lived
2. <module>/store.ts:91 — This eviction strategy trades memory for latency
3. <module>/routes.ts:15 — Breaking change: removed deprecated v1 endpoint
```

**HARD RULE — never ask "want me to post this?".** Posting the pending (draft)
review is unconditional after the summary; GitHub's Submit button is the human
checkpoint, not a terminal prompt. The user opts out by saying "don't post" /
"wait" / "let me edit first" before the summary is presented. After the summary,
proceed directly to Step 4 — no confirmation round-trip.

## Step 3.5: Validate every comment line lies inside a diff hunk

**HARD RULE:** Before POSTing, verify each comment's `line` falls inside a `@@`
hunk range in `git diff <base>...HEAD -- <path>`. The API rejects out-of-hunk
lines with `422 "Line could not be resolved"`.

- Resolve `<base>` dynamically: `gh pr view --json baseRefName --jq .baseRefName`.
- Extract `+N,M` ranges from each `@@` header for the file; commentable set =
  union of `[N, N+M-1]` per hunk on the new-file side.
- For each proposed comment, check `line ∈ commentable_set`. If not:
  - Snap to the nearest in-hunk line, **or**
  - Convert to a file-level comment by omitting both `line` and `side` in the API
    payload.
- Absolute file line numbers from `Read` output are not commentable unless they
  also appear in a diff hunk — never assume the two are the same.

```bash
BASE=$(gh pr view --json baseRefName --jq .baseRefName)
git diff "origin/$BASE...HEAD" -- "$PATH_TO_FILE" \
  | grep -E '^@@' | sed -E 's/.*\+([0-9]+),?([0-9]*).*/\1 \2/'
```

## Step 4: Post Comments

Post the pending review immediately after Step 3's summary — no approval prompt.
Create a PENDING review via GitHub API:

- **Important:** Finish every known commit-producing action in the current round
  before staging — the adversarial-review gate fix loop is one; its fixes
  rewrite files the pending review anchors to.
- Re-fetch `headRefOid` immediately before writing the payload; a changed HEAD
  voids all gathered anchors and requires rebuilding them.
- **Pre-POST pending-review check** — GitHub allows one pending review per user
  per PR; a second POST returns HTTP 422. Before creating a new review, query
  for a self-authored pending review (same query shape as Step 4.5). If found:
  preserve its comment bodies to a temp file via Write tool, DELETE it, fold
  still-valid comments into the new payload, then POST. Treat the 422 as a
  recovery trigger (query → delete → re-POST), not a retry candidate.
- After posting, verify each comment's `position` matches `original_position`;
  mismatch → delete the pending review and re-stage against current HEAD per
  "Updating an Existing Self-Review."

Write the payload with the **Write tool** (Step 0.5 HARD RULE — never a heredoc,
since the body's prose becomes bash command text):

```json
{
  "commit_id": "{head_sha}",
  "comments": [
    {
      "path": "src/file.ts",
      "line": 42,
      "side": "RIGHT",
      "body": "Design note: chose X over Y because..."
    }
  ]
}
```

Then POST the file — the only bash in this step, and it carries no review prose:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  --method POST \
  --input /tmp/agent/gh/{owner}/{repo}/pulls/{number}/self-review.json
```

- Omit `event` → pending (draft) review. `"event": "PENDING"` is not a valid enum
  value and returns HTTP 422.
- Valid event values (`APPROVE`, `REQUEST_CHANGES`, `COMMENT`) are for
  *submitting* a review, not creating one.
- Set `commit_id` to the PR's HEAD SHA to anchor the review.
- Review stays **pending** (draft) until the user submits it on GitHub.

## Step 4.5: Merge-gate submission

**When the PR is about to merge** (wk-pr-merge invocation, explicit merge
intent, or the session proceeding past CI toward merge), any still-pending
self-authored review must be submitted — invisible draft notes that land after
merge never helped any reviewer.

- Query pending self-authored reviews:
  ```bash
  gh api repos/{owner}/{repo}/pulls/{n}/reviews \
    --jq '[.[] | select(.state == "PENDING")] | {count: length, ids: [.[].id]}'
  ```
- Count > 0 → submit each with `event: "COMMENT"`:
  ```bash
  gh api repos/{owner}/{repo}/pulls/{n}/reviews/{id}/events \
    -f event=COMMENT
  ```
- Surface "N self-review comments still in draft — submitting before merge"
  rather than merging silently over invisible drafts.
- This does not change the pending-review-only HARD RULE — self-review is still
  *created* as pending. This step *submits* it at the merge boundary so design
  notes are visible.

## Updating an Existing Self-Review

New commits pushed to a PR that already has self-review comments:

1. **Resolve stale comments** that no longer apply — use `gh api` to resolve
   review threads or delete outdated comments.
2. **HEAD rewritten since the review was staged? Delete and re-post the pending
   review.** A pending review's `commit_id` pins it to a HEAD SHA; ANY event that
   rewrites the pushed HEAD orphans the review and every inline comment (the
   comments endpoint returns empty, and GitHub does not migrate them) — a
   self-initiated force-push OR a host-initiated auto-rebase when the base branch
   merges and the child is retargeted onto new SHAs. Before treating a staged
   review as live, confirm its `commit_id` still equals the current HEAD
   (`gh pr view --json headRefOid`); on mismatch, run
   `DELETE /pulls/{n}/reviews/{id}`, then re-stage a fresh pending review
   anchored to the new HEAD SHA.
   - **`commit_id` is only one drift axis — check the comments too.** Anchors rot
     while a review is still nominally current, so compare each comment's
     `position` against its `original_position`. A mismatch on either axis means
     delete and re-stage.
   - A pending comment reports `line: null`, so `position`/`original_position`
     are the only usable drift signal — never gate comment staleness on `line`.
   - **Preserve every comment body before the DELETE.** Write them to a temp file
     with the **Write tool** first: the delete becomes safe, and the re-staged
     version can correct any bullet that went factually stale meanwhile.
3. **Add new comments** for any critical changes introduced by the new commits.
4. Present the updated comment set for approval before posting.

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| Invoked by `wk-pr` | Full self-review flow before its CI poll |
| "self-review this PR" | Manual invocation on current PR |
| New commits pushed | Update existing comments, resolve stale ones |
| PR about to merge | Submit any still-pending self-review (Step 4.5) |

---
