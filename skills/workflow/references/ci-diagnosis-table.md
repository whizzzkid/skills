---
class: reference
---

# CI failure diagnosis signals

Map a CI error signal to the first thing to check.

| Error signal | Check |
|---|---|
| `no version is set`, `couldn't resolve latest`, `unknown tag` | Version-pinning rule |
| `auth failed`, `unauthorized`, `expired token` | Env-var / secrets provenance |
| `permission denied` on a script | Executable bit (`chmod +x`) |
| `command not found` for a project tool | Tool manifest (`mise.toml`, `.tool-versions`) |
| New third-party Action on org-managed runner | Prefer `actions/*` or non-action install; ask before adding |
| `verify`/typecheck fails on a committed generated file (RBI/type-sig, schema dump, DSL output) | A construct feeding a DSL/codegen/type compiler was added without regenerating — regenerate (e.g. `bin/tapioca dsl <Class>`) and commit it standalone (per `wk-commit`) before push |
