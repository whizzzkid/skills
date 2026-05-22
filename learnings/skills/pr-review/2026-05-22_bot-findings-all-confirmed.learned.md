---
skill: wk-pr-review
date: 2026-05-22
type: pattern
severity: low
---

All bot findings confirmed, zero new blocker bugs found — review body carried the substance.

**What happened:** The PR had 4 inline bot findings + 2 out-of-diff summary findings from the project's own CI bot. Phase 4 playground ran reproduction scripts on each; all 6 were confirmed exactly as the bot stated. Zero new inline comments warranted beyond one minor operator-log suggestion the bot hadn't flagged.

**Root cause:** The bot (same codebase, runs as part of the repo's own CI) caught every actionable issue. The agent's value was (a) confirming the bot's findings with executable evidence and (b) surfacing one new finding the bot missed (misleading log on zero-inline-but-nonzero-total path).

**Suggested fix:** When all bot findings are Confirmed and there are no new findings, the skill should still produce a clear review body that *names* each bot finding as confirmed — so the reviewer doesn't have to wonder if the agent ignored the bot. The current guidance says "skip silently" for Confirmed but the review body should acknowledge them collectively.
