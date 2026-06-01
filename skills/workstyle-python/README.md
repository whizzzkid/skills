# wk-workstyle-python

> Enforces idiomatic, type-safe Python style on every `.py` file the agent writes or edits.

## Invocation

| Mode | Trigger |
|------|---------|
| Model-invocable | Automatic whenever the agent writes or edits a `.py` file |
| User-invocable | `/wk-workstyle-python scan` — full tree; `/wk-workstyle-python check <path>` — one file |

## Rules at a Glance

- Type hints on all public functions (PEP 484); `from __future__ import annotations` for forward refs.
- f-strings over `.format()` or `%` interpolation.
- `dataclass` or `TypedDict` for structured data bundles, not raw dicts.
- `pathlib.Path` over `os.path` string manipulation.
- Context managers for every resource that must be closed.
- `logging` over `print` for anything that isn't script output.
- No mutable default arguments — use `None` sentinel with `items = items or []`.

## Noteworthy

- **Project config is always authoritative.** Defers to any active linter /
  formatter config; fills gaps only.
- **Part of the [`wk-workstyle`](../workstyle/README.md) family** — the [`wk-workstyle`](../workstyle/README.md) orchestrator runs
  the shared project-style-authority probe (Step 0) and routes to this skill
  based on the touched files / change type. This skill is also independently
  model-invocable on adjacent work.
- No mutable default arguments — the classic `def f(items=[])` shared-state bug is a finding.
- Structured data uses `dataclass`/`TypedDict`, resources use context managers, and `logging` replaces `print`.
