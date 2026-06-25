---
skill: wk-workstyle-docstrings
date: 2026-06-25
type: pattern
severity: medium
---

Comments must be terse and WHY-only; use the full 120-col line width.

**What happened:** Agent wrote verbose multi-sentence comments that described WHAT the code does rather than WHY — redundant given well-named identifiers.

**Root cause:** Default tendency to over-explain; no explicit col-width or verbosity constraint enforced.

**Suggested fix:** For every comment, ask: (1) does it explain WHY (hidden constraint, invariant, non-obvious workaround)? (2) could the same thought fit on one 120-col line? Strip anything that describes WHAT rather than WHY. Single-sentence max; use the full width rather than wrapping early.
