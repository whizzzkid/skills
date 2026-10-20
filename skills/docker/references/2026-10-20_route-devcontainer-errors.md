---
class: principle
source: learnings/skills/docker/2026-10-20_bake-fs-entitlement.learned.md
date: 2026-10-20
skill: wk-docker
---

**Rule** — When a Docker-level error comes from the devcontainer CLI's stack (bake fs entitlement on
`devcontainer up`, invalid uppercase Compose project name on teardown), route to `wk-devcontainer`, which owns the
tested fixes, instead of re-deriving them.

**Why** — Both fixes already shipped in `wk-devcontainer` (bake: `BUILDX_BAKE_ENTITLEMENTS_FS=0` on the CLI call;
teardown: lowercase the derived `<basename>_devcontainer`). The same incident was still filed under `wk-docker` twice,
because the Docker skill is the one that activates on the raw error and it carried no pointer. The fix is routing, not a
second copy of the rule. Label escalation in `wk-devcontainer` was not applied: the report repeats the incident already
distilled there (same symptoms and workaround sequence) and carries no evidence that the skill was loaded and
disobeyed.

**Where** — `SKILL.md` → Debugging Build Failures (owner pointer).
