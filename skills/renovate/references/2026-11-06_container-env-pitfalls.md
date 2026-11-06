---
class: principle
source: learnings/skills/renovate/2026-11-06_container-env-pitfalls.learned.md
date: 2026-11-06
skill: wk-renovate
---

**Rule** — Regenerating a lockfile inside a container: reproduce the provisioning script's registry-credential export
in the same exec shell, re-derived from that script, never pasted as a literal. A deterministic red in a container:
list forwarded config-override var names (never values) and rerun with them unset before blaming a bump.

**Why** — A lifecycle script's `export` lives only in its own shell, so container creation installs fine while every
later `exec` session fails registry auth. Separately, a compose file that forwards host config-override vars into the
container overrides the test-env config value a spec reads; the base-branch control reproduces the same red in the
same env, so it can classify the failure as pre-existing without ever pointing at the environment.

**Classification** — `partial`: the base-branch control (installed 2026-10-20) covered bump attribution but not the
environment as a confounder; container exec-session credential scope was only stated for a manual `docker run`.

**Rejected suggestion** — pasting the credential export "inline in the exec command" as a literal value: it lands the
secret in shell history and process listings; re-derive it from the provisioning script instead.

**Where** — `SKILL.md` → Step 3 (container-regen credential bullet) and Step 4 (container env-override bullet); README
Key Rules. Mechanics home broadened: `wk-devcontainer` Common Mistakes registry-`401` row now covers later
`devcontainer exec` sessions.
