---
class: principle
---

# Dev-only container env overrides reach the test suite; post-create reads the live tree

**Rule** — Every opt-in dev override added to the compose `environment:` block ships with a test-suite guard: unset
the vars in a test support file loaded before any config read, document it, and prove it with a negative control.
Settle the git branch before `devcontainer up`; after a switch, re-run the post-create steps.

**Why** — Compose `environment:` applies to every process in the container regardless of the app environment. An opt-in
override (config-source env vars) turned a feature on under the test env too, so specs could reach the network; removing
the guard failed four specs. A pre-existing override had already caused an unrelated spec failure the same way.
Separately, switching branches while post-create's dependency install ran changed the lockfile mid-install and produced
`GemNotFound` on the next step.

**Where** — `SKILL.md` → Steps 2-4 (two bullets) and the Common Mistakes table (`GemNotFound` row). Sibling of the
conditional-default HARD RULE in `config-templates.md` (that rule forbids overriding what bootstrap defaults; this one
covers deliberate overrides that must stay but must not leak into tests) and of the existing diagnosis row for a
`CONFIG__` override masking the YAML file.
