---
skill: wk-gh
date: 2026-10-29
type: correction
severity: high
verified-against-source: n/a
---

Outbound PR comments were posted without loading wk-gh/wk-tone, so they missed the canonical footer and terseness rule.

**What happened:** During a PR takeover the agent posted two `gh pr comment` bodies directly. One carried the
PR-description attribution line instead of the comment footer; the other had no footer. Both narrated process.

**Root cause:** The calling skill (pr-takeover handoff step) says "post PR comment" without routing through wk-gh, and
the agent treated the handoff comment as covered by the PR-description attribution reminder.

**Suggested fix:** pr-takeover Step 10 (and any skill that posts) should explicitly invoke wk-gh before writing; state
that the system-reminder PR-description attribution is not the comment footer.
