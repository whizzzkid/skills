---
class: principle
skill: wk-buildkite
date: 2026-06-23
---

**Rule**

Non-required checks (security scanners, dependency bots) never gate a merge.
Don't block or keep polling on them — gate only on GitHub *required* checks via
`gh pr checks --json name,state,required | jq 'select(.required==true)'`.

**Why**

Informational checks often queue indefinitely; waiting for them delays the merge
even though every required check has passed.

**Where**

"Monitoring Builds After Push" section. The required-only gating mechanism is
owned by pr-merge Step 2 (same principle, cross-referenced).
