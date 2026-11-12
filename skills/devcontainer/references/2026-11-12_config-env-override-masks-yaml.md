---
class: principle
skill: wk-devcontainer
date: 2026-11-12
severity: low
---

**Rule** — When a spec that reads the real config file fails only inside the container, suspect
an exported `CONFIG__<SECTION>__<KEY>` override before the code: list matching env var names
(names only — `env | cut -d= -f1`, never values), re-run the spec with `env -u <VAR>`, and record
the override in the PR test plan instead of treating it as a regression.

**Why** — The config library ranks env vars above the YAML file, so a container that exports an
override for a key silently replaces the YAML `test` value a spec asserts against. With the var
unset, the whole spec passed. Sibling of the conditional-default rule
(`2026-08-17_container-env-defeats-conditional-default.md`): that one prevents the collision at
authoring time; this one diagnoses it in an existing stack. The report's `env | grep ^CONFIG__`
prints values, so the recipe was corrected to a names-only form.

**Where** — `wk-devcontainer` → Common Mistakes table (new row).
