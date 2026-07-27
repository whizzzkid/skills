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
  success and hides the check's failure. Run the check bare, or redirect the
  target's output to a file and check `$?`.

**Corrected 2026-07-27** — this rule previously offered `${PIPESTATUS[0]}` as the
first remedy. That is bash-only: under zsh the uppercase name is unset, so
`rc=${PIPESTATUS[0]}` expands empty and the customary `${rc:-0}` default supplies a
success code — the pipe-swallowed failure becomes an affirmative false pass, which
is worse than the `$?` bug it was meant to fix. The remedy is now bare-or-redirect
only, and the SKILL bullet names `${PIPESTATUS[0]}` solely to forbid reaching for
it. Flagged as a deferred over-general instance in `wk-workstyle-shell`'s
`2026-07-25_pipestatus-empty-under-zsh.md`; corrected in the same pass that folded
the pipeline-verdict re-violation.

**Why:** Both failure modes let a real failure ship undetected — one because the
hook covers fewer files by design, the other because the pipe swallows the
target's exit status. A "clean" claim gated on either is a false positive.

**Where:** Phase 3 Test → Verification bullets.
