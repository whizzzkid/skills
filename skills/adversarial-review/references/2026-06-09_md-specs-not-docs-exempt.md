---
class: principle
skill: wk-adversarial-review
date: 2026-06-09
severity: high
---

- **Rule:** A `.md` file that is a skill instruction or executable
  specification is code — it gets the full adversarial subagent dispatch,
  not just the mechanical sweeps. The "docs-only" exemption applies only to
  changelogs, plain prose, and files with no executable logic.
- **Why:** Skipping the subagent on a markdown-only diff lets real logic bugs
  in instruction files ship; they fail at runtime exactly as source would.
- **Where:** Hard Rule 2 (Mechanical sweeps AND the adversarial subagent
  dispatch run unconditionally).
