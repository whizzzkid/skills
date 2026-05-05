---
skill: wk-retro
date: 2026-04-23
type: pattern
severity: medium
---

Two awk range pitfalls surfaced when writing bats structure tests for a shell script.

**What happened:** (1) Bare `fi` as awk end-range matched "fi" inside string literals, terminating the range too early. (2) Single-stage awk matched the first of two case blocks with identical branch labels instead of the intended second block.

**Root cause:** awk range patterns are substring matches, not keyword matches. Shell scripts with duplicate case labels or string literals containing shell keywords trigger false-positive range termination.

**Suggested fix:** Add a "Common awk pitfalls for bats structure tests" note to the retro skill or bats testing guidance: always anchor end-ranges to full lines (`/^[[:space:]]*fi[[:space:]]*$/`), and use two-stage awk when duplicate case labels exist.
