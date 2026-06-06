---
skill: wk-goodmorning
date: 2026-05-28
type: gap
severity: medium
---

Standup snippet bundled multiple merged PRs into one bullet without bare URLs for each.

**What happened:** The "Yesterday" standup bullet listed four merged PRs (#156, #161, #163, #166) in a single sentence with no URLs. The skill's HARD RULE requires "every bullet in Yesterday/Today/Blockers must include at least one bare URL pointing to its primary artifact" and "if it maps to multiple artifacts, include all of them space-separated."

**Root cause:** When multiple merged PRs are grouped into a single summary bullet (e.g., "Merged 4 PRs: X, Y, Z, W"), the URL-enforcement logic is applied at the bullet level — one URL satisfies the rule — rather than per-artifact. The grouping itself obscures that each PR needs its own URL.

**Suggested fix:** When building the Yesterday slot from merged PRs, either (a) emit one bullet per PR with its URL, or (b) if grouping for brevity, append a space-separated bare URL for every PR in the group on the same line. Add an explicit rule: "A grouped 'merged N PRs' bullet is only valid if it includes a bare URL for each PR in the group."
