---
name: wk-format
description: >-
  Apply the user's code-formatting preferences to any file the agent writes
  or edits, reconciled with the repo's lint/style configs (.editorconfig,
  eslint, prettier, ruff/black, rubocop, gofmt, rustfmt). Auto-invoked on
  any code write/edit/refactor; manual `/wk-format` reports the active rule
  set. Repo config wins.
argument-hint: '[scan|rules|check <path>]'
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - AskUserQuestion
  - Write
model: sonnet
effort: low
model-invocable: true
user-invocable: true
license: MIT
group: workflows
metadata:
  author: whizzzkid
  version: "2026.07.28-171045"
  internal: false
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Format

Reconcile user code-formatting preferences with the repo lint config; apply
merged rules to every file the agent writes or edits. Repo config wins on
conflict; preferences fill gaps.

## When this fires

- **Auto:** before writing/editing any source file (any language). Runs once
  per repo per session → caches resolved rule set → passes it forward.
- **Manual:**
  - `/wk-format` → rescan repo configs, refresh cache.
  - `/wk-format rules` → print active merged rule set.
  - `/wk-format check <path>` → report likely violations of merged set against
    an existing file (with line numbers).

---

## Hard preferences (apply unless lint config disagrees)

### Likes — apply by default

- **Comment functions well.** Every function/method/non-trivial closure gets a
  docstring/JSDoc/rustdoc-equivalent documenting: contract (what it does),
  inputs (types + meaning, not just names), outputs (return shape + error
  modes), side effects. Inline comments only where the *why* is non-obvious —
  never to restate code.
- **≤120 columns per line.** Hard cap. Wrap at semantic boundaries (after
  operators, before chained method calls), not arbitrary points.
- **End every file with a single trailing newline.** No more, no less.
- **2-space indent, spaces only — never tabs.** Mixed indentation is a defect.
- **Imports at top of file.** Group: stdlib, third-party, local. Two blank
  lines between import block and first declaration; two blank lines between
  top-level functions, classes, and import groups.

### Dislikes — avoid by default

- **No multi-line ternaries.** Doesn't fit on one line → use `if`/`else` (or
  pattern match, or guard clause).
- **Functions ≤40 lines.** Past that → split: extract a helper, use early
  returns, or flatten control flow. Counts code lines excluding docstring and
  blank lines.
- **No vague names.** Reject and rename: `data`, `temp`, `result`, `info`,
  `value`, `obj`, `thing`, `helper`, `do_stuff`, `manager`, `handler` (without
  a noun), single-letter locals outside tight loops or math.
- **No vague logic.** Reader must not need to run code to know what it does.
  Violations: hidden side effects, undocumented magic numbers, conditions
  mixing ANDs/ORs without parentheses, shadowing built-ins.
- **Do not overwrite input parameters.** Bind a new local instead. Exception:
  language idiom requires it (Python `*args` unpacking, Go
  `for i := range slice`, etc.) AND no clean alternative exists → document why
  in a one-line comment.

---

## Stage 0: Detect repo config (run once per session per repo)

Before writing any source file, scan repo root + immediate subdirs for
lint/style configs. Look for **all** of these and merge what is found — repos
often pin multiple layers (editor + language tool + project tool):

```bash
ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Universal
find "$ROOT" -maxdepth 2 -type f \( \
  -name '.editorconfig' \
  -o -name '.prettierrc*' \
  -o -name 'prettier.config.*' \
\) 2>/dev/null

# JavaScript / TypeScript
find "$ROOT" -maxdepth 2 -type f \( \
  -name '.eslintrc*' \
  -o -name 'eslint.config.*' \
  -o -name 'tsconfig.json' \
  -o -name 'biome.json' \
\) 2>/dev/null

# Python
find "$ROOT" -maxdepth 2 -type f \( \
  -name 'pyproject.toml' \
  -o -name 'setup.cfg' \
  -o -name '.pylintrc' \
  -o -name 'pylintrc' \
  -o -name 'ruff.toml' \
  -o -name '.flake8' \
  -o -name 'mypy.ini' \
\) 2>/dev/null

# Ruby
find "$ROOT" -maxdepth 2 -type f \( \
  -name '.rubocop.yml' \
  -o -name 'rubocop.yml' \
  -o -name '.standard.yml' \
\) 2>/dev/null

# Go / Rust / C-family / Shell
find "$ROOT" -maxdepth 2 -type f \( \
  -name 'rustfmt.toml' -o -name '.rustfmt.toml' \
  -o -name '.clang-format' \
  -o -name '.shellcheckrc' \
  -o -name '.golangci.yml' -o -name '.golangci.yaml' \
\) 2>/dev/null
```

