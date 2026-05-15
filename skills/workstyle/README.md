# wk-workstyle

> Code-quality gate applied to every file the agent writes or edits — naming, documentation, structure, constants, async patterns, and testing intent. Project settings always win; this skill fills gaps only.

## Invocation

| Mode | Trigger |
|------|---------|
| Model-invocable | Automatic before any `wk-commit` on a code-change diff; auto-invoked by `wk-adversarial-review` Step 2 |
| User-invocable | `/wk-workstyle scan` — full repo scan; `/wk-workstyle check <path>` — single file |

## How It Works

```mermaid
flowchart TD
    A([Code file written or edited]) --> B[Step 0: Detect project style authority]
    B --> C{Config governs rule?}
    C -->|yes — project wins| D[Suppress finding]
    C -->|no — apply workstyle default| E[Step 1: Universal rules pass]

    E --> E1[Layout: 120 col, spaces, imports at top]
    E --> E2[Naming: ALL_CAPS constants, descriptive vars, boolean predicates]
    E --> E3[Structure: no nested ternaries, guard clauses, ≤30-line fns, avoid duplication → wk-refactor]
    E --> E4[Async: no temporal deps, no unbounded chains, propagate errors]
    E --> E5[Docs: JSDoc/docstring for public API, WHY comments on decisions]
    E --> E6[Testing: cover new paths, sad-path tests, behavior not impl]

    E1 & E2 & E3 & E4 & E5 & E6 --> F[Step 2: Language-specific rules]
    F --> F1[TS/JS · Python · Ruby · Go · Rust · Shell]

    F1 --> G[Step 3: Apply or report]
    G --> H{Finding type}
    H -->|auto-fixable| I[Apply silently, note in commit]
    H -->|judgment needed| J[Surface as suggestion before commit]
    H -->|conflicts with project config| D

    I & J --> K[Workstyle summary: N fixed, M suggestions, P suppressed]

    style B fill:#4a90e2,color:#fff
    style K fill:#2ecc71,color:#fff
```

## Noteworthy

- **Project config is always authoritative.** `.editorconfig`, `.eslintrc`, `.rubocop.yml`, `pyproject.toml`, etc. win on any conflict. Workstyle defaults fill gaps — they never fight the linter.
- **Two classes of findings:** auto-fixable (rename, wrap line, add constant, sort imports, add doc stub) are applied silently; judgment-required (restructure logic, add test, extract function) are surfaced as suggestions before the commit lands.
- **Coverage reminder is non-skippable** — every non-trivial code addition without a corresponding test path is flagged. Exceptions: one-off scripts, migration runners, CLI scaffolding.
- **Stale comment removal is mandatory** — when editing code, update or delete adjacent comments that no longer accurately describe the code. Stale comments are worse than no comment.
- **Complements `wk-format`** — `wk-format` handles whitespace and lint-tool formatting; `wk-workstyle` handles naming, patterns, documentation, and structural quality. Both fire before commit.
- **Language-specific rule sets** cover TypeScript/JavaScript, Python, Ruby, Go, Rust, and Shell — each with idioms like `const`/no-`var`, f-strings, `set -euo pipefail`, no `.unwrap()` in Rust production paths, etc.
