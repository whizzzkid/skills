# Config Detection — Stage 0

Scan repo root + immediate subdirs for lint/style configs. Repos often pin
multiple layers (editor + language tool + project tool); merge what is found.

## Detection commands

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

## Key extraction

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

## Conflict precedence

Language-specific tool > Prettier/Black > `.editorconfig` > skill hard preferences.

Record source file + resolved value for each detected key. On disagreement
(e.g. `.editorconfig` says 2-space, `.prettierrc` says 4-space),
most-language-specific config wins.
