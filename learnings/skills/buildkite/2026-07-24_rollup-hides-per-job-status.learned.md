---
skill: wk-buildkite
date: 2026-07-24
type: pattern
severity: medium
verified-against-source: yes
---

A green `statusCheckRollup` names only top-level checks — use `bk build view <n> -p
<pipeline>` when a claim depends on which individual jobs actually ran and passed.

**What happened:** A spec failed locally and the PR body needed to state whether
the failure was environmental or real. The host's check rollup reported the
pipeline green but listed only the coarse pipeline-level check, which cannot
distinguish "that job passed" from "that job never ran." The Buildkite CLI's
per-job breakdown showed each job's individual exit status, which is what actually
supported the claim that the local failure did not reproduce in CI.

**Root cause:** The rollup is a summary surface — one entry per registered check,
not one per pipeline step. Treating it as per-job evidence lets a conditional,
soft-failed, or skipped step read as a pass, so a "CI proves this is
environmental" statement in a PR body can be unfounded while the rollup is green.

**Suggested fix:** When a PR-body or review claim rests on a specific job's
outcome, fetch the per-job view with `bk build view <build-number> -p <pipeline>`
and cite the build number plus that job's exit status. Reserve the rollup for the
coarse "is the pipeline green" gate only.
