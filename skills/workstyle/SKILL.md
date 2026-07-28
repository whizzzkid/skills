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
  version: "2026.07.28-171129"
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

Code-quality orchestrator for every code write or edit. Detects the project's
style authority once, then routes to the focused `wk-workstyle-*` sub-skills
that carry the actual rule sets. Project settings are authoritative — this
family fills gaps only, never overrides.

Each sub-skill is **independently model-invocable** on adjacent work: editing a
`.py` file auto-fires `wk-workstyle-python`, writing an async block auto-fires
`wk-workstyle-async`, and so on. This orchestrator is the entry point for a
full pre-commit pass that runs Step 0 once and fans out to every sub-skill the
diff touches.

**Invocation modes:**

| Mode | Trigger |
|------|---------|
| Auto | Before any `wk-commit` on a code-change diff; after any Edit/Write to a source file |
| `wk-adversarial-review` | Step 2 mechanical sweeps include a workstyle pass |
| Manual | `/wk-workstyle scan` — full repo scan; `/wk-workstyle check <path>` — single file |

---

## Step 0: Detect project style authority

Probe for existing style enforcement. Run once per session; cache
the result. **Every `wk-workstyle-*` sub-skill defers to whatever this
probe finds** — they reference this step rather than re-running it.

```bash
# Style config priority order
for f in .editorconfig .eslintrc* .eslintrc.{json,js,cjs,yaml,yml} \
         prettier.config.* .prettierrc* pyproject.toml setup.cfg \
         .rubocop.yml rubocop.yml .rubocop_todo.yml \
         .golangci.yml golangci.yml rustfmt.toml .rustfmt.toml \
         .clang-format .stylelintrc* .stylelintrc.json \
         .flake8 tox.ini mypy.ini; do
  [ -f "$f" ] && echo "found: $f"
done
```

- If a config governs a rule, **that config wins**. Do not emit a
  finding that contradicts an active config.
- If no config governs a rule, apply the workstyle default.
- Never emit a finding that would require adding `// eslint-disable`,
  `# rubocop:disable`, or equivalent to pass — escalate to user.

---

## Step 1: Route to sub-skills

Determine which rule sets apply from the change type and the touched
file extensions, then invoke the matching sub-skills. The sub-skills
carry the rules; this orchestrator only dispatches and aggregates.

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

A typical code change invokes one language sub-skill plus every
universal sub-skill whose change type the diff matches. When the agent
is already mid-edit on an adjacent concern (e.g. writing an async
block), that sub-skill fires on its own — this full pass is the
belt-and-suspenders sweep before commit.

---

## Step 2: Apply or report

Each sub-skill classifies its own findings; aggregate them here:

- **Auto-fixable** (rename, add constant, wrap line, add missing
  import sort, add doc stub) → apply silently and note in the
  commit message.
- **Requires judgment** (restructure nested ternary, add test,
  extract function) → surface as a suggestion before committing.
  Present: what the finding is, where, and a concrete fix sketch.
- **Conflicts with project config** → suppress the finding; never
  fight the linter.

After the pass, summarize:

> "Workstyle pass: {n} auto-fixed, {m} suggestions, {p} suppressed
> (project config). Sub-skills run: {list}. Changed files: {list}."

---

## Hard Rules

1. **Never override project settings.** If `.editorconfig` says
   4-space indent, use 4 spaces. If `rubocop.yml` sets 100-col
   width, use 100. Project config always wins.
2. **Do not emit a finding that would require disabling a linter
   rule** to pass. Escalate to user instead.
3. **Coverage reminder is non-skippable.** For any non-trivial
   code addition without a corresponding test, note it. Do not
   silently skip. (Enforced by `wk-workstyle-testing`.)
4. **Stale comment removal is mandatory.** When editing code,
   update or delete adjacent comments that no longer match.
   (Enforced by `wk-workstyle-docs`.)
5. **Sub-skills do not re-run Step 0.** The project-style-authority
   probe lives here and is the single source of truth all sub-skills
   defer to.

---

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| Before any `wk-commit` on a code diff | Run Step 0, route to every matching sub-skill, aggregate |
| `/wk-workstyle scan` | Full pass on all source files in working tree |
| `/wk-workstyle check <path>` | Pass on one file, report only |
| Editing an adjacent concern (async, naming, a `.py` file) | The matching sub-skill auto-fires on its own |
| Finding auto-fixable | Apply, note in commit |
| Finding needs judgment | Surface as suggestion before commit |
| Finding conflicts with project config | Suppress silently |

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn workstyle`).
