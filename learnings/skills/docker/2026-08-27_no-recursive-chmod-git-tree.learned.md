---
skill: wk-docker
date: 2026-08-27
type: correction
severity: high
verified-against-source: yes
---

Never `chmod -R a+rwX` a git tree, and never loosen perms on a bind mount that lives inside a persistent/shared CI host checkout.

**What happened:** To fix an EACCES where a container's dropped non-root uid
could not write `.git/info/exclude` in a bind-mounted scratch workspace, the fix
ran `chmod -R a+rwX` over the whole workspace. That set the other-write bit
across the entire `.git` tree (objects, refs, config). Because the scratch dir
lived inside a persistent/shared CI host checkout, the loosened perms let the
in-container uid write into a git tree on the host — leaving the host's git tree
dirty and requiring a human to clean it up manually the next morning. It also
trips git's dubious-permissions guard, breaking later git operations.

**Root cause:** A recursive world-writable chmod was used as a blunt fix for a
single-path EACCES. The blast radius (all of `.git`, on a shared host) was never
scoped to the actual write target.

**Suggested fix:** When a container's dropped uid needs to write into a
bind mount, grant write ONLY on the exact files/dirs it touches (e.g. the one
git-exclude file + the output dir), never `-R` over `.git`. Prefer `chown` to
the container uid or a dedicated scratch dir OUTSIDE any real checkout over
loosening perms. Treat any recursive perm change on a git tree, or any perm
change on a path inside a persistent/shared host checkout, as a red flag.
