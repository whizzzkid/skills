---
class: principle
---

# Report merge gates by source — repo-enforced vs skill convention

**Rule**

- When telling the user what stands before merge, separate repo-enforced gates (required checks, branch protection,
  CODEOWNERS — read from the platform, never assumed) from skill conventions.
- Label a skill convention as such (e.g. "skill convention: adversarial review before merge"); never present it as a
  merge blocker or "needed before merge".

**Why**

- After marking a PR ready, the agent said the adversarial review "is needed before merge". The repo and its branch
  protection require no such thing; the skill's "review gates merge" rule governs the agent's own merge path, and was
  reported as if the platform enforced it.
- The convention itself stands — the agent still runs the review before an agent-performed merge. Only the claim about
  who enforces it was wrong.

**Where**

`skills/pr/SKILL.md` → Hard Rule 2.
