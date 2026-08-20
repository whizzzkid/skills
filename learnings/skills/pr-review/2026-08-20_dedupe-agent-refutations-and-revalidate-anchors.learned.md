---
skill: wk-pr-review
date: 2026-08-20
type: pattern
severity: medium
verified-against-source: n/a
---

Three reinforcing lessons from a delegated PR review with a background adversarial subagent.

**What happened:**

1. **Dedupe against the agent's refutations, not just its new findings.** Before
   composing comments I had a self-assembled finding ("a disjoint-cap prewarm gate
   is read by nobody — wasted subprocess"). The background adversarial subagent
   independently traced that the empty-key gate *is* routed to the capped checks
   (they key the same empty toolset), so it is billed *and* consumed. The agent's
   result refuted my own candidate. I dropped it. Reconciliation must run the
   agent's verdicts against my own list in both directions, not only fold in its
   net-new findings.

2. **PR HEAD advanced mid-review; the Phase-5 `headRefOid` recheck caught it.** A
   docs-only commit landed after Phase 1, shifting anchors in one source file by
   +1. The stale working tree still showed the old line numbers via `grep -n`. I
   revalidated every anchor against the **new-HEAD blob** (`git show <sha>:file |
   grep -n '<pattern>'`) rather than the working tree, rebuilt the commentable set
   from a fresh `gh pr diff`, and set the review payload `commit_id` to the new
   HEAD. Never trust working-tree line numbers when local HEAD lags PR HEAD.

3. **The strongest finding came from a mutation probe, not static reasoning.** A
   test-infra concern (a derived coverage guard that would falsely fail once a
   default set is narrowed — the exact follow-up the change enables) was only
   confirmable by copying the package to a temp tree, editing the one default
   constant, and running the test. Logic-bearing test-infra findings should be
   mutation-verified before elevating to concern.

**Root cause:** n/a — process patterns observed during a run, not a defect in a
deterministic artifact.

**Suggested fix:** In wk-pr-review Phase 3/4, state explicitly that delegated-agent
verdicts must be reconciled bidirectionally (its refutations can kill a
self-assembled finding). In Phase 5, add "resolve anchor line numbers from the
PR-HEAD blob (`git show <PR_HEAD>:file`), never the working tree, whenever local
HEAD != PR HEAD." Reinforce that logic-bearing test-infra findings need a mutation
probe before reaching `concern`.
