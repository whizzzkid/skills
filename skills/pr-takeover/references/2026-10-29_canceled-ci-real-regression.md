---
class: principle
source: learnings/skills/pr-takeover/2026-10-29_canceled-ci-real-regression.learned.md
date: 2026-10-29
severity: high
---

# A canceled inherited check is a real signal until its log says otherwise

**Rule** — During takeover orientation, read the log of every non-green inherited job, canceled included, before
classifying it as infra. For a dependency-bump PR, audit every major-version change in the lockfile (direct and
transitive), not just the manifest. A linter bump that enables new rules → autocorrect, then review each unsafe
correction and every touched fixture or corpus file individually.

**Why** — A fail-closed gate that cancels its own build on failure renders as a canceled check, which reads as a flake
on the checks summary. A transitive major bump in a serialization library changed encoding behavior and tripped that
gate on every diff carrying non-ASCII text; only the canceled job's log surfaced it. The Buildkite canonical status
query also filtered to `failed`/`broken`, hiding canceled jobs entirely.

**Where** — `wk-pr-takeover` Step 4 (inherited-CI HARD RULE + dependency-bump bullet); `wk-buildkite` canonical status
query, "Investigating failures" step 1 and step 3 sub-bullet, and `references/build-job-states.md` `canceled` row.
The major-version audit itself stays owned by `wk-renovate` Step 4.
