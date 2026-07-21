---
class: principle
---

# Reuse the existing config mechanism; escalating pushback is a stop signal

**Rule** — Before inventing a parallel override (dummy env exports, a new config
path) to make a tool boot or resolve config/secret values, check whether an
existing config file, CLI, or environment already resolves those values and use
it. Treat repeated user pushback naming an existing convention as a hard stop on
the invented approach — abandon it and adopt the named mechanism.

**Why** — Reaching for a mechanism the agent can fully control, rather than the
codebase's own resolution, invents a parallel path that "works" locally but
diverges from CI/deploy and duplicates a named convention. On an asset-precompile
fix the user rejected a dummy-env-export approach three times before the agent
pivoted to running the step under an environment already fully populated by the
existing config file — zero exports, zero secrets, no new file. Escalating
pushback was treated as something to defend against rather than a signal to
abandon the approach.

**Where** — `wk-workflow` Phase 2 Code Standards; reuse-hygiene in
`references/code-standards-extended.md`.
