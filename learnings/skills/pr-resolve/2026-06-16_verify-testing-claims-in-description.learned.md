---
skill: wk-pr-resolve
date: 2026-06-16
type: gap
severity: medium
---

Drafted Testing sections in PR descriptions must not assert results that cannot be confirmed without user input.

**What happened:** When suggesting a rewritten PR description, the agent included a Testing section that claimed a build "completed successfully" — a result the agent had no basis to assert. The claim was fabricated from the description template rather than from known facts.

**Root cause:** The suggestion flow fills out all standard sections (Problem, Approach, Testing) to produce a complete description, but does not gate the Testing section on whether the agent actually knows what testing occurred. Template-filling produces plausible-sounding but unverified assertions.

**Suggested fix:** Before drafting a Testing section in a suggested PR description, check what is known: if no test evidence is available from the diff, CI results, or user statement, write the Testing section as an honest placeholder ("Pending — [describe how to exercise the change]") rather than asserting a result. Flag the placeholder explicitly so the user knows to fill it in.
