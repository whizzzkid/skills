---
class: principle
---

# A published port is for host access only — don't fight over it

**Rule** — When a sibling worktree's stack already publishes the host port, do not
remap or edit the committed port mapping. Attach a throwaway container to the
running stack's network and named volumes with nothing published; resolve the real
network and volume names from the running stack, since they follow the pinned
Compose project name.

**Why** — The skill documented starting and tearing down a stack but assumed the
host ports were free, so a second worktree had no sanctioned path and the fallback
was discovered ad hoc. The reframing that makes it obvious: a published port
serves *host* access only. Container-to-container traffic already uses the Compose
network, so a task that just needs to run inside the project environment never
needed the port.

**Where** — `skills/devcontainer/SKILL.md` → new subsection before *Common
Mistakes*, plus a mistake-table row keyed on `port is already allocated`.

## The tempting wrong fix

Editing the compose port mapping resolves the symptom locally, breaks the other
worktree, and lands an unrelated diff in the PR. Called out explicitly because it
is the first thing that works and the last thing that should ship.

## Related

The same session hit a registry 401 in one of these manually-started containers.
That is a separate cause — Bundler credentials are keyed by source hostname and a
manual `docker run` inherits nothing — folded into the Cloudsmith skill and
cross-referenced from the mistake table here.
