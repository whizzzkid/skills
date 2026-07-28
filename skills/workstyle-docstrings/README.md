# wk-workstyle-docstrings

Enforce terse, WHY-only **structured** docstrings (JSDoc, YARD, `///`, `@param`/`@return`) —
distinct from [wk-workstyle-docs](../workstyle-docs/README.md), which handles inline/prose
comments. Validates callable signature documentation (inputs/outputs), enforces full column-width
utilization, and mandates stale-comment removal when editing adjacent code.

**Version:** `2026.07.28-171117`

## Trigger

Auto-invoked by [wk-workstyle](../workstyle/README.md) whenever the diff adds or edits a doc
comment, docstring, or public API symbol. Also fires from [wk-adversarial-review](../adversarial-review/README.md)
sweep 2.15 (source diff → workstyle check). Directly invocable: `/wk-workstyle-docstrings check <path>`.

## Key Rules

- **WHY not WHAT** — every comment must explain a hidden constraint, invariant, or non-obvious
  workaround. If it restates the identifier name or describes what the code obviously does, delete it.
- **One line, full width** — use the full column limit (project config or 120 cols default). Single
  sentence. Multi-sentence summaries mean the function needs to be split.
- **Document callable signatures** — for public functions/methods/classes with a doc comment,
  include params and return type in the language-native format (JSDoc, YARD, Google-style, etc.).
- **Stale removal is mandatory** — when editing code, scan adjacent comments for stale `@param`,
  old names, or outdated behavior descriptions and delete or update them.
- **Project linter config wins** — never fight `.rubocop.yml`, `pyproject.toml`, or equivalent.

## Language-Native Formats

| Language | Format |
|----------|--------|
| TypeScript/JS | JSDoc `@param {Type} name` / `@returns {Type}` |
| Python | Google-style or NumPy-style (never both) |
| Go | `//` above `func`; first sentence is the summary |
| Ruby | YARD `@param name [Type]` / `@return [Type]` |
| Rust | `///` public items; `//!` modules |
| Shell | `# Args: $1 — description` |

## Integration Points

- [wk-workstyle](../workstyle/README.md) — orchestrator that routes here when the diff touches doc
  comments or public APIs
- [wk-workstyle-docs](../workstyle-docs/README.md) — companion skill covering inline comments (not
  structured docstrings); the two complement each other
- [wk-adversarial-review](../adversarial-review/README.md) — sweep 2.15 invokes this skill in
  report-only mode on every changed source file
- [wk-workflow](../workflow/README.md) — pre-commit pass routes through [wk-workstyle](../workstyle/README.md)
  which fans out here
