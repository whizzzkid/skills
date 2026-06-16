---
class: principle
---

**Rule**

On a non-fast-forward push rejection (remote diverged), default to `git pull
--no-rebase` (merge) then retry the regular push. Rebase only when the user
explicitly asks for clean linear history.

**Why**

Rebasing an already-published branch rewrites commits and forces a force-push,
which the safe-push classifier blocks — requiring manual user intervention.
Merge preserves SHAs and needs no force.

**Where**

`skills/commit/SKILL.md` → "Pushing" → "Hook and verify rules".
