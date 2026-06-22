---
skill: wk-adversarial-review
date: 2026-06-22
type: gap
severity: high
---

Porting a CI template from a feature branch silently drops env vars that main added after the branch diverged.

**What happened:** A CI step template was ported from a feature branch that predated several env var additions in main. The ported template was missing `REVIEW_HEAD_SHA`, `AUTO_APPROVE_ENABLED`, `AUTO_APPROVE_ALLOWLIST_REPOS`, `AUTO_APPROVE_LOC_MAX_THRESHOLD`, and `BUILDKITE_COMMIT` from the docker_compose env forwarding list. The downstream script and Ruby binary still read all of them — silently failing in production (beta polling fail-exit, auto-approve disabled, script hard-fail on missing COMMIT).

**Root cause:** Sweep 2.20 audits net-new env reads vs forwarding list, but when a template file is being replaced wholesale from a branch, it can remove existing forwarding that was never in the diff delta. The sweep misses deletions that weren't introduced by the current session's commits.

**Suggested fix:** When sweep 2.20 fires on a changed `env:` list (not just additions), diff the entire new list against the base-branch version of the same file. Any var present in base but absent in the new file is a candidate regression — require explicit justification or re-add it. Add this as an explicit substep in the sweep: "For env list changes: compare full list against `origin/$BASE` version of the same file; flag any removals."
