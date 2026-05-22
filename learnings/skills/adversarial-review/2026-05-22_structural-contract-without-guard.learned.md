---
skill: wk-adversarial-review
date: 2026-05-22
type: gap
severity: medium
---

Catch refactors that move from a constrained data structure to an open one without adding an invariant guard.

**Class:** Structural-contract-without-guard.

**Mechanism:** A refactor replaces a constrained shape (e.g., a `"key:value"` string array where collisions could not corrupt structure) with an open hash-merge / dict-update / spread operator that writes user-controlled keys directly into a structural container. Pre-refactor, the contract was enforced by the data shape itself; post-refactor, it relies on caller discipline. Reviewer bots flag the resulting silent-overwrite risk.

**Detection sketch:** In Step 2.7 (signature widening pre-flight), extend the check to data-shape widenings. Grep the diff for added merge / spread / write-into-event patterns:

```bash
git diff "$BASE...HEAD" | grep -nE '\.each \{[^}]*event\[|\.merge\([^)]*\)|\*\*[a-z_]+\b|Object\.assign\(|\{...|hash\.update\('
```

For each hit, verify there is a corresponding `RESERVED_*` constant / allowlist / collision guard in the same commit. If not, flag as suggestion (becomes blocker when the structure has named fields the caller could shadow).

**Confidence:** high — mechanical grep covers most cases; subagent reasoning handles the "do these keys collide with structural fields" question.
