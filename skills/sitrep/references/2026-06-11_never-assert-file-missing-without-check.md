---
class: principle
date: 2026-06-11
skill: wk-sitrep
severity: high
---

- **Rule:** Never assert "X does not exist / was not found" without a
  filesystem check (`ls`/`Read`/`find`) first. If unchecked, say "I have not
  read X" — never "X is missing."
- **Why:** The agent confused "I did not read the snapshot" with "the
  snapshot is absent" and falsely declared a present file missing.
- **Where:** start Stage 1 HARD RULE. General across skills; encoded here
  where the incident occurred.
