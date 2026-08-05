---
skill: wk-pr-merge
date: 2026-08-05
type: gap
severity: high
verified-against-source: yes
---

Merge mutations must preserve the pull request's resolved repository owner.

**What happened:** The merge procedure prescribed constructing `--repo` from the configured
organization even when the explicitly targeted current repository had a different owner.

**Root cause:** The merge skill's repository target conflicts with the GitHub routing skill's
explicit-current-repository exception; following the merge template literally can address a different repository.

**Suggested fix:** Resolve `owner/name` from the pull request at Step 1 and reuse that exact value for
all reads and mutations; use the configured organization only for searches and emit a mismatch warning.
