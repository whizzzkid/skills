---
name: wk-workstyle-docstrings
description: >-
  Use when writing or editing documentation comments or docstrings — JSDoc, Python docstrings,
  Rustdoc, Go doc comments, YARD, JavaDoc, or any language's structured comment syntax. Enforces
  terse WHY-only comments, full column-width utilization, input/output type documentation for
  callables, and mandatory removal of self-evident or stale comments. Auto-invoked whenever the
  agent adds or edits a docstring, doc comment, or public function/class/method/interface.
  Project linter config wins.
argument-hint: '[check <path>]'
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
model: haiku
effort: low
model-invocable: true
user-invocable: true
license: MIT
group: workflows
metadata:
  author: whizzzkid
  version: '2026.06.25-164842'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Workstyle — Docstrings

Enforce terse, WHY-only docstrings that document callable signatures. Project linter config wins;
this skill fills gaps only.

## When to Use

- Writing or editing any doc comment, docstring, or structured comment on a public symbol
- Adding a new function, method, class, interface, struct, or module with a comment block
- Editing code adjacent to an existing docstring (stale-comment removal is mandatory)
- `/wk-workstyle-docstrings check <path>` — audit a single file

---

## Step 0: Resolve column width

Check project config priority order (defer to [wk-workstyle](../workstyle/README.md) Step 0 if
already run). Use the first match found:

```bash
# Check for per-language column overrides
grep -E "max_line_length|print_width|max-line-length|column_limit|line-length|LineLength" \
  .editorconfig .eslintrc* .prettierrc* pyproject.toml setup.cfg .rubocop.yml \
  .golangci.yml rustfmt.toml .clang-format 2>/dev/null | head -5
```

- Config governs → use that width. Never fight the linter.
- No config → default **120 columns**.
- Go: enforce 120 unless `.golangci.yml` says otherwise.
- Python: PEP 257 style (72-col for flowing text) unless `pyproject.toml` overrides.
- Ruby: use RuboCop `Max` if present.

---

## Step 1: Apply the comment gate

Before writing or keeping any comment or docstring line, answer both questions:

1. **WHY, not WHAT?** Does it explain a hidden constraint, non-obvious invariant, or specific
   workaround — something a reader could not derive from the code and identifier names alone?
2. **One line, full width?** Can the thought fit on a single line using the resolved column limit?

If the answer to (1) is "no" → delete the comment. If the answer to (2) is "no" → compress to
one line before keeping it.

**Strip** anything that:
- Restates what the code obviously does (`// increments counter by 1`)
- Describes the current task, fix, or calling context (`// added for the auth flow`)
- Repeats the function name in prose (`// GetUser returns the user`)
- Chains independent reasons in one sentence (`because … while … so that`)

---

## Step 2: Document callable signatures

For every public function, method, constructor, interface, or class that has a doc comment, verify
it documents inputs and outputs. Use the language-native format; fill only what exists (skip `@param`
if no params, skip `@returns` if `void`/`None`/`unit`).

### Language-native formats

| Language | Format | Example |
|----------|--------|---------|
| TypeScript/JS | JSDoc `@param {Type} name` / `@returns {Type}` | `/** @param {string} id @returns {Promise<User>} */` |
| Python | Google-style docstring or NumPy-style; never both | `Args: id (str): ... Returns: User` |
| Go | `//` doc comment above `func`; first sentence is the summary | `// FetchUser returns the User for the given id, or ErrNotFound.` |
| Ruby | YARD `@param name [Type]` / `@return [Type]` | `# @param id [String] @return [User, nil]` |
| Rust | `///` for public items; `//!` for modules; use backtick for types | `/// Returns the [`User`] for `id`, or [`None`] if absent.` |
| Java/Kotlin | JavaDoc `@param` / `@return` / `@throws` | standard JavaDoc blocks |
| Shell | `# Args: $1 — description` above the function | inline `# Args:` block |

**One-sentence summary first**, then params/returns. Do not write a multi-paragraph summary — if
more than one sentence is needed, the function needs to be split.

---

## Step 3: Stale comment removal (mandatory)

When editing code, scan the **entire function or block** for adjacent comments that no longer match:

```bash
# Example: after renaming a parameter, grep for the old name in comments
grep -n "old_param_name" <file>
```

- Old parameter names, removed return types, stale behavior descriptions → delete.
- An outdated `@param` for a removed parameter is a blocker — it misleads callers.
- A comment describing behavior the code no longer implements → delete or update.

---

## Step 4: Auto-fix and report

**Auto-fixable** (apply silently, note in commit message):

- Delete self-evident or WHAT-only comments.
- Delete stale `@param` / `@return` entries for removed parameters or changed types.
- Compress multi-line single-thought comments to one line within column limit.
- Add missing `@param` / `@return` to a public callable that already has a doc comment block.

**Requires judgment** (surface before committing):

- Public API with no doc comment at all — suggest adding one; do not add blindly.
- Ambiguous WHY candidate — ask whether the constraint is real.
- Comment that would exceed column limit even fully compressed — surface; do not truncate meaning.

**Conflicts with project config** → suppress; never fight the linter.

---

## Common Mistakes

- **Over-explanation**: writing what the code does instead of why a constraint exists.
- **Early wrapping**: splitting a comment at 60 cols when 120 are available — wastes width, adds
  lines, dilutes signal.
- **Stale `@param` on renamed or removed params**: callers read the doc, not the code; a stale name
  misleads IDE autocomplete and human readers alike.
- **Multi-sentence summaries**: one sentence; split the function if more is needed.
- **Documenting the obvious**: `// returns nil if not found` when the return type is `*T, error` and
  `ErrNotFound` is defined — the type and error name already say it.

---

## Quick Reference

| Trigger | Check |
|---------|-------|
| New public callable | Add one-sentence summary + params/returns if non-trivial |
| Editing adjacent code | Scan block for stale comments; delete or update |
| Multi-line single-thought comment | Compress to one line at column limit |
| WHAT comment ("increments x") | Delete unconditionally |
| `/wk-workstyle-docstrings check <path>` | Report all violations in the file, no auto-fix |

---

## Requirements

- Project linter config resolved (defer to [wk-workstyle](../workstyle/README.md) Step 0).
- Column limit known before writing any comment line.

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn workstyle-docstrings`).
