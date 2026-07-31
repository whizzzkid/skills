---
skill: wk-pr-merge
date: 2026-07-30
type: gap
severity: high
verified-against-source: yes
---

Reconcile local and submitted stack membership before gating or merging any subset.

**What happened:** The local stack view listed three pull requests, while the stack submit command
reported an additional remote-only child. A merge based only on local metadata would have omitted
an active descendant.

**Root cause:** The merge workflow treats local stack metadata as the complete membership source
and does not require parity with the submitted GitHub stack.

**Suggested fix:** Before stack gates, compare local membership with the submitted stack. If the
stack command reports remote-only pull requests, hard-stop, import the full stack with the official
checkout flow, and rerun every gate across the reconciled member list. Never merge a locally
complete-looking subset while GitHub reports additional descendants.
