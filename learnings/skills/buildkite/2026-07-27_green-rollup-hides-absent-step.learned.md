---
skill: wk-buildkite
date: 2026-07-27
type: gap
severity: high
verified-against-source: yes
---

A green build proves nothing about a check that has no step — confirm the step exists in the job list before reporting it passed.

**What happened:** Asked to confirm that a review bot had vetted a dependency-manifest
change, the agent listed the build's jobs and found no such step. The bot's config file
was present in the repo and imported the relevant plugin, but nothing invoked it — no
pipeline step, no CI workflow, and the repo's setup TODO still listed the bot as
unconfigured. Every job in the build was `passed`/exit 0, so both the host check rollup
and the build state read fully green. Reporting "the bot passed" would have been false.

**Root cause:** The existing per-job rule ([rollup-hides-per-job-status]) corrects for a
rollup collapsing many jobs into one entry, but it still assumes the job exists and
frames the task as reading its state. The absent-step case fails one level earlier: the
job list is complete and green precisely *because* the check was never wired in.
Absence of evidence renders identically to a pass.

**Suggested fix:** In "Checking Build Status", extend the per-job rule — before
reporting any named check's outcome, confirm a matching job appears in the build's job
list; an empty match is a **finding** ("that check does not run here"), never a pass.
When the match is empty, grep the repo for the tool's wiring (pipeline definition, CI
workflow dir, setup TODO) and report it as an unwired gate rather than a green result.
