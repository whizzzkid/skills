---
skill: wk-pr-resolve
date: 2026-06-26
type: correction
severity: high
---

Judgment-required consultation messages must include the full suggestion block per item — not bare letter references or codes.

**What happened:** The skill sent a consultation prompt listing items as "A+C, D, B" without restating the comment body, fix plan, or skip rationale for each. The user could not interpret the prompt without that context and had to ask for clarification.

**Root cause:** The pre-emit count gate checks that only one `Comment {n}` header exists per message, but it does not verify that each item carries the full suggestion block (comment body, what changed, fix plan, skip rationale). Counting headers is necessary but not sufficient — a valid one-item message can still omit essential context if the agent summarizes instead of restating.

**Suggested fix:** Add a completeness check to the pre-emit gate: before sending any Step 5 judgment-required message, verify that the suggestion block for the single item contains at minimum (a) the original comment body or a direct quote, (b) the proposed fix, and (c) the skip rationale. If any of these are absent, require the agent to reconstruct them from the source before sending.
