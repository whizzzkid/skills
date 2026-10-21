---
class: principle
source: learnings/skills/pr-takeover/2026-10-21_resign-before-work.learned.md
date: 2026-10-21
severity: high
---

## Re-sign inherited commits before starting takeover work

An inherited PR (opened by an automation author) carried an unsigned commit. The takeover stacked
signed commits on top; CI, review, and threads all went green, then the required-signatures rule
blocked the merge. Re-signing at that point meant a rebase and force-push under finished work,
invalidating every SHA already cited in the PR body and thread replies.

**Failure mode:** branch protection requiring signed commits is only enforced at merge time, so
nothing earlier in the takeover surfaces it. The cost of the fix grows with every SHA cited after
checkout.

**Guard:** right after checkout, query verification over the whole PR commit range (never the head
alone). Overwrite mode: re-sign with `rebase --force-rebase --gpg-sign` onto the base, confirm a raw
`gpgsig` header per commit, force-push with a pinned lease, re-query. Stack mode: never rewrite the
original branch; flag the unsigned SHAs in the handoff.

**Related:** range-scoped signature checks (`wk-gh` merge-blocker diagnosis), the rebase-onto-merge-base
no-op (`wk-pr-update`), and the `%G?`/`--show-signature` false alarm (`wk-commit` signing reference).

**Landed in:** `SKILL.md` Hard Rule 5 and Step 3 "Signature gate".
