---
name: wk-workstyle
description: >-
  Code-quality orchestrator for every file the agent writes or edits — runs
  the style-authority probe, then routes to the wk-workstyle-* sub-skills
  (naming, structure, async, docs, testing, error-handling, per-language).
  Auto-invoked whenever the agent writes/edits/refactors code;
  code-modifying skills invoke it before committing. Project linter wins.
argument-hint: '[scan|check <path>]'
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
model: sonnet
effort: low
model-invocable: true
user-invocable: true
license: MIT
group: workflows
metadata:
  author: whizzzkid
  version: "2026.10.09-184159"
  internal: false
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Workstyle

Detect the project's style authority once, then route to the `wk-workstyle-*`
sub-skills that carry the rules. Project settings are authoritative: fill gaps
only, never override. Sub-skills also fire independently on adjacent work
(`.py` edit → `wk-workstyle-python`); this orchestrator is the full pre-commit
pass.

Invocation: auto before any `wk-commit` on a code-change diff and after any
Edit/Write to a source file; from `wk-adversarial-review` Step 2 mechanical
sweeps; manual `/wk-workstyle scan` (full repo) or `/wk-workstyle check <path>`
(single file, report only).

## Step 0: Detect project style authority

Run once per session; cache the result. Every `wk-workstyle-*` sub-skill defers
to this probe rather than re-running it.

```bash
# Detect style configs without shell glob expansion.
find . ! -name . -prune -type f -print |
  LC_ALL=C sort |
  while IFS= read -r config_path; do
    config_name=${config_path#./}
    case "$config_name" in
      .editorconfig|.eslintrc*|prettier.config.*|.prettierrc*|pyproject.toml|setup.cfg|.rubocop.yml|rubocop.yml|.rubocop_todo.yml|.golangci.yml|golangci.yml|rustfmt.toml|.rustfmt.toml|.clang-format|.stylelintrc*|.flake8|tox.ini|mypy.ini)
        echo "found: $config_name"
        ;;
    esac
  done
```

- Config governs a rule: that config wins; never emit a finding that contradicts it.
  No config: apply the workstyle default.
- Never emit a finding that would require adding `// eslint-disable`,
  `# rubocop:disable`, or equivalent to pass — escalate to user.

## Step 1: Route to sub-skills

Invoke one language sub-skill plus every universal sub-skill whose change type
the diff matches; dispatch and aggregate only.

### Universal rule sets (by change type)

| When the diff… | Invoke |
|----------------|--------|
| Introduces or renames any identifier (variable, function, class, constant, boolean) | `wk-workstyle-naming` |
| Adds/edits a function body, branching logic, control flow, imports, or file layout | `wk-workstyle-structure` |
| Touches async/await, promises, `.then` chains, callbacks, goroutines, threads, channels, mutexes | `wk-workstyle-async` |
| Adds/edits an inline comment or updates existing docs without a structured docstring | `wk-workstyle-docs` |
| Adds/edits a structured docstring, JSDoc, YARD, `///`, or any callable with `@param`/`@return` | `wk-workstyle-docstrings` |
| Writes or modifies tests | `wk-workstyle-testing` |
| Touches a `catch`/`rescue`/`except` block, error return, or raise/throw | `wk-workstyle-error-handling` |
| Adds/edits CSS, design tokens, colors, borders, or visual styles | `wk-design-review` |
| A `bundle exec`/`bin/*`/`rake`/`rails` command fails with a gem or env error | `wk-workstyle-rails` |

### Language rule sets (by file extension)

| Extension | Invoke |
|-----------|--------|
| `.ts` `.tsx` `.js` `.jsx` `.mjs` `.cjs` | `wk-workstyle-typescript` |
| `.py` | `wk-workstyle-python` |
| `.rb` + Ruby bin scripts | `wk-workstyle-ruby` |
| `.go` | `wk-workstyle-go` |
| `.rs` | `wk-workstyle-rust` |
| `.sh` + shell bin scripts | `wk-workstyle-shell` |

## Step 2: Apply or report

Aggregate each sub-skill's classified findings:

- **Auto-fixable** (rename, add constant, wrap line, import sort, doc stub): apply
  silently; note in the commit message.
- **Requires judgment** (restructure nested ternary, add test, extract function):
  surface before committing with the finding, location, and a concrete fix sketch.
- **Conflicts with project config**: suppress; never fight the linter.

Summarize: "Workstyle pass: {n} auto-fixed, {m} suggestions, {p} suppressed
(project config). Sub-skills run: {list}. Changed files: {list}."

## Hard Rules

1. **Never override project settings.** `.editorconfig` says 4-space indent → use
   4 spaces; `rubocop.yml` sets 100-col width → use 100. Project config always wins.
2. **Do not emit a finding that would require disabling a linter rule** to pass.
   Escalate to user instead.
3. **Coverage reminder is non-skippable.** Note any non-trivial code addition
   without a corresponding test; never silently skip. (Enforced by `wk-workstyle-testing`.)
4. **Stale comment removal is mandatory.** When editing code, update or delete
   adjacent comments that no longer match. (Enforced by `wk-workstyle-docs`.)
5. **Sub-skills do not re-run Step 0.** The probe here is the single source of
   truth all sub-skills defer to.

## Post-Completion

Invoke `wk-learn workstyle`.
