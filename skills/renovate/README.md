# wk-renovate

> **Version:** 2026.10.20-225726 · **Group:** pull-request · **Model:** sonnet

Batch all open Dependabot PRs in the current repo into a single combined
dependency-update PR — one branch, one review, one merge.

## Why

Dependabot opens one PR per dependency bump. In active repos this creates a
queue of 10–30 open PRs, each needing CI, review, and merge.
[wk-renovate](../renovate/README.md) collapses them into one PR that upgrades
everything at once.

## Trigger

| How | When |
|-----|------|
| `/wk-renovate` | Combine open Dependabot PRs into a single update PR |
| `/wk-renovate cleanup` | Close superseded Dependabot PRs after the combined PR merges |

## Flow

```mermaid
flowchart TD
    A[Discover open Dependabot PRs] --> B{Any found?}
    B -- No --> Z[Report: nothing to do]
    B -- Yes --> B2[Pause for user confirmation / exclusions]
    B2 --> C[Create combined branch from main]
    C --> D[Cherry-pick each Dependabot commit]
    D --> E{Lockfile conflict?}
    E -- Yes --> F[Regenerate lockfile via package manager]
    F --> D
    E -- No --> G[Verify install + optional tests]
    G --> G2[Audit every major bump, direct or transitive]
    G2 --> H{Major bump or code changes beyond deps?}
    H -- Yes --> I["Invoke [wk-adversarial-review](../adversarial-review/README.md)"]
    H -- No --> J[Skip adversarial review]
    I --> K[Create combined PR with Supersedes annotations]
    J --> K
    K --> L[Post-merge: gh pr close originals]
```

## Key Rules

- **`Closes #N` auto-closes PRs too** — use it in the combined PR body for
  each superseded Dependabot PR; Step 7 handles any stragglers.
- **Every major bump is audited** — direct or transitive, found by diffing the
  lockfile against base; a green suite is not evidence of safety.
- **Adversarial review** runs when any major bump exists or the diff touches
  application code beyond manifests and lockfiles.
- **Automated external review** is always skipped for dependency-only updates.
- **Lockfile conflicts** are resolved by regenerating via the detected package
  manager, not by manual conflict resolution.

## Integration

- Invokes [wk-gh](../gh/README.md) for org-scoped GitHub operations.
- Invokes [wk-adversarial-review](../adversarial-review/README.md) when a major
  bump or code change is detected.
- Invokes [wk-commit](../commit/README.md) for the combined commit.
- Invokes [wk-pr](../pr/README.md) for PR creation.
