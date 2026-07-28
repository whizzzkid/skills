---
skill: wk-commit
date: 2026-07-27
type: surprise
severity: medium
verified-against-source: yes
---

Regenerating a vendored type-stub artifact re-stamps host-OS constants into it — declare the churn in the commit body or a reviewer reads it as collateral damage.

**What happened:** Removing a dependency orphaned a constant referenced by five
vendored type stubs, so they had to be regenerated. Regeneration ran inside the Linux
container the repo mandates for local work, while the committed stubs had been captured
on a macOS host. The diff therefore flipped a batch of platform predicates
(`IS_MAC`/`IS_LINUX`/`IS_BSD`) and added libc/version constants that have nothing to do
with the dependency removal. The new values are the correct ones — CI is Linux — but
the hunks look like unrelated damage inside an otherwise pure deletion.

**Root cause:** The existing rule ([generated-artifact-from-mutable-state]) covers
pollution from *sibling-branch* local state and prescribes restoring to base. This is a
different axis: the local state is legitimate and the regeneration is required, so
restoring to base is wrong. The drift is only invisible because the pipeline verifies
one artifact class and not this one, so the committed stubs had silently diverged from
what any Linux run produces.

**Suggested fix:** Extend the generated-artifact section — when a diff regenerates a
vendored artifact whose content varies by host platform, say so in the commit body:
name the generator, the platform it ran on, the platform the committed version came
from, and which hunks are platform churn rather than change-driven. If the pipeline has
no verify gate for that artifact class, call the missing gate out as a follow-up in the
same commit body; an ungated artifact is how the divergence accumulated.
