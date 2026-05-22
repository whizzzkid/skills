---
skill: wk-pr
date: 2026-05-22
type: correction
severity: high
---

Early return after `gh pr create` recurred despite an existing `.learned.md` entry for the same gap.

**What happened:** Agent posted a cross-repo discussion comment and then stopped, returning the PR URL to the user. CI polling, `wk-self-review`, adversarial gate, and `gh pr ready` were skipped. User had to prompt "is this ready for review?" to re-enter the flow.

**Root cause:** The cross-repo comment (posting on the referenced PR) was treated as a session-terminal action — the agent conflated "posted on the discussion" with "task complete." The wk-pr hard rule against early return did not fire because the mental model was "the user asked me to post on the discussion, so I'm done."

**Suggested fix:** Add an explicit note to wk-pr Step 3's hard rule: posting a cross-repo comment or reply does **not** constitute task completion. The post-creation workflow (Steps 3–5) runs regardless of any ancillary side actions taken after `gh pr create`. Consider adding to the quick-reference table: `"posted external comment"` → continue to Step 3, do not stop.

**Recurrence note:** A `.learned.md` for the same root cause already existed from a prior session. The fix has not been absorbed into the skill. wk-sharpen needs to harden the rule.
