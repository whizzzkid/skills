---
skill: wk-adversarial-review
date: 2026-07-27
type: gap
severity: high
verified-against-source: yes
---

A conditional skip-guard whose predicate never matches silently deletes coverage while the suite reports green.

**What happened:** A test-support file skipped every example carrying a given tag
unless the live connection's adapter name matched a case-insensitive pattern. The app's
driver reports a different adapter name than the one the pattern expected, so the
predicate never matched — every tagged example was skipped on **every** run, including
the intended one. The tag had been added specifically to protect those examples, and it
was disabling them instead. Nothing failed; the suite counted them as pending, and the
count was never read.

**Root cause:** The sweep catalog covers tests that assert nothing and tests that are
tautological, but not tests that never execute. A guard is treated as ordinary
conditional logic (2.3 traces reachability of *guards added by the diff*), so a
pre-existing skip predicate carried unchanged by the diff is never evaluated against
the runtime value it compares.

**Suggested fix:** Add a sweep — diff touches, or the reviewed code relies on, a
conditional skip/exclude guard (`skip … unless <predicate>`, tag filters,
`pytest.mark.skipif`, build-matrix excludes) → resolve the predicate's operand against
the value the runtime actually supplies, not the value its name implies. Confirm the
guard fires in at least one configuration and does *not* fire in at least one other;
a guard that is constant in either direction is dead. Severity blocker when the dead
direction is "always skip".
