---
skill: wk-sitrep
date: 2026-06-10
type: correction
severity: medium
---

Two logically distinct action items that share the same canonical URL (e.g. "prep for X" and "complete scorecard for X" both linking to the same resource page) will incorrectly collapse into one dismissed entry — completing the prep item silently suppresses the follow-up action.

**What happened:** An interview prep item and a post-interview scorecard completion item both used the same resource URL as their `key` in the dismissed registry. When the user checked off the prep item, its URL was written to the dismissed registry. On the next `start` run, the scorecard completion item (still open, `data-done="false"`) was filtered out because it shared the same key.

**Root cause:** The dismissed filter is URL-keyed, which assumes one URL = one logical action. Items that represent different workflow stages for the same resource (prep → attend → debrief → scorecard) all point to the same resource URL but require separate tracking.

**Suggested fix:** When writing dismissed entries, use the most action-specific URL available as the key — prefer the calendar event URL, a direct scorecard link, or a sub-path anchor over a shared resource root URL. If no more-specific URL exists, append a deterministic action slug to the key: `{url}#action=scorecard-complete`. Document this in the dismissed registry section of the skill.
