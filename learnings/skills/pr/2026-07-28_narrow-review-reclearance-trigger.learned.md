---
skill: wk-pr
date: 2026-07-28
type: correction
severity: medium
verified-against-source: yes
---

Adversarial-review re-clearance should trigger on new unreviewed work, not on any HEAD movement.

**What happened:** Hard Rule 2 states the adversarial review gates the merge and requires
re-clearance whenever pushed history changes, with "no exemption". On PR #NNN the review had
already run and its findings had been applied; the only subsequent commits were the fixes
those findings asked for. Under the rule as written, each fix push re-armed the gate — the
merge could not proceed without another full review of a change the review had just produced.
The user waived the gate and asked that the rule be narrowed to stop multiplying reviews.

**Root cause:** The rule uses "pushed history changed" as a proxy for "there is unreviewed
logic". The proxy over-fires because the review's own fix loop necessarily changes pushed
history. Re-clearance cost is therefore proportional to the number of fix rounds rather than
to the amount of unreviewed code.

**Suggested fix:** Reword Hard Rule 2 so re-clearance is required only when unreviewed
*logic* exists after the clearance:

- Review runs once, when the work is considered complete at our end and ready for agent or
  human review.
- Commits that only apply findings already surfaced by that review (or by an automated
  reviewer) keep the clearance valid — no new run.
- A force-push/rebase that merely rewrites already-reviewed commits keeps the clearance;
  one that introduces new content does not.
- Genuinely new functionality or logic added after clearance → scope a re-review to
  `git diff <cleared-sha>..HEAD` only, never a full re-run.

Minimizing total review invocations is an explicit goal, not a cost optimization to trade
away. Parallel learning filed under `pr-merge/` for the merge-side gate.
