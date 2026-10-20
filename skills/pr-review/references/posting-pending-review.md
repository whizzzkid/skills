# Posting the pending review

## Recheck reviewed head

Before each POST, fetch `headRefOid` vs Phase 1 `PR_HEAD`. Mismatch → do not post; resolve anchors from
`git show <PR_HEAD>:file`; revalidate; rebuild. Set `commit_id` to `PR_HEAD`.

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
