---
class: principle
skill: wk-adversarial-review
date: 2026-06-09
severity: medium
---

- **Rule:** When a build/correctness flag or env is added to one toolchain
  invocation, grep the whole repo for every sibling invocation and require
  each to apply or justify the same flag; prefer a top-of-script
  `export <TOOL>FLAGS=...` over per-call flags.
- **Why:** A fix on one call site that misses analogous sites is a partial
  fix — CI runs the missed ones. "Works locally" is weak evidence when the
  behavior is environment-dependent (a linked worktree masks what a fresh
  clone exposes).
- **Where:** Sweep 2.2 (Sibling-script audit), Toolchain-invocation siblings.
