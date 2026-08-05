---
skill: wk-pr-merge
date: 2026-08-04
type: gap
severity: medium
verified-against-source: yes
---

Choose the merge method from the active ruleset before issuing the merge command.

**What happened:** The merge skill required a squash attempt after the active ruleset had already reported that only
merge commits were allowed, producing a predictable policy failure before the permitted merge succeeded.

**Root cause:** The skill's unconditional squash-first rule conflicts with its rule that a method absent from
`allowed_merge_methods` is not a valid candidate.

**Suggested fix:** Make the ruleset authoritative: use squash first only when it is allowed; otherwise select the
first allowed method in the documented preference order without probing a known-forbidden method.
