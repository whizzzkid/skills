# wk-adversarial-review

> Adversarial pre-flight review of the current branch before anything leaves the machine.

**Version:** `2026.06.11-230337`

## Invocation

| Mode | Trigger |
|------|---------|
| User-invocable | `/wk-adversarial-review [base-branch]` |
| Model-invocable | automatic on: push, `gh pr ready`, new commits on existing PR, any force-push |

## How It Works

```mermaid
flowchart TD
    A[Resolve base branch] --> B[Enumerate diff surface]
    B --> C[14 mechanical sweeps]
    C --> D[Spawn adversarial subagent]
    D --> E[Playground validation]
    E --> F{Verdict}
    F -->|Clear| G[Write .cleared-SHA.json<br/>Hand back to caller]
    F -->|Blockers| H[Print blocker list<br/>Refuse to proceed]
    F -->|Suggestions only| I[AskUser: fix/clear/defer]
    H --> J[Caller fixes → re-invoke]
    J --> C
    I --> G
```

## Noteworthy

- **No opt-out exists.** "Small fix", "trivial", and "docs-only" are explicitly named red flags, not exemptions — even a docs commit can contradict test counts in a spec.
- **Idempotent within a session** — if no new commits land since the last clear verdict, re-invocation is a no-op that prints the prior clearance record (keyed by HEAD SHA).
- **14 mechanical sweeps run unconditionally** before any LLM reasoning: vulnerability-class, sibling-script, reachability, comment accuracy, hardcoded-base, version-pin, signature-widening, cross-doc enumeration, design-pivot, PR metadata sync, external-call reproduction, self-review surface, raw-API bypass, and pre-push gate compliance.
- **Playground validation is mandatory** for any runtime-behavior claim — findings that cannot be reproduced in `.review-playground/` are downgraded from `blocker` to `question`.
- **Fix loop caps at 3 cycles.** After 3 blocked rounds on the same axis, the skill surfaces to the user — repeated recurrence means the diagnosis or design is wrong, not just the fix.
- **This skill is a gate, not an actor.** It never pushes, never posts PR comments, never edits the PR — those actions belong to the calling skill ([`wk-pr`](../pr/README.md), [`wk-workflow`](../workflow/README.md), [`wk-pr-resolve`](../pr-resolve/README.md)).
