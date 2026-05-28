---
class: one-off
date: 2026-05-28
source:
  - ~/.claude/memory/feedback_capture_stderr_before_or_true.md
severity: low
---

- **Scenario** — shell command uses `|| true` to suppress failure and the else branch takes a meaningful action (set a default, proceed, retry-cap dispatch).
- **Symptom** — once `|| true` swallows the exit code, stderr is gone; the else branch cannot distinguish a transient API error from an expected miss and may silently bypass safety checks.
- **Fix** — capture stderr to a temp file before the suppression so the else branch can inspect the failure reason:

  ```bash
  ERR_FILE=$(mktemp)
  OUTPUT=$(some_command 2>"$ERR_FILE") || true
  ERR=$(cat "$ERR_FILE"); rm -f "$ERR_FILE"
  # dispatch in else branch on $ERR contents
  ```

- **Why not promoted** — narrow bash recipe; the generic rule ("don't suppress signals that the next branch depends on") is already implied by guard-clause and error-handling guidance in SKILL.md, and the verbatim recipe would bloat the skill with one language's syntax.
