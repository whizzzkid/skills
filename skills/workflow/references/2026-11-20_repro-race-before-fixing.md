---
class: principle
skill: wk-workflow
date: 2026-11-20
---

# A race/ordering bug goes red against unfixed code before the first fix edit

- **Rule:** For a race, ordering, or timing bug, run a reproduction against the unfixed code before any fix edit. It
  must go red. Green means the premise is refuted: read the framework path that should produce the bug, then ask the
  user before editing.
- **Why:** The ticket's mechanism was never confirmed. The framework already cancelled the earlier in-flight request
  when a newer one started, so the stale response could never render. The fix shipped first, and its negative control
  (guard removed) stayed green at verification. Ordering "implement → verify" for an unconfirmed premise yields a fix
  for a bug that does not exist.
- **Where:** `SKILL.md` → Phase 2, HARD RULE after the external-failure reproduction pointer. The planning side
  (baseline measurement of claimed savings) lives in `wk-plan` Step 0.
- **Secondary (one-off, reference only):** a manual-test env override injected into a shared container leaks into
  later spec runs → `references/environment-guardrails.md` → *Shared test containers*.
- **Same-commit de-bloat:** relocated the open-a-local-file standard to `references/code-standards-extended.md`
  (structural move; the Phase 2 `Bash:` line already points there).