Read each file found. Extract rule-set keys (see "Key extraction"). On
disagreement (e.g. `.editorconfig` says 2-space, `.prettierrc` says 4-space),
**most-language-specific config wins** — `.prettierrc` for JS,
`pyproject.toml [tool.black]` for Python, etc.

### Key extraction

| Source | Keys to read |
|--------|--------------|
| `.editorconfig` | `indent_style`, `indent_size`, `end_of_line`, `insert_final_newline`, `max_line_length`, `trim_trailing_whitespace` |
| `.prettierrc*` | `tabWidth`, `useTabs`, `printWidth`, `semi`, `singleQuote`, `trailingComma`, `bracketSpacing`, `endOfLine` |
| `eslint*` | `max-len`, `indent`, `quotes`, `semi`, `no-unused-vars`, `no-param-reassign`, `complexity`, `max-lines-per-function` |
| `pyproject.toml [tool.black]` | `line-length`, `target-version` |
| `pyproject.toml [tool.ruff]` | `line-length`, `indent-width`, `select`, `ignore` |
| `.pylintrc` / `pylintrc` | `max-line-length`, `indent-string`, `max-args`, `max-statements`, `max-module-lines`, naming `*-rgx` |
| `tsconfig.json` | `strict`, `noImplicitAny`, `noUnusedParameters` (signal — not formatting per se but informs naming/clarity rules) |
| `.rubocop.yml` | `LineLength.Max`, `IndentationWidth`, `MethodLength.Max`, `ClassLength.Max`, `Naming/*` |
| `rustfmt.toml` | `max_width`, `tab_spaces`, `hard_tabs`, `newline_style` |
| `.clang-format` | `ColumnLimit`, `IndentWidth`, `UseTab`, `BreakBeforeBraces` |

For each detected key, record source file + resolved value. Conflict
precedence: language-specific tool > Prettier/Black > `.editorconfig` > this
skill's hard preferences.

---

## Stage 1: Build the merged rule set

Produce a single in-memory rule set to consult during edits. Suggested shape
(illustrative — not literal output format):

```
language: <auto-detect from extension>
indent_style: spaces | tabs              # repo config wins
indent_size: <int>                       # repo config wins
max_line_length: <int>                   # repo config wins (cap at 120)
final_newline: true                      # always
trim_trailing_whitespace: true           # always
quote_style: single | double             # repo config; else language idiom
import_grouping: stdlib, third-party, local
function_max_lines: 40                   # preference; repo overrides if set
function_doc_required: true              # preference; never overridden
no_param_reassign: true                  # preference; eslint/rubocop equivalents reinforce
no_multiline_ternary: true               # preference
naming_min_chars: 3                      # except idiomatic loop counters
banned_names: data, temp, result, info, value, obj, thing, do_stuff, manager
```

(`/wk-format rules` prints this set; `/wk-format check <path>` runs it against
an existing file and reports violations with line numbers.)

---

## Stage 2: Apply during write/edit

1. Resolve rule set (Stage 1 cache, or rerun Stage 0 if absent).
2. Detect file language from extension/shebang.
3. **Before** committing the edit text:
   - Wrap any line >max_line_length at a semantic boundary.
   - Convert tabs to resolved indent (or vice versa if repo uses tabs).
   - Add trailing newline if missing.
   - Reject any function exceeding the length cap → split into helpers, re-emit.
   - Reject any vague name → name the *thing* (the data's role), not its type
     or position.
   - Reject any multi-line ternary → rewrite as `if`/`else`.
   - Reject any input-parameter reassignment lacking an explicit justifying
     comment.
4. **Documentation:**
   - Every new function gets a doc block in the language idiom: Python
     `"""…"""`, JS/TS JSDoc `/** … */`, Rust `///`, Ruby `# @param`, Go
     top-of-func comment with the function name.
   - Block names: contract, params (type + meaning), return, errors/raises,
     side effects.
   - Inline comments only where the *why* is non-obvious; never restate code.

---

## Stage 3: Conflict resolution

Repo config is authoritative — repo rule contradicting a hard preference →
**repo wins**. Flag once per session so the user knows the preference was
overridden; do not re-surface the same conflict on subsequent edits (cache the
resolved set):

> "Repo `.prettierrc` sets `printWidth: 100`; using 100 instead of the
> preferred 120 for this repo."

No repo config to read (greenfield repo, scratch script, dotfile edit) → apply
hard preferences as-is; note in the first commit that formatting reflects user
defaults.

---

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| About to write/edit code | Auto-resolve rule set; apply during write |
| `/wk-format` | Rescan repo configs, refresh cached rule set |
| `/wk-format rules` | Print merged active rule set |
| `/wk-format check <path>` | Lint an existing file against the merged set; report violations |
| Repo config conflicts with preference | Repo wins; flag once per session |
| No repo config | Apply hard preferences as defaults |

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn format`).
