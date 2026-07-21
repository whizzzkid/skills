---
skill: wk-workflow
date: 2026-07-21
type: correction
severity: high
---

Invented a parallel build-time override (dummy env exports) instead of reusing the config-resolution mechanism the codebase already provided.

**What happened:** A production build needed config/secret values to boot a precompile step. The agent added a script exporting dummy override env vars to satisfy the config layer. The user rejected this three times, twice naming the existing config-resolution convention, before the agent pivoted to running the step under an environment whose keys were already fully populated by the existing config file — zero exports, zero secrets, no new file.

**Root cause:** The agent reached for a mechanism it could fully control rather than first checking whether the codebase's own config/CLI already resolved those values under some environment. Escalating pushback was treated as something to defend against rather than a signal to abandon the approach.

**Suggested fix:** Before adding env exports/overrides to make a tool boot at build time, check whether an existing config file, CLI, or environment already resolves the needed values. Treat repeated user pushback naming an existing convention as a hard stop on the invented approach — abandon and adopt the named mechanism.
