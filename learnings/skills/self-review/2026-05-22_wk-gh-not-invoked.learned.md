---
skill: wk-self-review
date: 2026-05-22
type: correction
severity: high
---

Self-review posted GitHub comments without invoking `wk-gh` first.

**What happened:** The skill executed its GitHub read/write steps (fetching PR details, posting the pending review) without invoking `wk-gh` for org scoping and the canonical outbound footer, even though the skill's HARD RULE at the top explicitly requires it.

**Root cause:** The HARD RULE exists in the skill text but there is no enforced checkpoint — the agent proceeded directly to `gh` calls without pausing to invoke `wk-gh`. The rule was read but not acted on.

**Suggested fix:** Add a mandatory gated Step 0 before any GitHub interaction:

> **Step 0 (MANDATORY):** Invoke `wk-gh` before any `gh` or GitHub API call. Do not proceed until `wk-gh` confirms org scoping. Append its canonical outbound footer to every inline comment body at payload-render time.

This converts the prose HARD RULE into a numbered, sequenced step that the agent cannot skip without visibly violating the workflow order.
