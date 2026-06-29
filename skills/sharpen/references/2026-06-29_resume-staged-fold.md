---
class: principle
---

**Rule:** In batch mode, a fully-distilled fold that a prior session staged but
left uncommitted (blocked on a signer unlock) is a resumable terminal state, not
"nothing to do." Before concluding "sources drained," check `git diff --cached
--name-only` for a staged fold (`SKILL.md`/`README`/`references`) whose learnings
are already renamed `.learned.md`. If present, resume: re-run the terminal gate
(install + prohibited scan), then retry the commit. Never re-distill folded work.

**Why:** An agent that sees every learning already `.learned.md` can mistake the
state for "done" and skip the pending commit, or re-distill work already folded.
The signer-failure rule (Step 8) says to stop and ask on the failing run, but did
not state the next run must resume the staged fold.

**Where:** Step 8 signing-failure bullet, and the Source 2 batch terminal check.

**Companion guard (already-covered, not escalated):** an all-undistilled memory
`comm` diff is almost always a path-form mismatch (full-path marker vs basename
listing), not a real backlog — re-normalize both sides to one path form before
processing. Source 3's normalize bullet fired correctly this run (0 real
backlog), which is positive-steering evidence — no escalation.
