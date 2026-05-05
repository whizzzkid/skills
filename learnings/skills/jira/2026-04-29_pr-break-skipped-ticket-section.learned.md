---
skill: wk-jira
date: 2026-04-29
type: gap
severity: medium
---

When wk-pr-break splits a PR into a stack of child PRs, the wk-jira `## Ticket` section is silently dropped from every child PR description.

**What happened:** Splitting PR #NNN into children #80/#81/#82, each child PR description was generated with only `Refs BOARD-NUM` / `Closes BOARD-NUM` mentions in body prose and a `[BOARD-NUM]` title suffix. None had the canonical wk-jira `## Ticket` block (`[BOARD-NUM](https://<org>.atlassian.net/browse/BOARD-NUM) — <ticket summary>`) at the top of the description. The user had to ask for a manual fix on all four PRs (the original plus three children).

**Root cause:** wk-jira's Stage 3 ("Description reference") is enforced by wk-pr's PR-creation flow but not by wk-pr-break's Stage 4 plan template or Stage 7 execution. The pr-break skill's child-PR description template only mentions Jira keys in the title-suffix routing rule and the prose `Refs/Closes` annotation rule — it never invokes the `## Ticket` section requirement. wk-jira itself has no defensive check that fires when descriptions lack the section, so child PRs slip through.

**Suggested fix:**

1. **wk-jira side (this skill):** add a Stage 3 invariant — "Every PR with a `[KEY]` title suffix MUST also carry a `## Ticket` section near the top of the description with the linked ticket and summary. Skills that generate PR descriptions (wk-pr, wk-pr-break, wk-pr-update on merge-rebase commits) must populate this section, not just the prose annotations."
2. **wk-pr-break side:** in Stage 4's "Propagate parent annotations into the right child" table, add an entry: `wk-jira ## Ticket section → every child` — and make the Stage 4 plan template surface the section explicitly so it's visible to the user during Stage 6 review.
3. **Detection:** wk-jira could add an audit step at PR-open time that greps the description for `## Ticket` and inserts a templated section if missing — defense in depth against any description-generating caller.
