---
skill: wk-gh
date: 2026-08-18
type: correction
severity: medium
verified-against-source: yes
---

A "branch not mergeable" state was wrongly attributed to branches needing to be up-to-date, when the ruleset only required status checks to pass.

**What happened:** The agent claimed a PR could not merge because its branch was behind the base and needed updating. The user corrected it: the active ruleset requires status checks to pass, not branches to be up-to-date. The agent had asserted a merge gate that did not exist in the ruleset.

**Root cause:** The `mergeStateStatus`/BLOCKED signal was interpreted as "branch is stale" without reading the ruleset's actual `required_status_checks` and `strict_required_status_checks_policy` parameters. GitHub only enforces branch-freshness when the ruleset explicitly sets the strict (require-branches-up-to-date) flag; absent it, a passing-checks + resolved-threads PR merges regardless of base distance.

**Suggested fix:** Before asserting a PR is merge-blocked on branch-freshness, read the ruleset and confirm the strict/require-up-to-date flag is actually set. Never infer a "must update branch" gate from a BLOCKED merge state alone — enumerate the ruleset's required checks and cross-check each against the head SHA; branch-behind is a blocker only when the strict policy flag is present.
