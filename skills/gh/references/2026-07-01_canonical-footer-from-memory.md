---
class: principle
---

**Rule** — Before composing any outbound GitHub/external body, read the Step 4 footer block and paste it verbatim; never type a "Generated ... wk-skills" line from memory. The `wk-commit` commit-message trailer (`🦾 Generated with [wk-skills](...) and multiple models.`) is a distinct string and must never appear on a GitHub/outbound body. Pre-emit: grep each body for the exact canonical footer AND reject if the commit-trailer variant is present. When a footer defect is found on one surface, sweep every outbound surface in one pass.

**Why** — A dismissal comment shipped with the commit-message trailer instead of the Step 4 outbound footer (`<sup>Generated using ...`); both open with "Generated ... wk-skills", so the memory-typed footer conflated the two. The same wrong footer was live on two surfaces (comment + PR body), fixed one-at-a-time instead of swept together.

**Where** — `wk-gh` Step 4 (outbound footer block).
