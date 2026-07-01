---
skill: wk-adversarial-review
date: 2026-07-01
type: pattern
severity: medium
---

An automated reviewer flagged a guard in an extracted script as "new
validation logic changing behavior" when it was relocated verbatim from the
original inline code.

**What happened:** A refactor moved a `: "${VAR:?msg}"` fail-fast guard and a
`sed | xargs` install line out of two duplicated build-stage RUN blocks into a
shared script. An automated review then raised two "major" findings — one
claiming the guard was newly introduced (original "silently proceeded"), one
treating the relocated parse-then-install line as newly risky. Both were
relocation of pre-existing behavior, not new logic. Grepping the `-` lines of
the pre-refactor source disproved the "new behavior" claim outright.

**Root cause:** A line-diff reviewer sees extracted code as `+` lines in the new
file and reads it as introduced, without checking that the same lines were `-`
removed from the origin in the same diff. Extract-to-shared-helper refactors are
especially prone to this false positive.

**Suggested fix:** Reinforce the introduction-claim-aware stance: before calling
any behavior in an extracted/moved helper "new," grep the `-` side of the same
diff (the origin file's removed lines) for the identical construct. A verbatim
match downgrades the finding to relocation-aware (inherited, not introduced).
Apply the cheap hardening when trivial, but reply to false "new behavior"
findings with the pre-refactor line as evidence rather than accepting them.
