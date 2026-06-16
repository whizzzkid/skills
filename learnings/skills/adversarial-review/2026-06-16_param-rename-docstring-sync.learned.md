---
skill: wk-adversarial-review
date: 2026-06-16
type: gap
severity: medium
---

Parameter rename must sync class-level docstring in the same commit.

**What happened:** A method parameter was renamed from a broad name to a more precise one (e.g. reflecting that only a subset of a count matters, not the total). The class-level docstring described the method's entry condition using the old semantic ("no findings" vs "no blocking findings"). A bot review flagged the stale docstring in a subsequent CI cycle, requiring a follow-up commit.

**Root cause:** The rename sweep checked callers and the method signature but not the class-level docstring, which described the method's contract in terms of the old parameter meaning. Class docstrings are prose, so a symbol-rename grep does not catch them.

**Suggested fix:** Add a docstring sweep step to the rename checklist: after renaming any parameter, grep the owning class's documentation block for the old parameter name AND for any behavioral phrase it qualified (e.g. "no findings", "zero findings") — stale semantic claims in class docstrings are a top bot-review flag.
