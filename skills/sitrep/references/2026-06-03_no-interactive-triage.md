---
class: principle
---

- **Rule:** Never run interactive triage in wk-sitrep; write every surfaced item unconditionally as a `[ ]` checkbox. Both sub-commands are compile-only.
- **Why:** In the SilverBullet model the user triages by editing the live markdown in the browser — a per-item keep/skip prompt (inherited from the HTML-output goodevening) is redundant and gets interrupted.
- **Where:** "HARD RULE — no interactive triage"; start Stage 3 and end Stage 3 (compile-only); `AskUserQuestion` dropped from allowed-tools.
