---
skill: wk-pr-resolve
date: 2026-08-06
type: correction
severity: high
verified-against-source: yes
---

Accepted PR resolutions must continue through verified remote and review state.

**What happened:** The workflow stopped repeatedly after partial local progress even though push and full resolution were explicitly authorized.

**Root cause:** Local implementation and environment friction were treated as terminal states instead of tracking the skill's remote completion criteria.

**Suggested fix:** Keep an explicit exit checklist and do not finish until commits are pushed, addressed threads are replied to and resolved, the PR is refetched, and required CI state is reported.
