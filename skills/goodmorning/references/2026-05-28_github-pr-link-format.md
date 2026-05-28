---
class: principle
date: 2026-05-28
source: learnings/skills/goodmorning/2026-05-28_github-pr-link-format.md
severity: low
---

- **Rule:** Label every GitHub PR/issue link as `repo#number`; bare `#NNN` is forbidden everywhere in the brief.
- **Why:** Bare numbers lose repo context once the brief is pasted outside its original surface (Slack, standup channel), making links ambiguous.
- **Where:** Standup snippet → Source-link enforcement (HARD RULE: GitHub PR/issue link label = `repo#number`).
