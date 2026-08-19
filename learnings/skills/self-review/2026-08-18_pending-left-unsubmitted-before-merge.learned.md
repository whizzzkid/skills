---
skill: wk-self-review
date: 2026-08-18
type: gap
severity: medium
verified-against-source: n/a
---

Pending self-review comments were left unsubmitted at merge time; the user had to ask twice to post them.

**What happened:** Across several PRs the agent staged self-review comments as pending (draft) reviews per the skill default, then proceeded toward merge without submitting them. The user twice had to prompt "did you also post the comments that were pending?" / "can you also post the pending review comments prior to merging" before the drafts were submitted.

**Root cause:** The skill mandates pending-only and treats GitHub's Submit button as the human checkpoint, so at merge the drafts sit unsubmitted by design. When the user has expressed (or the workflow implies) that self-review notes should actually be visible on the PR before it lands, the pending-only default silently strands them as invisible drafts.

**Suggested fix:** When a session directive says to post self-review as submitted (or the PR is about to merge and the author wants the design notes visible), submit the review with `event: "COMMENT"` rather than leaving it pending — and at the merge gate, detect any still-pending self-authored review on the PR and surface it ("N self-review comments are still in draft — submit before merge?") instead of merging over invisible drafts.
