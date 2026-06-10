---
class: principle
date: 2026-06-10
severity: medium
---

- **Rule:** In batch-mode Source 3, materialize every external memory file as
  a learning file via `Skill(wk-learn, args="<skill>")` first, then distill
  that learning through the Source 2 path — never distill a memory straight
  into a SKILL.md.
- **Why:** Memory files live outside the repo and are not version-controlled;
  distilling one directly leaves no reviewable provenance beyond a one-line log
  entry, and the memory→skill path skips the learning artifact every other
  source produces.
- **Where:** Batch Mode → Source 3 (new HARD RULE + steps 4–6); Quick Reference
  batch-mode flow; `allowed-tools` gained `Skill` + `Bash`.
