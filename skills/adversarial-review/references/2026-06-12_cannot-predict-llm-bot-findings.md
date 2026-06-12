---
class: one-off
date: 2026-06-12
skill: wk-adversarial-review
---

- **Scenario:** A project runs an LLM-based CI code-review bot; pre-push
  adversarial review passed but the bot flagged new findings post-push.
- **Symptom:** User questions the value of adversarial review when bot
  findings still appear after a clean pre-push pass.
- **Fix:** Set expectations — adversarial review eliminates a class of
  mechanical/structural failures (stale refs, signature mismatches, doc
  drift, security patterns) but cannot predict an LLM reviewer's output on
  the same diff under different prompts. Expect ≥1 bot-comment cycle per
  push; plan the wk-pr-resolve loop (Step 9.5 loop-until-mergeable)
  accordingly rather than treating bot findings as an adversarial miss.
- **Why not promoted:** Expectation-setting, not an actionable check; the
  loop-planning action is already covered by wk-pr-resolve Step 9.5.
