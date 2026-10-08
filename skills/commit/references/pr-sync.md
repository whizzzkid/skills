# Post-Push PR Sync

**HARD RULE:** After every successful push to a branch with an open PR, the PR
title and description MUST be re-checked against the post-push branch state and
updated if drifted. No exceptions.

Drift signals to a reviewer that the agent shipped without re-reading its own
work. The PR is the source of truth for everyone except the author — leaving it
stale silently changes what reviewers approve.

**HARD RULE — push first, then sync the body. Never the reverse.** The PR body's
commit SHAs, ref links, and "current behavior" narrative are only correct *after*
the push lands. Editing the body before pushing bakes in stale refs you then
re-edit — two round-trips for one sync. Fixed order: full pre-push gate →
`git push` → detect drift → edit the body. Any branch-ref-dependent step (body
sync, "Closes #N" verification, self-review SHA links) waits for the push.

## Step 1: Detect whether a PR exists

After `git push` returns success:

```bash
gh pr view --json number,title,body,headRefName,state 2>/dev/null
```

- Exit code non-zero or `state != OPEN` → no open PR; skip the rest of this section.
- Otherwise capture `number`, `title`, `body` for comparison.

## Step 2: Check for drift

Compare the PR's current title and body against the branch's post-push state:

| Drift signal | Example |
|---|---|
| Title no longer matches primary intent | scope flipped feat→fix; version pin landed but title still says "upgrade" |
| Body lists commits/behaviors that no longer exist | removed commits, reverted decisions still described as live |
| Test plan / Closes section is now wrong | steps reference removed code; linked issue closed by a different PR |
| Body cites a version or config value the push changed | dep version in body doesn't match lockfile |

A clean push that only adds tests/docs aligned with the existing description is
**not** drift.

## Step 3: Update on drift

Drift detected → update the PR before returning control:

```bash
gh pr edit <number> --title "<new-title>" \
  --body "$(cat <<'EOF'
<refreshed body>
EOF
)"
```

Rules for the refresh:

- Preserve any `Closes #N` / `Fixes #N` / `Refs #N` annotations unless now wrong.
- Preserve human-authored sections (reviewer notes, test plan checks the user
  added). Do not overwrite review checkboxes a human ticked.
- Reflect the **current** set of commits and the **current** behavior — not the
  historical narrative of how the branch evolved.
- Keep the title under ~70 chars; details belong in the body.
- **Route through `wk-gh`.** Any `gh pr edit --body` issued by this skill ends
  with the canonical outbound footer per `wk-gh` Step 4 — emitted exactly once at
  the end of the body.
- **Important:** a body sync is not complete until the footer gate runs on the
  NEW body string — never the one it replaced. An inherited body is the usual
  carrier of the wrong block: the commit-message trailer and the canonical
  outbound footer open alike, so a carried-over trailer passes an "already has a
  footer" glance. Match the exact canonical string; replace a trailer variant,
  never preserve it.
- Unsure whether a section is human- vs agent-authored → ask the user before
  overwriting. Better to ask once than clobber a hand-edited test plan.

## Step 4: Report

State the outcome explicitly — `Pushed to <branch>. PR #<N> title/body updated`,
or `… already in sync — no edit needed`. Silence after a push that touched an open
PR is itself a violation of this rule.
