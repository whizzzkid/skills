---
class: principle
---

# Auth-boundary diffs: check every background fetch on public pages

**Rule**

- Brief the subagent to list each background fetch (lazy frame, poller, stream) on public pages and check its target
  against the new auth boundary; reproduce each resulting `question` in a no-session browser before closing it; flag
  ancestry-only audit specs as a coverage gap.

**Why**

- Reviewing an auth-tightening change, the subagent raised an unrun `question`: a poller on a public page pointed at a
  now-protected route. A no-session browser confirmed the frame broke after the first poll tick. The bug predated the
  change, so it went to a separate ticket. The same review found an audit spec that checked class ancestry, so a
  re-added skip guard on a subclass still passed it.

**Where**

`skills/adversarial-review/references/subagent-stances.md` → Auth-boundary-aware (briefed from `SKILL.md` Step 3).
