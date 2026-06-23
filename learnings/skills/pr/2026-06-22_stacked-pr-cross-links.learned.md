---
skill: wk-pr
date: 2026-06-22
type: gap
severity: low
---

Auto-inject cross-reference links in stacked PR descriptions.

**What happened:** When creating a 4-PR stack (PR1 → PR2 → PR3 → PR4 via branch bases), the skill created each PR with its body content but did not populate the cross-reference links (`[#NNN](...)`) between them. These links had to be added manually via 4 separate `gh pr edit` calls post-creation, breaking DRY and creating maintenance debt.

**Root cause:** The skill doesn't introspect the base branch relationship (base == previous-PR-branch) to infer the stack ordering and inject canonical links into the body template.

**Suggested fix:** In the PR create step, after `gh pr create` succeeds, detect whether the PR's base branch matches a previous PR's head branch (stacking pattern). If yes, surface a prompt: "This PR stacks on #{N}. Inject cross-reference links into body? (y/n)" If yes, update the body with `[Previous PR #{N}]({url}) ← [Next PR #{M}]({url})` or similar canonical format, then `gh pr edit` to sync. Alternatively, detect the pattern upfront and populate these links in the description template BEFORE calling `gh pr create`, so all links are present in the first pass.

