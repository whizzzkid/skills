---
class: principle
---

# Skip settled PRs; surface every live draft

**Rule** — re-check each auto-review candidate's live `state` and `reviewDecision` right before dispatch and again
before publishing; merged, closed or approved → no review, no listed draft. Run the review in its lightest mode, have
the orchestrator open each posted draft, and list only drafts on still-open PRs.

**Why** — candidates came from the gather snapshot, so reviews were spent on PRs that merged or were approved before
the drafts landed. Defaulting to medium depth wasted more, nothing opened finished drafts for the user, and drafts on
merged or closed PRs kept accruing on the page. A gather-time snapshot goes stale during a long review run, so state
must be re-read at both ends.

**Where** — `SKILL.md` → Stage 2 GitHub agent (PENDING sweep with PR state) and Stage 7; `references/auto-review.md`
→ Rule, Per-PR subagent, Open the draft; `references/rendering-contract.md` → Terminal state rule.
