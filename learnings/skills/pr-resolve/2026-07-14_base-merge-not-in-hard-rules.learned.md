---
skill: wk-pr-resolve
date: 2026-07-14
type: correction
severity: high
---

The mandatory base-branch integration obligation lives only in Step 2 prose, not in the numbered Hard Rules, so it was skipped and then hard to cite when the user challenged it.

**What happened:** On a PR that was 18 commits behind base and showing `mergeable: CONFLICTING`, the agent read the ahead/behind count, reported it, and proceeded straight to fetching comments — skipping the base-branch merge. The user caught it ("the first step of the skill is to resolve conflicts, why didn't you do that?"). Later, when the agent cited "the hard rule" for a push confirmation, the user asked "where is this hard rule?" — because the obligations the agent kept invoking were scattered in step prose and a partly-numbered list, not consistently traceable to a labeled rule.

**Root cause:** The strongest, most-violable obligation in the skill — "`$BEHIND > 0` obligates the merge before reading one comment; reporting the count and continuing is a violation" — is buried in a Step 2 bullet. The numbered **Hard Rules** block at the top (which the agent treats as the citeable, non-negotiable list) does not include it. Prose obligations lose to context pressure exactly the way the skill's own 2.0 sweep warns; an obligation that isn't in the enforced list gets treated as advisory.

**Suggested fix:** Promote the base-integration obligation to a numbered Hard Rule (e.g. "Never triage a comment while `$BEHIND > 0` or the tree has conflict markers — integrate base first; reporting the count and continuing is a violation") so it is citeable by number and carries Hard-Rule weight. Cross-reference it from Step 2. Every obligation the skill expects the agent to cite under pressure belongs in the numbered list, not in step prose.
