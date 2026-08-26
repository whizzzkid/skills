---
skill: wk-pr-resolve
date: 2026-08-25
type: gap
severity: medium
verified-against-source: yes
---

An actionable Minor-severity bot finding was deferred to a "file a follow-up ticket" offer instead of being fixed during an explicit pr-resolve run.

**What happened:** The user said "run wk-pr-resolve" to address PR review comments. A bot finding was Minor severity (test-scope redundancy: two request-level specs duplicated coverage already available at the unit level, with a concrete suggested fix). It was left as an unresolved thread and treated under the merge skill's "Minor/Info never gates merge, offer a follow-up ticket post-merge" rule. The user then had to explicitly ask why the finding wasn't fixed, and a follow-up PR had to be created after the fact.

**Root cause:** The Minor/Info deferral rule exists in `wk-pr-merge` Step 4 to keep low-severity, ambiguous, or judgment-heavy findings from blocking a merge. It was applied here even though the finding had a concrete, low-effort, obvious fix (add two unit tests) and the user's explicit instruction was to resolve review comments now, not later. Severity alone was used as the gate, without checking whether the fix was trivial to apply in-session.

**Suggested fix:** In `wk-pr-resolve`, do not let "Minor severity" alone justify deferring a finding when the finding names a concrete, small fix (e.g., "add a unit test asserting X") and the user explicitly invoked the resolve workflow. Reserve the merge-time "Minor/Info never gates, offer a ticket" path for findings that are genuinely low-value, ambiguous, or high-effort — not for cheap fixes that just happen to carry a Minor label. When in doubt, apply the obvious-fix classification (per Step 4's `obvious-fix` tag) rather than the severity label to decide whether to fix now.
