---
class: principle
---

# Post-push finalization

- Sync the PR description before replies or resolutions; preserve metadata and verify commit links, test-plan
  checkboxes, CI, remaining work, limitations, and file lists.
- No description drift → log the verified fields; claim Testing/Results only from known evidence, otherwise use an
  honest placeholder.
- Re-check submitted self-review comments and docs drift after every push; correct/resolve stale comments and invoke
  `wk-docs` for touched behavior, signatures, or configuration.
- Re-run the pending-self-review check, then post replies sequentially by surface. Quote issue comments; split
  suggestions from one issue comment share one combined reply.
- **Before EACH mutation (reply, PR-body edit, issue comment, dismissal): run the wk-gh Step 4 footer pre-emit
  gate on the final body string.** Grep for the canonical `<sup>Generated using [wk-skills]…/DM me your
  feedback.</sup>` marker and the pinned `tree/main@%7B…%7D` link; reject the commit-trailer variant (`🦾 Generated
  with …`). Lint each body independently — a footer carried on another surface never satisfies the current mutation.
- Refresh bot threads against HEAD with full bodies; an addressed echo gets reply+resolve, a new finding returns to
  Step 4. Use commands.md §8 for reaction, ID-refresh, and error recovery.
