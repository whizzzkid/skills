---
skill: wk-pr
date: 2026-06-29
type: correction
severity: high
---

Skipping adversarial review must not drop the wk-gh outbound footer

**What happened:** User said no adversarial review was needed. Agent skipped wk-gh routing entirely along with the review gate, producing a PR body without the canonical footer.

**Root cause:** Agent conflated "skip the review gate" with "skip wk-gh". These are independent: wk-gh Step 4 (outbound footer) is unconditional on every PR body; the adversarial review gate in wk-pr Hard Rule 2 is separately waivable by the user.

**Suggested fix:** Treat wk-gh routing and footer injection as non-negotiable regardless of any review skip instruction. When user says "no review", suppress only the adversarial-review Skill call — still route through wk-gh and still inject the footer into every `gh pr create` / `gh pr edit` payload.
