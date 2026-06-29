---
class: principle
---

**Rule:** In the Step 8 terminal gate, treat a commit signing failure as a stop-and-ask, not a retry. Do not re-run install/scan or re-stage; surface one explicit request for an interactive signer unlock. A loaded agent key (`ssh-add -l` succeeds) does not prove signing capability — only a completed signed commit does.

**Why:** A signer backed by an interactive credential agent can list keys yet fail to sign when locked, emitting "communication with agent failed". Conflating reachability (listing) with capability (signing) drove repeated re-stage cycles across sessions instead of a single unlock ask — wasted gate loops.

**Where:** Step 8, Commit sub-bullets.
