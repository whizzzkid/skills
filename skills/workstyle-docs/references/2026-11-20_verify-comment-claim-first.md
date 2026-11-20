---
class: principle
skill: wk-workstyle-docs
date: 2026-11-20
---

# Verify a comment's factual claim before writing it

- **Rule:** Before writing a comment that asserts what the tests, a dependency, or an external tool does, grep or read
  the source that proves it. Unproven → cite what you did verify, or drop the claim.
- **Why:** A lint-ignore reason comment claimed the test suite stubs a browser global. A later grep found no such
  stub, and the comment was rewritten to cite the library that really sets it. The check ran after the claim instead
  of before it.
- **Where:** `SKILL.md` → Rules, after the no-stale-comments rule. `wk-workflow` Autonomy Rules carry the
  external-tool-behavior case; `wk-self-review` Step 2.7 re-checks comments at review time.
