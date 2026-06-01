---
skill: wk-workstyle
date: 2026-06-01
type: gap
severity: high
---

wk-workstyle must explicitly audit variable names for semantic accuracy, not just style-guide compliance.

**What happened:** Variables named `serious` and `nitpicks` were used to bucket severity levels in a function. `nitpicks` is semantically inaccurate — the bucket contains minor+info findings, which are not necessarily nitpicky. A human reviewer caught this on the PR and suggested `lowRiskCount` / `highRiskCount` as more accurate names. The skill did not surface this during authorship.

**Root cause:** wk-workstyle's naming guidance likely focuses on formatting conventions (casing, length, abbreviations) rather than semantic accuracy — whether the name truthfully describes the value it holds. A name can pass all formatting rules and still be wrong.

**Suggested fix:** Add a semantic naming check to wk-workstyle: for each variable or identifier the agent introduces, verify that the name accurately describes what the value *means*, not just what it *contains*. Specifically: names that borrow domain vocabulary (e.g., `nitpick`, `blocker`, `critical`) must match the field's actual definition — if the variable holds `Minor + Info` findings, a name implying "trivial style comments" is wrong even if it passes casing rules. The check should be a required gate, not advisory.
