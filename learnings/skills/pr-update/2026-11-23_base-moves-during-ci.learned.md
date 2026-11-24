---
skill: wk-pr-update
date: 2026-11-23
type: gap
severity: low
verified-against-source: n/a
---

On a busy base branch, the merge state can turn DIRTY again while CI runs on the freshly integrated head.

**What happened:** After merging base and pushing, CI went green but the merge state was DIRTY because base had moved
again (a second conflict). One cycle later, the new base commit turned out to be the PR's own squash, because the user
had merged it mid-watch.

**Root cause:** The skill ends at push + sync. It does not re-check base drift after CI goes terminal, and it does not
check whether the PR itself has merged before integrating again.

**Suggested fix:** After the CI watch, re-query `mergeStateStatus` and the PR `state`. If MERGED, hand off to the
merge skill's post-merge steps. If DIRTY, loop Stage 1 once more. Run the CI watch in the background and report
between cycles.
