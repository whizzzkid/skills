---
skill: wk-self-review
date: 2026-07-28
type: correction
severity: medium
verified-against-source: yes
---

Preview URLs must be markdown links; backtick-wrapped URLs render as inert code spans.

**What happened:** The skill's own "Markdown preview link for large diffs" template shows
the URL wrapped in backticks. Two staged comments followed it verbatim, so both shipped a
non-clickable code span where a link was intended. The user caught it and the whole pending
review had to be preserved, deleted, and re-posted to correct the bodies — GitHub review
comments in a pending review are not editable through this flow.

**Root cause:** The template in the skill body itself models the wrong syntax. A code span
is the correct rendering for a *path*, and the guidance conflated "monospace the path" with
"emit the URL", so a URL inherited the backticks.

**Secondary finding — re-staging churn:** the pending review was orphaned and re-staged
three times in one round: twice because new commits moved HEAD (`commit_id` pins to a SHA)
and once for this content fix. Staging before HEAD is final guarantees the cycle.

**Suggested fix:**

- Change the template to `[`<path>`](<url>)` — code-span the label, never the URL.
- Add a pre-emit check: reject any comment body containing a backtick-adjacent `http`.
- Stage the pending review as the **last** action of a round, after the final commit is
  pushed and CI has been kicked off, so `commit_id` is not stale on arrival.
