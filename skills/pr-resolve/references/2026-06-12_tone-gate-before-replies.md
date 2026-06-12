---
class: principle
date: 2026-06-12
severity: high
---

- **Rule:** Gate every outbound reply/dismissal body through `Skill(wk-tone)`
  before it is drafted or posted.
- **Why:** Reply bodies are prose posted as the user; without the tone gate,
  banned register ("good catch") ships and a post-hoc correction on a live
  comment is visible and embarrassing.
- **Where:** wk-pr-resolve → Hard Rule 2 (tone-gate sub-bullet), alongside the
  wk-gh footer applied at payload-render time.
