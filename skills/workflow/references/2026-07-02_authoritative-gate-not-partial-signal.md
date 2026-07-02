---
class: principle
skill: wk-workflow
date: 2026-07-02
---

# A fast/narrow check is never the authoritative gate

**Rule:** Do not claim lint/format/test clean from a partial signal.
- A pre-commit hook is a fast subset — it may lint a narrower file set (e.g.
  only `*.sh`) than the full CI-mirroring check. Run the full gate before
  claiming clean.
- Never read `$?` from a piped command to gate a correctness claim. In a default
  shell, `$?` after `a | b` is `b`'s status, so `check | tail` reports `tail`'s
  success and hides the check's failure. Read `${PIPESTATUS[0]}`, or redirect the
  target's output to a file and check `$?`.

**Why:** Both failure modes let a real failure ship undetected — one because the
hook covers fewer files by design, the other because the pipe swallows the
target's exit status. A "clean" claim gated on either is a false positive.

**Where:** Phase 3 Test → Verification bullets.
