---
skill: wk-adversarial-review
date: 2026-07-23
type: pattern
severity: medium
---

Author-facing docs asserted a validation/auto-fix feature applied to a broader
file class than the code actually covered.

**What happened:** A PR wiring version + content-hash drift enforcement for one
class of config files (core checks, gated by a `--skills-dir` flag) also added
author docs telling authors of a *second* class (repository-local checks) to rely
on the same `--auto-bump` auto-management and "validate rejects stale hash" drift
gate. The enforcement/auto-bump code only ever touched the first class; the second
class flowed through a separate validator that never inspected the fields. Authors
following the docs would run auto-bump, see no change, and get false assurance of a
drift guard that never fired for them.

**Root cause:** A field can be *parsed and emitted* for a file class (so it looks
supported) while the *enforcement/auto-fix* machinery is scoped to only one class.
Doc sweep 2.4 must separate "recognized/parsed" from "enforced/auto-managed" —
they are different guarantees with different code paths.

**Suggested fix:** When a diff adds docs claiming a validate/auto-fix/enforcement
behavior, grep the enforcement entrypoint for its scope argument (dir flag, glob,
type filter) and confirm every file class the docs address actually reaches that
code path — not merely that the field is parsed elsewhere. A staged/multi-part
rollout is the high-risk case: docs commonly describe the end-state while the
current part covers a subset. Flag any doc claim of current enforcement for a
class the current code excludes.
