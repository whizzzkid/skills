---
class: principle
---

# Mechanical pre-emit lint for praise/thanks openers

**Rule** — Before the `gh api .../replies` POST, grep every reply/dismissal
body's first sentence against `^(good catch|great|thanks|nice|well spotted|good
point)` and reject on a match. The prose "no pleasantry" ban is not enough on
its own.

**Why** — The ban slips exactly when the finding is a genuinely good catch: the
instinct to acknowledge is strongest where the rule applies. A body written and
posted in one step has no gate against the opener the prose rule alone misses.
Escalation of the existing Hard Rule 2 prose ban → structural (mechanical) form.

**Where** — `wk-pr-resolve` Hard Rule 2, mirroring the `wk-gh` footer pre-emit
gate.
