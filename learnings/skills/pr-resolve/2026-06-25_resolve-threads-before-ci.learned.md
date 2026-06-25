---
skill: wk-pr-resolve
date: 2026-06-25
type: correction
severity: medium
---

Resolve bot review threads immediately after pushing the fixing commits — do not wait for CI.

**What happened:** After pushing commits that addressed bot review findings, the skill waited for CI to complete before resolving the review threads. CI failed on an unrelated flake, and the threads remained open until the user prompted resolution manually.

**Root cause:** The skill's Step 8 flow groups push → reply → resolve as a single sequence, with CI polling (Step 9.5) implicitly delaying thread resolution. No explicit instruction separates "resolve addressed threads" from "wait for CI."

**Suggested fix:** After a successful `git push` in Step 8, immediately resolve all threads whose findings were addressed by the pushed commits — regardless of CI state. CI failures after that point belong to a different commit context. The resolve step should be gated on "did the commit address this finding?" not "did CI pass?"
