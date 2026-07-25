---
skill: wk-buildkite
class: principle
---

**Rule** — A green host-side check rollup supports only the coarse
"is the pipeline green" claim. When a PR-body or review statement rests on a *specific*
job's outcome, fetch the per-job view and cite the build number plus that job's
`exit_status`.

**Why** — The rollup carries one entry per registered check, often a single entry for a
whole pipeline — not one per pipeline step. It therefore cannot distinguish "that job
passed" from "that job never ran," so a conditional, skipped, or soft-failed step reads
as a pass and a claim like "CI proves this failure is environmental" can be unfounded
while the rollup is green.

**Where** — wk-buildkite Checking Build Status; the rollup's granularity limit is
recorded alongside the other rollup semantics in wk-gh.
