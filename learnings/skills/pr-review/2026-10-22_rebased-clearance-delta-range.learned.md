---
skill: wk-pr-review
date: 2026-10-22
type: pattern
severity: low
verified-against-source: n/a
---

On a rebased branch, scope the delta review from the rebased equivalent of the last cleared commit, not the cleared SHA.

**What happened:** The prior clearance SHA predated a rebase, so `<cleared>..HEAD` spanned dozens of base-branch merges. Scoping from the rebased copy of the last cleared PR commit gave a small, correct delta. Separately, the user's own pending drafts quoted an adversarial test payload containing a team @-mention; posting it verbatim would have pinged the whole team.

**Root cause:** The skill does not say how to find the delta base when lineage breaks by rebase, or to sanitize hostile repro strings in comment bodies.

**Suggested fix:** When the cleared SHA is not an ancestor-by-content of HEAD, map it to its rebased equivalent via `git log --no-merges` subject matching. Before posting, strip @-mentions and live links from quoted adversarial payloads.
