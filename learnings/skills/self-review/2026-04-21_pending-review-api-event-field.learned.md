---
skill: wk-self-review
date: 2026-04-21
type: correction
severity: medium
---

`wk-self-review` example in skill shows `"event": "PENDING"` but GitHub API rejects it with HTTP 422.

**What happened:** Followed the skill's example payload and sent `"event": "PENDING"` in the POST to `repos/{owner}/{repo}/pulls/{number}/reviews`. GitHub returned 422: `Variable $event of type PullRequestReviewEvent was provided invalid value`. Worked after dropping the `event` field entirely (and adding `commit_id`).

**Root cause:** The skill's "Step 4: Post Comments" example has a `"event": "PENDING"` line. `PullRequestReviewEvent` only accepts `APPROVE`, `REQUEST_CHANGES`, or `COMMENT` — pending is the **default state** when no event is submitted, not an event value. The skill documentation is wrong.

**Suggested fix:** In the `wk-self-review` SKILL.md "Step 4: Post Comments" code block, remove the `"event": "PENDING"` line from the JSON example and add a note: "Omit the `event` field to create a pending (draft) review. Include `commit_id` set to the PR's HEAD SHA to anchor the review." Also mention that valid `event` values are only `APPROVE`, `REQUEST_CHANGES`, `COMMENT` — used to *submit* a review, not create one in pending state.
