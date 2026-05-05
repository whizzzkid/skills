---
skill: wk-pr-resolve
date: 2026-04-28
type: gap
severity: medium
---

Step 4/5 doesn't prompt to propose a design fix when the reviewer implies the implementation is structurally fragile.

**What happened:** Reviewer showed a condition never fired in their e2e. Draft response was a clarifying reply explaining the contract. User had to redirect: "remove the if-else entirely."

**Root cause:** Skill instructs to generate "a concrete suggested fix" but frames it as fixing the reviewer's specific complaint, not questioning whether the underlying design is wrong.

**Suggested fix:** In Step 4 (Generate Suggestions), add: "If the reviewer's concern is 'this might not trigger' or 'this depends on X being correctly set by an external system,' evaluate whether the design itself is fragile. If so, propose a design fix as the primary option and a clarifying reply as a secondary — do not lead with the explanation."
