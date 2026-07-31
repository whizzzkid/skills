---
class: principle
---

# Recover omitted reference-only installs

**Rule:** Keep installed-byte comparison authoritative. When a normal install
omits or mismatches a changed reference, copy-refresh the owning skill with the
same package, scope, and agent targets, then repeat every comparison.

**Why:** Installer success does not prove that an unchanged owning skill was
refreshed with a new unlinked reference.

**Where:** `wk-sharpen` Step 8 install gate and its linked recovery procedure.
