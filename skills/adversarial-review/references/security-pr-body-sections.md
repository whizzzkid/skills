---
class: principle
---

**Rule**

When the diff touches token scope, secret access, or privilege escalation, verify
the PR body carries `## Problem`, `## Approach`, and `## Testing`
(`grep -E "## Problem|## Approach|## Testing" <pr_body>`). Any absent section is a
blocker. Sweep 2.40.

**Why**

Security-sensitive changes were authored with the same placeholder bodies as
routine PRs; description checks flag missing Problem/Approach/Testing as Major
findings. The rationale for an elevated scope must be explicit and reviewable.

**Where**

`skills/adversarial-review/SKILL.md` → sweep 2.40.
