# wk-docs

> Check for and update documentation affected by code changes. Bootstraps a docs structure if the project doesn't have one.

**Version:** `2026.07.28-022825`

## Invocation

| Mode | Trigger |
|------|---------|
| User-invocable | `/wk-docs` |
| Model-invocable | automatic on: code changes, new features, API modifications, potentially stale docs |

## How It Works

```mermaid
flowchart TD
    A[Code changes made] --> B{docs/ folder exists?}
    B -- No --> C[Bootstrap: mkdir -p docs/plans,specs,adr,tutorials,examples]
    C --> D[Create docs/README.md index]
    B -- Yes --> E[Scan docs/ for affected files]
    E --> F{Any docs impacted by changes?}
    F -- No --> G[Done — leave correct docs alone]
    F -- Yes --> H[Update affected docs only]
    H --> I{docs/README.md exists?}
    D --> I
    I -- Yes --> J[Sync index: add new, remove stale entries]
    I -- No --> G
```

## Noteworthy

- **HARD RULE:** Write and Edit tools may only target files under the docs root (`docs/`, `documentation/`, `doc/`, or `site/`). The skill never writes outside the docs directory.
- **Surgical updates:** Only docs made inaccurate by the current changes are touched — the skill never reformats or rewrites docs that are still correct.
- **Docs root discovery:** The skill checks for `docs/`, `documentation/`, `doc/`, and `site/` in that order; it uses whichever exists rather than assuming `docs/`.
- **Bootstrap is non-destructive:** If the project has no docs folder, the skill creates the canonical structure; it never overwrites an existing layout.
- **Index maintenance:** `docs/README.md` is kept in sync — new docs are listed, stale entries removed — so the index is always a reliable map of what exists.
- **Read-only code access:** Grep, Glob, and Read may access any path to understand code changes; only writes are restricted to the docs root.
- **Claim-grounding gate:** Every doc, README, announcement, and PR-body accuracy pass extracts capability verbs (runs, validates, enforces, blocks) and requires each to name the symbol implementing it — a numbers-only grounding pass verifies statistics while a false capability claim ships unread. Regeneration from a source file adds no claim the source lacks.
- **Cross-section consistency:** After editing a spec concept, the skill greps the whole doc for its core terms and reconciles tense, qualifier, and implementation status across every section — catching narrative-vs-risk-table drift a diff review misses.
