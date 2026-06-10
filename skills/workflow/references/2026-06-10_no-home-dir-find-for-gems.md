---
class: principle
date: 2026-06-10
skill: wk-workflow
---

- **Rule:** In a mise-managed repo, treat `GemNotFound`/missing-tool on
  `bundle exec`/`bin/rspec` as a setup gap — run `bin/setup`, never a
  `find ~` sweep; invoke tests via `mise exec -- <cmd>`.
- **Why:** `find ~` scans the whole home dir (slow, signals inattention);
  the real fix is the skipped mise-scoped setup step.
- **Where:** Phase 3 Test, "mise-managed test invocation".
