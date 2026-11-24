---
class: principle
source: learnings/skills/docker/2026-11-23_compose-project-lowercase.learned.md
date: 2026-11-23
severity: low
skill: wk-docker
---

## Re-violation: raw basename as the devcontainer Compose project name

- **Rule:** On a devcontainer stack error, load `wk-devcontainer` before retrying. Take the Compose `-p` from
  `composeProjectName` in `devcontainer up`'s JSON output; else lowercase the derived `<basename>_devcontainer`.
- **Why:** A teardown again built `-p` from a raw `basename "$PWD"` and failed with "invalid project name" on a
  mixed-case directory. The lowercase fix shipped in `wk-devcontainer` on 2026-10-14 and the routing pointer here on
  2026-10-20, so this is a re-violation of an installed rule.
- **Escalation:** the routing pointer in Debugging Build Failures moved one rung, baseline → `**Important:**`. The
  owning HARD RULE in `wk-devcontainer` gained the primary source (`composeProjectName`), which is the CLI's own name
  rather than a re-derivation of it.
- **Where:** `SKILL.md` Debugging Build Failures; `wk-devcontainer` "Teardown / rebuild the stack".
