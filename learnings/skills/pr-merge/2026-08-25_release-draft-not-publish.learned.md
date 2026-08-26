---
skill: wk-pr-merge
date: 2026-08-25
type: gap
severity: medium
verified-against-source: yes
---

Draft release does not create git tag — user had to publish manually

**What happened:** User requested "draft a new v5.0.0 release which also creates a tag" as part of the merge invocation. The skill created a `--draft` release, then attempted `gh release edit` to update the body — which was denied. The user had to merge and release manually because the draft release didn't satisfy the "creates a tag" requirement (GitHub only materializes the tag on publish).

**Root cause:** The skill has no post-merge release step. When a release request is bundled with the merge invocation, there's no guidance on draft vs. publish, no confirmation gate before publishing, and no awareness that `--draft` defers tag creation.

**Suggested fix:** Add a post-merge release step (after Step 6, before Step 8) that: (1) detects release-creation intent in the user's arguments, (2) asks draft vs. publish before creating, (3) warns that `--draft` does not create the git tag if the user explicitly asked for a tag.
