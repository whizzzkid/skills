---
class: principle
---

# Auto-merge turns an approval into the merge

**Rule**

- At the approve gate, read `autoMergeRequest` in the same live `gh pr view` query as the head and rollup recheck.
- Non-null and the review carries any `suggestion:`/`question:` comment or an author-actionable `Re:` answer →
  `gh pr merge <n> --disable-auto` as its own Bash call before submitting APPROVE; re-query once to confirm it is null.
- Add one body sentence saying auto-merge was disabled so the comments can land first (a fourth allowed body-sentence
  exception).
- Disable denied, errored, or still non-null → do not approve; hold as pending and report "approve requested; held as
  pending: auto-merge on and could not be disabled".
- No actionable comment → approve normally; merging is the intended outcome.
- Report the auto-merge state and the action taken in the terminal on every approve run.

**Why**

- The gate treated `suggestion:`/`question:` as non-blocking on the assumption that approval is advisory. With
  auto-merge enabled and approval the last missing requirement, the PR merged about two minutes after the APPROVE, so
  the author never saw the suggestions. Approval was the merge trigger, which is irreversible.
- The squash commit also used the body captured when auto-merge was enabled, so a stale description shipped.
- Not adopted: blocking approval outright when auto-merge is on. A clean review should still merge; only actionable
  comments need a pause.
- `gh pr merge --disable-auto` was not added to `allowed-tools`: it writes to someone else's PR, so a permission
  prompt or denial is acceptable, and the denial path holds the review as pending.

**Where**

`skills/pr-review/SKILL.md` → Approve Flag (auto-merge HARD RULE) and Phase 5 body-sentence exceptions;
`references/posting-pending-review.md` → "Submit as approval".
