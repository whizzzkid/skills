---
class: principle
date: 2026-11-26
severity: low
---

# A verification request measures; it never regenerates evidence

**Rule** — When asked to confirm nothing broke after an integration, re-assert the measured properties of the last
capture run (sizes, computed styles, state transitions, console errors) on the integrated head, read-only.
Regenerate captures only when a measured value changed, and copy existing evidence aside before any run that
overwrites it.

**Why** — A conflict resolution that keeps the branch side verbatim (`git diff --quiet "$START_SHA" HEAD -- <file>`
rc 0) is not a visual fix, so the "re-shoot after a visual commit" rule does not apply. Starting an overwriting
capture anyway replaced verified evidence; the run was interrupted mid-write and the files had to be restored from
a backup. The measured check is the arbiter: base changes outside the conflicted files can still alter rendering,
and only a changed measurement justifies new captures.

**Rejected** — the report's "merged net diff equals pre-merge net diff" precondition. Reproduced in a scratch repo:
when the base edited the conflicted line and the resolution kept the branch line, `git patch-id` of the branch's
net diff differs before and after (the diff is now against the base's line), so the precondition misses the exact
case reported. Also rejected: a scoping qualifier on `wk-workflow`'s capture-freshness rule — it is already
conditioned on "rendered output changed", and that body sits at its size ceiling.

**Where** — `SKILL.md` → Stage 5 (Re-validate), bullet after test-command detection.
