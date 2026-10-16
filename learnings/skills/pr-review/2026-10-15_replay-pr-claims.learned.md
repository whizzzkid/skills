---
skill: wk-pr-review
date: 2026-10-15
type: pattern
severity: medium
verified-against-source: n/a
---

When a PR description makes empirical claims (mutation results, test counts, gating behavior), replay each one in a
scratch worktree before trusting it.

**What happened:** The user asked to validate a PR's claims. Replaying them in a detached scratch worktree confirmed
the mutation claims and the author's own "known gap". It also found that a sibling PR the description treated as
pending had already merged, so its predicted follow-up step was now required. One full-suite run printed a bare FAIL
that disappeared on rerun.

**Root cause:** The skill never says to treat a PR description's claims as unverified, as it already does for spec
docs. It also never says to check whether "lands first" PRs have since merged.

**Suggested fix:** In Phase 1, list every empirical claim in the description and replay each one in a detached
worktree with a scripted mutation runner. Check the merge state of every related PR the description mentions. Capture
full test output to a log file, never just `tail -1`, and rerun before treating a bare FAIL as real.
