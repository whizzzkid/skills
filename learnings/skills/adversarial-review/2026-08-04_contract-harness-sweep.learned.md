---
skill: wk-adversarial-review
date: 2026-08-04
type: pattern
severity: high
verified-against-source: yes
---

API signature changes require a whole-repository sweep of runtime harness stubs.

**What happened:** Unit fakes matched a corrected Promise-only browser API, while a headless
screenshot harness still returned `void` from the old callback-shaped stub and failed before its
visual flow could mount.

**Root cause:** The contract sweep covered production callers and colocated unit fakes but did not
initially include browser and screenshot harnesses that install their own runtime globals.

**Suggested fix:** When a cross-system method signature changes, grep the whole repository for
every stub, injected global, and harness implementation, then drive at least one real consumer of
each distinct harness rather than relying on type-checking alone.
