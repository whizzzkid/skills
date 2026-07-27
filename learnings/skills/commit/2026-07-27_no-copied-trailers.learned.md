---
skill: wk-commit
date: 2026-07-27
type: correction
severity: high
verified-against-source: n/a
---

Trailers were copied from neighbouring commits instead of being decided from the skill's rules, adding an unwanted `Co-Authored-By:` to every commit on the branch.

**What happened:** While committing a long branch, the agent matched the trailer block of
pre-existing commits on that branch and stamped a human `Co-Authored-By:` line onto each new
commit. `{user}` challenged it and asked for the whole branch rewritten. The rewrite changed
every commit SHA, which invalidated the per-item landing SHAs already recorded in a plan doc,
a PR body, and a tracking issue — all of which had to be remapped old→new by hand.

**Root cause:** The skill mandates the assisted-by trailer but says nothing about trailers it
does **not** want, so "what do the sibling commits look like?" filled the gap. Pattern-matching
neighbours is not deciding.

**Suggested fix:** State the trailer set as closed: the assisted-by trailer is the only trailer
the skill adds, and a human co-author trailer is added **only** on explicit user instruction for
that commit — never inferred from sibling commits, branch history, or an available employee-email
env var. Add a note that any trailer edit on already-pushed commits is a history rewrite whose
real cost is the recorded-SHA fan-out (plan docs, PR body, tracking issues), so the SHA remap and
re-verification sweep is part of the same task, not a follow-up.
