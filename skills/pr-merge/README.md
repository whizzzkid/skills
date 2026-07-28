# wk-pr-merge

> Gate the merge of a pull request behind a full pre-merge checklist, then
> merge, transition the linked ticket to its terminal state, and surface
> any follow-ups and deferred action items. The merge is where the
> adversarial-review gate is enforced — publishing is ungated, so this skill is
> the step that blocks on a stale or missing verdict.

**Version:** `2026.07.28-082712`

## Invocation

| Mode | Trigger |
|------|---------|
| User-invocable | `/wk-pr-merge` (current branch) or `/wk-pr-merge 123` (explicit PR) |
| Model-invocable | `false` — user-initiated gate only |

## How It Works

```mermaid
flowchart TD
    A["Step 1: Resolve PR<br/>(current branch or argument)"] -->|state == MERGED| G
    A -->|open| B["Step 2: CI green?"]
    B -->|failing/pending| BLOCK1["🚫 Block — list failing checks"]
    B -->|green| C["Step 3: Reviews approved?"]
    C -->|changes requested / no review| BLOCK2["🚫 Block — list reviewers"]
    C -->|approved| D["Step 4: All threads resolved?"]
    D -->|unresolved threads| BLOCK3["🚫 Block — list open threads"]
    D -->|all resolved| E["Step 5: No open action items?"]
    E -->|unchecked non-deferred items| BLOCK4["🚫 Block — list items"]
    E -->|clear| E2["Step 5.5: Clear adversarial-review<br/>verdict against current HEAD?"]
    E2 -->|missing / stale / blocked| BLOCK5["🚫 Block — run wk-adversarial-review"]
    E2 -->|clear| F["Step 6: Retarget stacked children onto base,<br/>then merge PR (squash)"]
    F --> G["Step 7: Transition linked ticket to Done"]
    G --> H["Step 8: Output follow-ups and action items"]
    H --> I["Step 9: Capture session retro"]
    I --> J["Step 10: Clean up worktree<br/>(point of no return — only after<br/>every pending question is answered)"]
```

## Checks Before Merge

All four must pass; any failure blocks and reports what needs fixing:

- CI: all required checks green on HEAD SHA (non-required checks are informational — never polled or blocked on)
- Reviews: `reviewDecision = APPROVED` (or no required reviewers)
- Threads: reviewer/bot threads resolved or triaged (author's own self-review threads may stay open)
- Action items: no unchecked `- [ ]` outside designated deferred sections

## Ticket Handling

| Source | How resolved |
|--------|-------------|
| Jira (`[A-Z]+-\d+` or `atlassian.net` URL) | Transition to terminal state via Jira MCP; post shipped comment |
| GitHub issue (`Closes #N` annotation) | `gh issue close` with merge-commit reference |
| Asana / other | Noted as limitation — user must close manually |

## Noteworthy

- **[`wk-pr-resolve`](../pr-resolve/README.md) first if threads exist** —
  resolve outstanding review comments before invoking this skill.
- **Never auto-resolve the author's own self-review threads** — they are
  informational and left open; the Step 6 merge attempt is the ground-truth
  probe of whether branch protection actually counts them.
- **Squash is the default** — the skill detects repo merge settings and
  respects overrides, but squash is the safe default for clean history.
- **Jira auto-close does not happen via `Closes #N`** — GitHub's
  auto-close only works for GitHub Issues. Jira always needs an
  explicit transition call.

## ⚠️ Status

Scaffold written — RED phase not yet run. Steps 1–8 contain `DESIGN NOTES`
describing intended behaviour; implementation lands after RED documents
baseline failures.
