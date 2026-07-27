---
class: principle
skill: wk-sharpen
date: 2026-07-25
severity: medium
---

**Rule** — Justify "run the owning hook, never hand-roll its matcher" with the mechanism
that always applies: **same flags ≠ same engine**. The agent's `grep` may be a shell
function or alias routing to another implementation, and the pattern file is the owning
script's private config — usually gitignored and machine-local, so its comment style and
matcher-specific constructs vary per checkout. A hand-rolled `grep -iEf` can return
**rc=1 with no stderr** on a term the hook flags. The governing direction is the
false-*clean*, not noise.

**Why** — The rule previously rested on "`#` comment lines match every markdown heading."
That is falsifiable in one command and false for the live denylist, which invites an agent
to check the comment style, find no noise risk, and conclude a hand-rolled scan is safe.
A rule whose cited mechanism the source disproves is weaker than one with no mechanism at
all.

**Verified against source** — Driving the real files, not reasoning about them:

- Comment lines vs headings: full-sentence comments match only their own literal text; a
  heading fed through the denylist did **not** fire (rc=1) while a real listed term did
  (rc=0). The noise mode requires bare `#` comment lines to be present.
- Comment self-match is conditional: a plain-prose comment line self-matches, but one
  containing regex metacharacters does not — `(`…`)` parse as a group, not literals. So
  the companion "a comment line always matches its own text" was also over-general.
- The owning hook strips comments itself (`grep -vE '^[[:space:]]*(#|$)'`) and scopes to
  the staged added diff plus the commit message — neither of which a worktree grep
  reproduces.
- **Engine divergence, reproduced:** identical flags against one pattern file and one
  subject containing a listed term — bare `grep` returned 0 matches / rc=1 with empty
  stderr; `command grep` returned 1 match / rc=0. A shell function was shadowing the
  binary and routing to a different engine.

**Consequence for this skill's own scans** — Every hand-rolled denylist or path scan must
invoke `command grep`. A canary that fires under bare `grep` does not clear a scan run in
another form; prove the engine on the invocation form the scan actually uses.

**Rejected suggestion (do not re-propose)** — The learning proposed restating the
justification as a conditional ("the matcher *may* mis-handle the pattern file, and you
cannot tell without checking"). Adopted only in part: the conditional framing is correct
for comment style, but leading with it still leaves the reader auditing the pattern file.
The reproduction surfaced a mechanism that needs no per-checkout condition (engine
shadowing), so that leads instead — per the Step 1 rule to prefer the formulation the
source can be driven to demonstrate.

**Where** — Step 5 mechanical overfit scan (the `**CRITICAL**` hook-vs-hand-roll bullet
and the residual staged-path hand-roll bullet); corrections also landed in the two
reference files that carried the disproven mechanism. No escalation: the rule is already
`**CRITICAL**` and the learning affirms its conclusion is correct — only the stated reason
was defective.
