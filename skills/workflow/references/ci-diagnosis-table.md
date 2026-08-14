---
class: reference
---

# CI failure diagnosis signals

Map a failure type to its action.

| Failure type | Action |
|---|---|
| Code failure | Diagnose root cause; apply the smallest fix |
| Flaky test | Re-trigger once; if it repeats, treat as real |
| Infrastructure | Re-trigger; if persistent, inform user — no code fix |

Map a CI error signal to the first thing to check.

| Error signal | Check |
|---|---|
| `no version is set`, `couldn't resolve latest`, `unknown tag` | Version-pinning rule |
| `auth failed`, `unauthorized`, `expired token` | Env-var / secrets provenance |
| `permission denied` on a script | Executable bit (`chmod +x`) |
| `command not found` for a project tool | Tool manifest (`mise.toml`, `.tool-versions`) |
| New third-party Action on org-managed runner | Prefer `actions/*` or non-action install; ask before adding |
| `verify`/typecheck fails on a committed generated file (RBI/type-sig, schema dump, DSL output) | A construct feeding a DSL/codegen/type compiler was added without regenerating — regenerate (e.g. `bin/tapioca dsl <Class>`) and commit it standalone (per `wk-commit`) before push |

## CI-fix rules

- Coupled config rule: when changing a tool version, audit every config file that tool reads in the same commit.
- CI-only fix evidence: prove the concrete environment delta and keep the fix scoped to it.
- If failure was caused by stale base, integrate latest base first.
- If CI cannot be reproduced locally, inspect the full remote log before changing code.
