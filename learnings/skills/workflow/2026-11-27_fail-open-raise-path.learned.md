---
skill: wk-workflow
date: 2026-11-27
type: correction
severity: medium
verified-against-source: n/a
---

A fail-open guarantee covered only returned failures, so a raised exception could still abort the caller.

**What happened:** A deploy-time step was made fail-open ("a failure never blocks the deploy"). The code checked only
the dependency's returned failure result, relying on the dependency's own internal rescue. An exception raised around
the call (the constructor, or an API renamed in a future version) would escape and abort the deploy. The specs stubbed
only returned failures, so they encoded the same assumption. That PR was also the one layer of a stacked set that
skipped the independent review; an automated review bot caught the gap after the PR was published.

**Root cause:** The "every path" termination-matrix rule was not applied: the raised-exception cell was never listed.
Trusting a dependency's internal error handling replaced a guard at the call site. Independent review was dispatched
for later stack layers but not the first.

**Suggested fix:** In wk-workflow Phase 3, state explicitly that a fail-open or "never blocks" promise needs (a) a
rescue at the call site, not only result-checking, and (b) a spec that stubs a raised exception, before the first
push. In the PR lifecycle, require the same independent review for every layer of a stack.
