---
skill: wk-sharpen
date: 2026-07-31
type: gap
severity: medium
verified-against-source: no
---

Recover when a successful install omits a reference-only skill change.

**What happened:** The normal repository installer reported success after a
new unlinked reference was added without changing its owning `SKILL.md`, but
the active runtime lacked that reference. A targeted copy refresh of the owning
skill installed it, and the byte comparison then passed.

**Root cause:** (unverified — inferred from symptom) The incremental installer
appears to skip refreshing an otherwise unchanged skill package when only an
unlinked reference is new.

**Suggested fix:** Keep the byte comparison authoritative. When a normal install
leaves a changed reference missing or mismatched, explicitly copy-refresh the
owning skill, then repeat the comparison before committing.
