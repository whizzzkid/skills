---
class: principle
date: 2026-11-27
source: learnings/skills/adversarial-review/2026-11-27_fail-safe-paths-missed.learned.md
---

# Probe a fail-safe policy past its entry point

- **Rule:** For any fail-safe or default-on-error design, check each policy on its raise path, on a repeated call
  (failure cached as deliberately as success), at every later call site in the same unit of work (inherits the
  earlier decision, not a fresh default), and through any noise filter (errored items kept).
- **Why:** A review that checked each policy only at its entry point cleared a runtime-flag client; a bot then found a
  success-only memoization that re-ran and re-reported every failure, a trace filter that dropped errored background
  polls, and a mid-job "unreadable reads as off" check that dropped work the start check had admitted.
- **Where:** `SKILL.md` Step 3 fail-safe bullet; `references/subagent-stances.md` Fail-safe-policy-aware stance. The
  raise-path axis defers to `wk-workstyle-error-handling`'s fail-open call-site rescue rule (author side) rather than
  duplicating it; sweep 2.50 keeps the narrower log-filter token-mismatch case.
- **Classification:** `partial` — sweep 2.50 and the error-handling rule each covered one axis; the repeated-call and
  later-call-site axes had no rule. No escalation: no installed rule was re-violated.
