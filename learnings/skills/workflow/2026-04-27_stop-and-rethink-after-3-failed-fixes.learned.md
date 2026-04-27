---
skill: wk:workflow
date: 2026-04-27
type: gap
severity: medium
---

The Phase 6 "max 3 fix attempts" rule needs a stronger trigger — keep going past it as long as each attempt's failure mode is "different" is too easy to rationalize.

**What happened:** Across one PR I pushed eight commits trying to fix one failing CI step (check-links / lychee install): default registry, ubi backend, aqua backend, curl-direct, tarball-layout-fix, `MISE_AUTO_INSTALL`, `MISE_TASK_RUN_AUTO_INSTALL`, `include_fragments` syntax, version pin. Each failure had a "different" surface error, so the "each attempt must be different" check kept passing — but the meta-pattern (chasing surface symptoms instead of stepping back) was the real issue. The eventual fix from the user was a one-line version downgrade.

**Root cause:** The 3-attempt rule's exit condition says "ask the user how to proceed" when 3 consecutive attempts fail. I bypassed it because each attempt looked like progress (different error → different fix). But the right question after attempt 2 wasn't "how do I make this attempt work" — it was "am I varying the right axis?" That meta-question never fired.

**Suggested fix:** Add to Phase 6: after attempt 2, before attempt 3, force a one-line restatement of the axis being varied — "I'm varying the install backend" or "I'm varying the binary install path." If attempts 1, 2, and 3 are all on the same axis, broaden — try a different axis (version, tool choice, dependency removal) on attempt 3, not "the same thing harder." Combine with the existing "ask the user after 3" rule so the bailout converts into a useful question, not a generic "I'm stuck."
