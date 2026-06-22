---
class: principle
---

**Rule** — In Step 4, triage unresolved reviewer/bot threads by severity before blocking. Blocker/Major (correctness, security, data-loss) → invoke wk-pr-resolve, do not merge. Minor/Info (style, abstraction quality, non-critical coverage gap) → propose a Jira ticket per finding (or an omnibus ticket), file it, resolve each thread with a `Tracked in [<KEY>]` reply, then proceed. User declines filing → leave the thread open and proceed anyway; Minor threads must not block a merge-ready PR.

**Why** — Treating every unresolved bot thread as a hard stop stalls a merge-ready PR on cosmetic findings. Severity, not mere existence, decides whether a thread blocks. Resolving Minor threads via a tracking reply also satisfies the count-ALL branch-protection rule.

**Where** — wk-pr-merge Step 4, severity-triage substep. Complements the count-ALL platform-gate rule without overriding it.
