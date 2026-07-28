# wk-pr-takeover

Take over a pull request being worked on by someone else and drive it to
completion using the full [`wk-workflow`](../workflow/README.md).

**Version:** `2026.07.28-171057`

## Purpose

When a PR needs a new owner — the original author is unavailable, you are
pairing and continuing their work, or a colleague asked you to finish it —
this skill handles the handoff cleanly: checks out the branch, establishes
co-authorship, orients you to what's been done, and runs the full development
workflow to completion.

## Trigger

- `/wk-pr-takeover <pr-number-or-url>` — overwrite mode (default)
- `/wk-pr-takeover <pr-number-or-url> --stack` — stack mode
- Natural language: "take over PR 123", "pick up this PR", "finish this PR",
  "continue someone else's PR", "inherit this PR"

## Modes

| Mode | Behavior |
|------|----------|
| **overwrite** (default) | Check out the existing branch; add commits directly; both authors own the branch |
| **stack** | Create a new branch on top of the existing head; new PR targets the original branch as base |

Auto-upgrade from overwrite → stack when new changes exceed 30% of the
original PR's line-count diff.

## Key Phases

1. **Parse** — resolve PR number / URL, detect `--stack` flag
2. **Fetch context** — read PR description, diff, reviews, and comments
3. **Check out** — branch checkout (overwrite) or new branch from head (stack)
4. **Orient** — read changed files, run baseline tests, identify gaps. Prose/docs-dominated diffs substitute a gate-preservation audit (hooks as baseline; verify every claimed rule/link/count survived)
5. **Co-authorship** — extract original author identity; set `$WK_CO_AUTHOR`
6. **Plan** — task list from unresolved feedback + incomplete code
7. **[`wk-workflow`](../workflow/README.md)** — full workflow (plan → implement → test → review → PR → retro)
8. **PR update / creation** — update existing PR or create stacked PR
9. **Self-review** — inline comments; no self-approval
10. **Handoff comment** — summary posted to the PR

## Hard Rules

- User MUST NOT approve the PR (co-author constraint).
- Every commit carries `Co-Authored-By: <original-author>` — skipped when the sole author is the user (own-PR takeover).
- Pre-existing test failures are documented, not silently fixed without attribution.
- Stacking on a draft base surfaces a three-option prompt; auto-mode retargets to the default branch.
- 30% scope threshold triggers automatic switch to stack mode.

## Integration Points

- Invokes [`wk-workflow`](../workflow/README.md) at Step 7 (full workflow)
- Invokes [`wk-pr-update`](../pr-update/README.md) if base conflicts exist before checkout
- Invokes [`wk-self-review`](../self-review/README.md) at Step 9
- Invokes [`wk-commit`](../commit/README.md) with `$WK_CO_AUTHOR` for all new commits
- Invokes `wk-learn pr-takeover` at session end
- Follows [`wk-gh`](../gh/README.md) org-scoping rules for all GitHub API calls
