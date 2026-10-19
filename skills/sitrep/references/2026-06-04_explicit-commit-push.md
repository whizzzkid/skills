---
class: principle
---

- **Rule:** Both sub-commands end with an unconditional commit stage (no
  prompt) — `start` commits live.md; `end` commits live.md + snapshot.md and
  stages the dismissed registry + brag log when present. The push that follows
  is gated by the push-destination rule (see
  `2026-10-19_push-target-is-personal-remote.md`).
- **Why:** The skill must be self-contained; relying on ambient project
  CLAUDE.md to commit output breaks in any repo lacking that rule.
- **Where:** start Stage 6 + end Stage 8.
