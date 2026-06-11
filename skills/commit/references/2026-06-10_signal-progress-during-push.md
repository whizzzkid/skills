---
class: principle
date: 2026-06-10
skill: wk-commit
---

- **Rule:** Emit a one-line note before `git push` that pre-push hooks may
  take ~30s, then report the result when it returns.
- **Why:** Silence between stating intent and a long hook run reads as a
  frozen session and invites an "is this stuck?" interrupt.
- **Where:** Pushing section.
