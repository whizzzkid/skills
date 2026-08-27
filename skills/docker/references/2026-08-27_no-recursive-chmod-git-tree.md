---
class: principle
---

**Rule** — Never use recursive chmod (`chmod -R`) on a git tree or any path
inside a persistent/shared host checkout to fix a container EACCES. Grant
write only on the exact files/dirs the container uid needs. Prefer `chown`
or a dedicated scratch dir outside any real checkout.

**Why** — Recursive world-writable chmod sets the other-write bit across
the entire `.git` tree (objects, refs, config). When the workspace lives
inside a persistent/shared CI host checkout, the loosened perms let the
in-container uid write into the host's git tree — leaving it dirty and
tripping git's dubious-ownership guard, breaking later operations and
requiring manual cleanup.

**Where** — `SKILL.md` → *Bind-Mount Permission Fixes — Scoped, Never Recursive*.
