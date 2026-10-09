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
  version: "2026.10.09-171327"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# Self-Review

Post inline review comments on your own PR — document design decisions,
non-obvious logic, critical context for human reviewers. Not a bug hunt.

## HARD RULES

- **HARD RULE:** All GitHub reads/writes follow [`wk-gh`](../gh/README.md).
- **HARD RULE: self-review is always a pending review** — stage via `/pulls/{n}/reviews` with `event` omitted.
  Never use `gh api .../pulls/{n}/comments` (publishes immediately, skips
  human-in-the-loop). Holds for single notes too.
- **HARD RULE — never fabricate a quantitative claim** — cite a verifiable source or state
  "conservative"; drop unsourced numbers.

## Step 0: Route through `wk-gh`

`Skill(wk-gh)` before any `gh` command. Precondition for Step 1 — skipping violates
the GitHub-routing HARD RULE (no org scoping, no footer).

## Step 0.5: Pre-flight POST permission

Check `gh api repos/.*/pulls/.*/reviews` in settings; no match → warn early.
**HARD RULE: author the payload with the Write tool** to `/tmp/agent/gh/{owner}/{repo}/pulls/{n}/self-review.json` — never inline
prose in bash. Blocked → hand user the one-liner. See
[permission-preflight](references/permission-preflight.md).

## Step 1: Gather Context

```bash
gh pr view --json number,title,url,baseRefName,headRefName
gh pr diff
```

Read every changed file in full.

## Step 2: Identify Comment-Worthy Changes

- **Comment on:** non-obvious decisions, security paths, behavioral changes,
  rejected alternatives, performance implications, tradeoffs.
- **Skip:** formatting, renames, boilerplate, anything obvious at a glance.
- **Markdown preview:** `.md` file + >50 added lines → inline comment with rendered
  preview link. Reject backtick-wrapped URLs before POST.
- **Arch-level change:** read `wk-arch-review` recorded verdict
  (`.review-playground/.arch-cleared-{SHA}.json`); fold findings into self-review
  notes. No record → note for the gate; skip silently when no trigger.

## Steps 2.5–2.7: Pre-post audits

See [pre-post-audit](references/pre-post-audit.md):
- **2.5** Dedupe against existing self-review threads.
- **2.6** Scan sibling code paths for same flaw class.
- **2.7** Verify code-comment claims against implementation; fix stale ones.

## Step 3: Present Comments

Numbered summary: `1. path:line — rationale`. **HARD RULE — never ask "want me to
post this?".** Opt-out only before the summary ("don't post"/"wait"); then proceed directly to Step 4; GitHub's Submit button is the human checkpoint.

## Step 3.5: Validate hunk positions

**HARD RULE:** Before POSTing, verify each comment's `line` falls inside a `@@` hunk
range (else `422 "Line could not be resolved"`). Out-of-hunk → snap to nearest or
convert to file-level comment (omit `line` + `side`). `Read` line numbers ≠ hunk lines.

```bash
BASE=$(gh pr view --json baseRefName --jq .baseRefName)
git diff "origin/$BASE...HEAD" -- "$FILE" | grep -E '^@@' | sed -E 's/.*\+([0-9]+),?([0-9]*).*/\1 \2/'
```

## Step 4: Post Comments

Post immediately after Step 3 — no approval prompt.

- Finish all commit-producing actions before staging; re-fetch `headRefOid` before
  writing the payload.
- **One pending review per user** — existing pending → preserve bodies (Write tool),
  DELETE, fold valid comments into new payload, POST. Treat 422 as recovery trigger.
- Verify `position` == `original_position` after posting; mismatch → delete and re-stage.

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews \
  --method POST \
  --input /tmp/agent/gh/{owner}/{repo}/pulls/{number}/self-review.json
```

Payload via Write tool only (Step 0.5 HARD RULE — never a heredoc).

Omit `event` → pending. `"event": "PENDING"` is invalid (422). `commit_id` = HEAD SHA.

## Step 4.5: Merge-gate submission

PR about to merge → submit any pending self-review with `event: "COMMENT"`.
Surface "N comments still in draft — submitting before merge." Pending-review-only
HARD RULE unchanged — still *created* as pending; this step *submits* it at the merge boundary.

## Updating an Existing Self-Review

New commits on a PR with existing self-review:

1. Resolve stale comments via `gh api`.
2. HEAD rewritten → confirm `commit_id` still matches `headRefOid`; mismatch →
   preserve bodies (Write tool), DELETE, re-stage against new HEAD. Also check
   `position` vs `original_position` (pending comments report `line: null`).
3. Add new comments for critical changes in the new commits.

---

## Post-Completion

Invoke `wk-learn self-review`.
