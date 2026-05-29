---
skill: wk-pr
date: 2026-04-22
type: gap
severity: high
---

`wk-pr` Step 3 "Update PR description" rewrites the body without preserving `Closes #N`, `Co-authored-by:`, and automation metadata from the original body.

**What happened:** PR #NNN was originally created by an automation agent (`{agent}`) with a body that included `Closes #NNN`, a `**Build:** [...]` link, a `<details><summary>Prompt</summary>` context block, and `Co-authored-by:` attribution. When `wk-pr` Step 3 was invoked to refresh the description for accuracy, the agent read the current body, rewrote it as clean prose, and called `gh pr edit --body-file` — silently dropping `Closes #NNN` along with the other metadata. Traced via GitHub GraphQL `userContentEdits`: the first rewrite replaced the entire body and removed every metadata-bearing line. The PR would have merged without auto-closing issue #NNN, which the user only noticed much later.

**Root cause:** Step 3 item 1 says "Review the existing description to ensure it still covers all changes. If it has drifted, update with `gh pr edit`." It gives no rule for what MUST be preserved when overwriting. The agent treats the body as prose to be rewritten, not as a document with structured metadata fields that carry semantic weight outside the prose (issue-linking, attribution, CI provenance). The PR template resolution logic in Step 2 has the same blind spot: when a repo template is used, the skill says to "populate every section with real content" but doesn't mention carrying forward metadata from a pre-existing body on subsequent edits.

**Suggested fix:** Add an explicit "preserve metadata" subclause to Step 3 item 1 (and mirror it in Step 2 for first-edit cases). Specifically: before calling `gh pr edit` with a new body, extract and carry forward these fields from the current body:

- `Closes #N` / `Fixes #N` / `Resolves #N` auto-close keywords (GitHub only honors these in the PR body, not commits in a closed branch)
- `Co-authored-by:` lines — attribution metadata
- Automation-generated blocks: `**Build:** [...]` links, `<details><summary>Prompt</summary>` context, generator footer lines
- Any line matching `@user mentioned` at the body level that exists for notification purposes

Generalize the rule as: "treat PR body metadata (issue links, attribution, automation provenance) as append-only unless explicitly asked to remove it — rewrites change prose, not metadata." The rule should apply equally in `wk-pr-resolve` (which also edits PR bodies after pushing fixes) and any ad-hoc `gh pr edit` call. Consider surfacing it as a Hard Rule at the top of `wk-pr` so the agent loads it into working memory before any body edit.
