---
class: principle
---

**Rule:** Before calling a behavior in extracted/moved code "newly introduced,"
grep the `-` side of the same diff (the origin file's removed lines) for the
identical construct. A verbatim match means the behavior is inherited by a
relocation, not introduced — downgrade the finding.

**Why:** A line-diff reviewer sees extracted code as `+` lines in a new file and
reads it as introduced, without checking that the same lines were `-` removed
from the origin in the same diff. Extract-to-shared-helper refactors are
especially prone to this false positive.

**Where:** ALREADY COVERED — wk-adversarial-review "Introduction-claim-aware"
stance ("before calling a behavior newly introduced, grep the `-` lines of the
same hunk"). This session's retro logged the rule firing correctly (positive
steering), so the repeat is confirmation, not a re-violation — cited, not
escalated.
