---
class: principle
---

**Rule** — Make a conflict-marker check (`git diff --check`) the first action of branch sync, before any fetch or comment read. Any markers present → resolve to a clean tree (or delegate to `wk-pr-update`) before triaging a single comment.

**Why** — Triaging on a conflicted tree embeds conflict markers into commits or generates suggestions against a stale diff. Conflict resolution belongs at sync time, not as a deferred "before you start" reminder the user has to supply.

**Where** — Step 2 sync pre-flight. A user reminder to "resolve conflicts first" is the signal this gate was skipped on a prior run.

---

**Rule (dropped-guard audit)** — After each conflict resolution, audit for dropped base-side safety guards. During a rebase the base side (HEAD) is the canonical `origin/$BASE_BRANCH`, so a guard there was intentional. Diff both sides for signal/cleanup primitives (signal stops, `defer`, channel closes); any present on the base side but absent from the result is a dropped guard — restore it unless the incoming commit removed it with a rationale.

**Why** — Green compile/tests do not prove a dropped guard unneeded; the guard covers a path the test suite may not exercise. Block until each base-side absence is confirmed intentional.

**Where** — Step 2, after resolving a base-advance/rebase conflict. Mirrors adversarial-review's merge/rebase safety-primitive sweep.
