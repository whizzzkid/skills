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

## Append to existing pending review

GitHub allows no append — delete review, recreate with full comment set. Pending comments return `line: null`; rebuild
from scratch.

## Follow-up after posted review

Live inline comment (`POST /pulls/{n}/comments`) or thread reply (`/comments/{id}/replies`). Never a second pending
review for one finding.
