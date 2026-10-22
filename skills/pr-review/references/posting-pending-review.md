# Posting the pending review

## Recheck reviewed head

Before each POST, fetch `headRefOid` vs Phase 1 `PR_HEAD`. Match → post with `commit_id` = `PR_HEAD`. Mismatch →
do not post the built payload; re-derive it at the new head (`NEW`):

1. Fetch `NEW`; `git diff <PR_HEAD> <NEW>`. `PR_HEAD` not an ancestor of `NEW` (force-push/rebase) → map it to its
   rebased equivalent first per `wk-adversarial-review`'s `references/clearance-lineage.md`; a raw two-dot diff
   across a rebase spans every base-branch change.
2. Each finding whose hunk the delta touches: fixed → drop; changed → re-run its probe (logic) or re-read (static),
   then revise or drop. Untouched findings survive as-is.
3. New code in the delta → review at the current mode's depth, or list it as unreviewed in the terminal.
4. Re-anchor **every** comment from `git show <NEW>:file` — a delta hunk shifts the lines of every untouched finding below it.
5. Set `PR_HEAD` = `NEW`, rebuild the full payload with `commit_id` = `NEW`, and recheck again before POST.

Never post the old payload at the old `commit_id`: it publishes findings the author already fixed, anchored to lines
the author no longer sees. Omitting `commit_id` instead attaches stale evidence to the newer head silently.

## Create pending review

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

Omit `event` entirely (422 on `"PENDING"`).

Run that POST as its own Bash call — no chained footer gate, payload build, or `open`. A compound call that fails
classifier review takes every chained step down with it; an isolated POST is cheap to retry once and simple for the
user to re-authorize. Hook input-rewrite denial → [`wk-env`](../../env/README.md) Step 3.6 (one retry, then hand off).

## Submit as approval (`approve` flag only)

Only after the SKILL.md Approve gate passes and the pending review exists. Recheck `headRefOid` == `PR_HEAD` first;
moved → stay pending. Write `{"event": "APPROVE", "body": "<same verdict + footer>"}` with the Write tool, then, as its
own Bash call:

```bash
gh api repos/{owner}/{repo}/pulls/{n}/reviews/{review_id}/events --method POST --input <file>
```

Response `state` must be `APPROVED`; anything else → report the pending review as-is. 422 → stay pending; never retry
as `COMMENT`. Submitting is irreversible — inline comments publish with it.

## Append to existing pending review

GitHub allows no append — delete review, recreate with full comment set. Pending comments return `line: null`; rebuild
from scratch.

## Follow-up after posted review

Live inline comment (`POST /pulls/{n}/comments`) or thread reply (`/comments/{id}/replies`). Never a second pending
review for one finding.
