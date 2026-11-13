---
class: principle
skill: wk-workstyle-rails
date: 2026-11-12
severity: medium
---

**Rule** — After any routes-file edit, regenerate DSL RBIs with a plain `bin/tapioca dsl`, never a
constant-scoped subset; never pass a constant that does not resolve; check `git status` for deleted
RBIs before staging.

**Why** — Tapioca's URL-helper compiler builds its RBIs from the application's named routes, so
every route change alters them regardless of which models or jobs were touched; a subset run leaves
them stale and CI's `tapioca dsl --verify` fails. When `tapioca dsl` is given an unresolvable
constant, its `constantize` step prints `Error: Cannot find constant '<Name>'` and removes that
constant's generated RBI file before raising (verified against the installed tapioca gem source).

**Where** — `wk-workstyle-rails` → Generated RBIs after a routes edit (Tapioca); routing row in
`wk-workstyle`; example in `wk-workflow` CI-diagnosis table corrected to name the full run.
