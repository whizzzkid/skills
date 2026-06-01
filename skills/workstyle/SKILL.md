---
name: wk-workstyle
description: >-
  Code-quality gate applied to every file the agent writes or edits. Enforces
  language-agnostic best practices (naming, documentation, structure, constants,
  async patterns, testing intent) and language-specific idioms, while always
  deferring to the project's own linter or style guide. Auto-invoked whenever
  the agent writes, edits, or refactors code. All skills that modify code must
  invoke this skill before committing. Reminder: project settings are
  authoritative — this skill fills gaps only.
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
  version: '2026.06.01-213734'
  internal: false
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Workstyle

Quality checklist applied to every code write or edit. Project settings
are authoritative — this skill fills gaps only, never overrides.

**Invocation modes:**

| Mode | Trigger |
|------|---------|
| Auto | Before any `wk-commit` on a code-change diff; after any Edit/Write to a source file |
| `wk-adversarial-review` | Step 2 mechanical sweeps include a workstyle pass |
| Manual | `/wk-workstyle scan` — full repo scan; `/wk-workstyle check <path>` — single file |

---

## Step 0: Detect project style authority

Probe for existing style enforcement. Run once per session; cache
the result.

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

- If a config governs a rule below, **that config wins**. Do not emit
  a workstyle finding that contradicts an active config.
- If no config governs a rule, apply the workstyle default.
- Never emit a finding that would require adding `// eslint-disable`,
  `# rubocop:disable`, or equivalent to pass — escalate to user.

---

## Step 1: Universal rules (all languages)

Apply to every file the agent touches, unless the project config
explicitly sets a different value.

### Layout

- **Column width 120.** Wrap lines that exceed 120 characters.
  If `.editorconfig` or a linter sets a different value, use that.
- **Spaces, not tabs.** Two-space indent for general languages;
  four spaces for Python (PEP 8). If the project uses tabs (Go,
  Makefile), follow the project.
- **Imports / requires / uses at the top.** Group and sort:
  standard library first, then third-party, then local. A blank
  line between each group. Never scatter imports mid-file.

### Naming

- **Descriptive variable names.** Never single-letter except loop
  indices (`i`, `j`, `k`) in trivial loops. Avoid abbreviations
  (`userCount` not `usrCnt`, `initialize` not `init` in method
  names).
- **Constants in ALL_CAPS** (unless project convention differs, e.g.
  Go exported identifiers use PascalCase, Rust uses SCREAMING_SNAKE).
  Never hardcode a string or number that recurs or carries semantic
  meaning — assign it a named constant.
- **Boolean variables and functions read as assertions.**
  `isLoading`, `hasPermission`, `canRetry` — not `loading`, `perm`,
  `retry`.
- **Names must be semantically accurate, not just well-formatted.**
  Verify each introduced identifier truthfully describes what its value
  *means*, not merely what it *contains* — a name can pass every casing,
  length, and abbreviation rule and still lie. Names that borrow domain
  vocabulary (`blocker`, `critical`, `nitpick`, `error`, `warning`) must
  match the field's actual definition: a bucket holding `minor + info`
  findings named `nitpicks` is wrong, since minor issues are not
  necessarily trivial. Prefer a name keyed to the real boundary
  (`lowRiskCount` / `highRiskCount`). This is a **required gate**, not
  advisory — surface an inaccurate-name finding even when formatting is
  clean.

### Structure

- **No nested ternaries.** One ternary level maximum. Nested
  ternaries → `if/else` or early-return.
- **Guard clauses first.** Return / throw / raise early for
  invalid preconditions rather than wrapping the whole body in an
  `if`. Max nesting depth: 3 levels. Beyond that, extract a function.
