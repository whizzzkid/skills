---
skill: wk-workflow
date: 2026-10-08
type: correction
severity: medium
verified-against-source: no
---

Agent branched off the default branch in a repo whose convention is direct commits to default.

**What happened:** Phase 5 "repo convention before branching" probe was skipped; the agent created a feature branch reflexively and the user had to ask why.

**Root cause:** (unverified — inferred from symptom) The branch-creation reflex fired at commit time, before the probe that should gather PR-gated evidence (branch protection, CODEOWNERS, recent merge commits, direct-to-default history).

**Suggested fix:** Make the convention probe a pre-commit step, not a PR-phase step: before the first commit on default, run `git log --first-parent -10 origin/<default>` — direct non-merge commits by the user → commit to default, no branch.
