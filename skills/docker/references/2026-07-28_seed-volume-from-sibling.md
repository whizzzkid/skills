---
class: principle
---

# A registry credential expiry is not a hard stop for a fresh container

**Rule** — when a provisioning script fails to install dependencies because the
package registry returns 401, check whether a sibling container on the same daemon
already holds a populated dependency volume for the same lockfile generation. If so,
copy the volume with a throwaway container mounting both (`-v "$SRC_VOL":/from
-v "$DST_VOL":/to`, `cp -a /from/. /to/`) and install offline from the seeded cache.
Guard on two things: the source volume must be the same lockfile generation, and both
volume names must be confirmed via `docker volume ls` before the copy.

**Why** — the provisioning script treats the registry as the only source of
dependencies, so any credential expiry blocks setup entirely even though every needed
artifact is already present on the same daemon. Seeding turns a blocking outage into
an offline install. The same-lockfile guard matters because the offline install then
fails loudly on a missing version instead of silently resolving a stale one; the
name-verification guard matters because volume names are project-prefixed
(`<project>_<volume>`) and a mistyped destination silently creates a new empty volume,
so the copy "succeeds" into nothing and the failure surfaces much later.

**Where** — `skills/docker/SKILL.md` → *Seed a Dependency Volume from a Sibling*;
reached from `skills/devcontainer/SKILL.md` → *Common Mistakes* registry-401 row.