- **Single responsibility.** Each function does one thing. Target
  ≤ 30 lines per function (tooling can't enforce this; apply judgment).
- **No magic numbers or magic strings.** Every literal that has
  semantic meaning gets a named constant. `MAX_RETRY_ATTEMPTS = 3`
  not bare `3`. Exception: `0`, `1`, `-1`, `""`, `true`, `false`
  in obvious arithmetic context.
- **No boolean trap parameters.** `createUser(true)` says nothing.
  Use an options object, named keyword args, or an enum:
  `createUser({ notify: true })`.
- **No commented-out code.** Delete it. Git is the history. If it
  must stay for reference, add a comment explaining why it's
  preserved — not just the dead code itself.
- **Avoid duplication.** Before pasting or rewriting a block that
  resembles existing code, grep the codebase for the operation and
  reuse or extract. Three near-duplicates in the diff (or across the
  repo) is the threshold for extracting a helper — once duplication
  ships, every consumer accretes tests against its copy and
  consolidation cost climbs.
  - Two duplicates can stay; copy-paste the third time means lift.
  - Pure-coincidence similarity (same shape, unrelated semantics)
    is not duplication — do not force an abstraction across it.
- **Invoke `wk-refactor` when duplication is frequent.** If the
  current change touches ≥ 3 near-identical sites, or the codebase
  already carries ≥ 5 copies of a pattern the change extends,
  invoke `wk-refactor` to lift-and-migrate **before** extending the
  pattern further. Match the lift → migrate → extend ordering from
  `wk-workflow`'s prefactor probe; new behavior rides on top of the
  helper, not alongside another copy.

### Async and concurrency

- **No temporal dependencies between async calls.** Do not rely on
  one concurrent operation having completed by the time another
  reads its result unless the dependency is explicit (await, join,
  channel, mutex). Temporal coupling is a race condition waiting to
  surface.
- **No unbounded async chaining.** `.then().then().then()` > 2
  levels → extract named async function and `await` each step.
  Chains obscure error provenance and break stack traces.
- **Propagate errors from async operations.** Never `.catch(() => {})`
  silently. At minimum log and re-throw. If ignoring the error is
  intentional, leave a one-line comment saying why.

### Documentation

- **JSDoc / docstring for every new public function, method, or
  class.** Document: what it does (one sentence), parameters with
  types, return type and shape, exceptions thrown. For non-JS
  languages use the language-native equivalent (Python docstring,
  Rustdoc `///`, Go doc comment, Ruby YARD, etc.).
  - Skip for trivial private helpers where the name is self-
    explanatory and the signature is ≤ 2 obvious params.
- **Comment critical decisions.** Leave a one-line comment when:
  - A non-obvious algorithm or formula is used.
  - A counterintuitive value or order is required.
  - A workaround for an external bug or constraint exists.
  - A performance trade-off was consciously made.
  Do NOT comment what the code does (that's what the code is for).
  Comment WHY it does it that way.
- **No stale comments.** When editing code, update or delete any
  comment that no longer accurately describes the adjacent code.
  Stale comments are worse than no comment.

### Testing

- **Cover new lines.** For every function or branch added in the
  diff, ask: does a test exercise this path? If the answer is no
  and the code is non-trivial, add a test. Exceptions: one-off
  scripts, migration runners, CLI entry-point scaffolding, trivial
  delegators that are covered transitively.
- **Tests assert behavior, not implementation.** Avoid tests that
  assert internal state or private method calls. Test the
  observable outcome.
- **Sad-path tests are mandatory** for any error-handling branch.
  A function that throws/returns-error with no corresponding test
  is untested error handling.

### Error handling

- **Never swallow errors silently.** Every `catch`/`rescue`/`except`
  must log, re-raise, or translate into a domain-specific error.
  Empty catch blocks are always a finding.
- **Distinguish operational errors from programmer errors.** Operational
  (network timeout, file not found) → handle gracefully.
  Programmer (null passed where required) → throw hard, fail fast.

---

## Step 2: Language-specific rules

### TypeScript / JavaScript

- **`const` over `let`; never `var`.**
- **No `any` in TypeScript.** Use `unknown` when the type is
  genuinely unknown; narrow before using. `any` defeats the type
  system.
- **Explicit return types on public functions.** TypeScript inference
  is not documentation.
- **Arrow functions for callbacks; named functions for top-level
  declarations.** Anonymous `function` expressions → arrow unless
  `this` binding is needed.
- **Nullish coalescing (`??`) over `||`** for defaulting — `||`
  treats `0`, `""`, `false` as missing.
- **Optional chaining (`?.`) over guard chains** (`x && x.y && x.y.z`).
- **Destructure at the call site** when using ≥ 3 fields from an object.
- **`Promise.all` for independent async operations;** never sequential
  `await` when operations don't depend on each other.

### Python

- **Type hints on all public functions** (PEP 484). Use `from __future__ import annotations` for forward refs.
- **f-strings** over `.format()` or `%` interpolation.
- **`dataclass` or `TypedDict`** for structured data bundles, not raw dicts.
- **`pathlib.Path`** over `os.path` string manipulation.
- **Context managers** for every resource that must be closed.
- **`logging`** over `print` for anything that isn't script output.
- **No mutable default arguments.** `def f(items=[])` → `def f(items=None)` with `items = items or []`.

### Ruby

- **Predicate methods end in `?`**; mutating methods end in `!`; follow the Ruby naming contract.
- **`frozen_string_literal: true`** magic comment in every file.
- **Guard `return` / `next` / `break`** at the top of a method rather than `unless … else`.
- **Prefer `map`, `select`, `reduce`** over imperative loops.
- **`raise` specific exception subclasses**, not bare `RuntimeError`.
- **No `rescue Exception`** — rescue `StandardError` at most unless explicitly handling signals.
- **ASCII-only in source comments.** Use `-`, `->`, `--`, `...` — not em dash (`—`), en dash (`–`), smart quotes,
  or Unicode ellipsis. RuboCop's `Style/AsciiComments` enforces this in many Ruby shops; the cop default is
  ASCII-only. Applies to `.rb` files and bin scripts loaded as Ruby.

### Go

- **Errors are values — handle them immediately** after every function call that returns one.
- **`fmt.Errorf("context: %w", err)`** to wrap with context; never discard.
- **Table-driven tests** for any function with multiple input variants.
- **Unexported identifiers** for package-internal state; only export the minimal API.
- **No `panic` in library code** — return an error.
- **`defer` for cleanup** (close, unlock) immediately after acquire.

### Rust

- **No `.unwrap()` or `.expect()` in production code paths** — propagate with `?` or match.
- **Prefer `&str` over `String`** for parameters that don't need ownership.
- **Derive `Debug`** on all public types.
- **`clippy::all`** passes before commit.
- **Document public items** with `///` doc comments; include an `# Examples` section for non-trivial items.

### Shell (bash/sh)

- **`set -euo pipefail`** at the top of every script.
- **Quote every variable** — `"$var"` not `$var`. Unquoted variables split on whitespace.
- **`local`** for all variables inside functions.
- **`[[ … ]]`** over `[ … ]` in bash.
- **Heredoc** for multi-line strings; avoid concatenated `echo` chains.
- **Named constants** for magic values at the top of the script.
- **Probe capability, don't parse error text.** Detect support for a flag or feature by running it against a known-good input and branching on the exit code — never by grepping the stderr wording. Error strings differ between GNU coreutils, BSD/macOS, BusyBox, and library wrappers, so wording-based fallbacks fail closed on the variant they were supposed to handle.

  ```bash
  # WRONG — wording varies by vendor (BusyBox vs GNU vs macOS)
  if tool -flag -- "$arg" 2>&1 | grep -q "invalid option"; then
      fallback
  fi

  # CORRECT — capability probe
  if tool -flag -- /known-good >/dev/null 2>&1; then
      use_tool
  else
      fallback
  fi
  ```

---

## Step 3: Apply or report

For each finding:

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
> (project config). Changed files: {list}."

---

## Hard Rules

1. **Never override project settings.** If `.editorconfig` says
   4-space indent, use 4 spaces. If `rubocop.yml` sets 100-col
   width, use 100. Project config always wins.
2. **Do not emit a finding that would require disabling a linter
   rule** to pass. Escalate to user instead.
3. **Coverage reminder is non-skippable.** For any non-trivial
   code addition without a corresponding test, note it. Do not
   silently skip.
4. **Stale comment removal is mandatory.** When editing code,
   update or delete adjacent comments that no longer match.

---

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| Before any `wk-commit` on a code diff | Full pass on touched files |
| `/wk-workstyle scan` | Full pass on all source files in working tree |
| `/wk-workstyle check <path>` | Pass on one file, report only |
| Finding auto-fixable | Apply, note in commit |
| Finding needs judgment | Surface as suggestion before commit |
| Finding conflicts with project config | Suppress silently |

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn workstyle`).
