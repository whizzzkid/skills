# wk-workstyle-structure

> Layout & structure gate for code the agent writes — imports-at-top, guard clauses, bounded nesting, single-responsibility, no nested ternaries, no magic values, no boolean traps, no dead code, and a duplication threshold that triggers wk-refactor.

**Version:** `2026.07.28-171126`

## Invocation

| Mode | Trigger |
|------|---------|
| Model-invocable | Automatic whenever the agent writes or edits a function body, branching logic, or file layout |
| User-invocable | `/wk-workstyle-structure scan` — full tree; `/wk-workstyle-structure check <path>` — one file |

## Rules at a Glance

- **Column width 120**, wrapping longer lines (defers to `.editorconfig`/linter).
- **Spaces not tabs** — two-space general, four-space Python; follow project for tab languages.
- **Imports at the top**, grouped stdlib → third-party → local with blank lines between.
- **No nested ternaries** — one level max; nested → `if/else` or early-return.
- **Guard clauses first**, max nesting depth 3; deeper → extract a function.
- **Single responsibility** — one thing per function, target ≤ 30 lines.
- **No magic numbers/strings** — name semantic literals as constants.
- **No boolean-trap parameters** — use options objects, keyword args, or enums.
- **No commented-out code** — delete it; explain anything preserved.
- **Avoid duplication** — three near-identical sites is the lift threshold.
- **Invoke [`wk-refactor`](../refactor/README.md)** when duplication is frequent (≥ 3 in-diff sites or ≥ 5 repo copies).

## Noteworthy

- **Project config is always authoritative.** Defers to any active linter /
  formatter config; fills gaps only.
- **Part of the [`wk-workstyle`](../workstyle/README.md) family** — the [`wk-workstyle`](../workstyle/README.md) orchestrator runs
  the shared project-style-authority probe (Step 0) and routes to this skill
  based on the touched files / change type. This skill is also independently
  model-invocable on adjacent work.
- **Duplication threshold is three near-identical sites** (in-diff or repo-wide ≥ 5 copies) — that triggers a wk-refactor lift-and-migrate before extending the pattern.
- **Layout rules (column width, indent) defer to wk-format and any `.editorconfig`**; this skill owns the structural concerns (imports grouping, nesting, magic values, duplication).
