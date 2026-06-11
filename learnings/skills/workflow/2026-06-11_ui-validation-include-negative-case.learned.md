---
skill: wk-workflow
date: 2026-06-11
type: gap
severity: medium
---

End-to-end UI validation must include a deliberately non-matching input, not only positive cases.

**What happened:** After implementing case-insensitive codebase matching, the agent validated the feature with correct-casing inputs only. The user then tested a wrong-casing input and found it failed — exposing that the fix was incomplete at that point.

**Root cause:** The validation step only verified "does the feature work for the happy path" without checking "does an input that *should* match via the new behavior actually match." Positive-only tests cannot prove a transformation was applied; only a formerly-failing case turned passing proves it.

**Suggested fix:** Add to wk-workflow's validation checklist: after implementing any case/normalization/transformation feature, include at least one test input that *used* to fail and now must succeed. Confirm the result in the UI or test output before declaring the feature done.
