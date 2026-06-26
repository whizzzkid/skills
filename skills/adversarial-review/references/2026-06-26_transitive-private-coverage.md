---
class: principle
---

**Rule:** Do not flag a line-coverage gap on a private helper that is exercised
transitively through its public caller, nor on a sibling severity/branch already
covered by an equivalent case. Both look like gaps through a changed-line lens
but are covered through the public interface.

**Why:** A line-coverage lens (and bots that scope by changed lines) reports a
private method tested only via its caller, and two severities sharing one
branch, as untested. Standard practice tests private methods through the public
interface; coupling tests directly to private helpers couples them to
implementation detail. Accepting such a finding adds redundant tests that
ossify internals.

**Where:** wk-adversarial-review Step 3 "Coverage-aware" subagent stance
(extended with the transitive-coverage clause).
