---
skill: wk-gh
date: 2026-07-31
type: surprise
severity: medium
verified-against-source: yes
---

Stack metadata can lag the live pull-request head.

**What happened:** `gh stack view --json` reported an older top-member head while the local branch
and `gh pr view` agreed on a newer pushed head; the atomic merge used the live pull-request head.

**Root cause:** The stack view's recorded member head is stack-topology metadata and is not a
reliable substitute for the pull request's current remote head OID.

**Suggested fix:** Document the distinction and require live pull-request head OIDs for CI and
pre-merge gating while using stack view only for topology and membership parity.
