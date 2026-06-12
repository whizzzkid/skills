---
skill: wk-adversarial-review
date: 2026-06-12
type: gap
severity: low
---

Adversarial review cannot predict what an LLM-based CI reviewer will flag in the next build — this is a structural limitation, not a review failure.

**What happened:** Pre-push adversarial review passed. A subsequent CI run with an LLM-based code review bot produced new findings on the just-pushed code. User questioned the value of the review.

**Root cause:** Adversarial review catches mechanical/structural issues (stale refs, signature mismatches, doc comment drift, security patterns). It cannot predict the output of an LLM reviewer evaluating the same diff with different prompts and context. These are different classes of review.

**Suggested fix:** Set correct expectations: adversarial review eliminates an entire class of mechanical failures but does not eliminate LLM-bot review cycles. When a project runs LLM-based CI review, expect at least one bot-comment cycle per push and plan the pr-resolve loop accordingly rather than treating bot findings as an adversarial-review miss.
