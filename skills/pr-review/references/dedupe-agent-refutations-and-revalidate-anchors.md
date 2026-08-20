---
class: principle
---

**Rule** — Two reinforcing patterns for delegated adversarial review:

1. **Bidirectional reconciliation.** When the adversarial subagent returns
   findings, reconcile in both directions: fold net-new agent findings into
   Phase 4 AND drop or revise self-assembled candidates the agent refutes.
   Agent verdicts override pre-assembled static reasoning.

2. **Anchor resolution from PR-HEAD blob.** When local HEAD lags PR HEAD
   (detected by Phase 5 `headRefOid` recheck), resolve line numbers from the
   PR-HEAD blob (`git show <PR_HEAD>:file | grep -n`), never the working tree.
   Working-tree line numbers are stale when a commit landed after Phase 1.

A third pattern — mutation probing for logic-bearing test-infra findings —
was already covered by the Phase 3 HARD RULE "logic-bearing findings need an
empirical pass."

**Why** — Unidirectional reconciliation lets a refuted finding survive to
Phase 4. Stale working-tree anchors produce off-by-N line targets that break
GitHub's `line` field or misanchor the comment.

**Where** — Phase 3 "On the returned findings" bullet list; Phase 5
"Recheck the reviewed head."
