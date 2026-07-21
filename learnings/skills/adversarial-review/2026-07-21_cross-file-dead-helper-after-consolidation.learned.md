---
skill: wk-adversarial-review
date: 2026-07-21
type: gap
severity: medium
---

Sweep 2.17's dead-code inverse case is easy to miss when the deleted caller and the now-dead helper live in different files.

**What happened:** A consolidation refactor collapsed a controller's single-metric helper trio down to calls into a pre-existing generalized batch-read helper. That deletion removed the only caller of a sibling method in a separate lib file (`{project}`'s hot-layer counters module), leaving it reachable only from its own unit spec. A same-file "grep for dangling references to the deleted names" check passed clean because the dangling reference wasn't the issue — the *newly dead* method lived entirely outside the diff's file.

**Root cause:** Sweep 2.17 as usually run only checks "for each call kept/added, grep for the definition" (forward direction) inside the touched file. The inverse direction — "for each helper whose caller was just deleted, grep the whole repo for remaining callers" — requires walking one hop further: from the deleted call site, into the callee's own definition file, then re-checking *that* method's caller count repo-wide. Skipping that hop lets a cross-file dead-code case slip through a review that felt thorough.

**Suggested fix:** When sweep 2.17 fires on a diff that deletes a private/internal helper method (not just a call site), always resolve the helper's *own* callee(s) and grep the whole repo (not just the diff's files) for their remaining call count before declaring the sweep clean. A helper that drops to zero callers anywhere in the repo is the same class of finding as a dangling reference to the deleted code, just discovered one hop away.
