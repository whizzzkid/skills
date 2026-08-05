---
skill: wk-gh
date: 2026-08-05
type: surprise
severity: medium
verified-against-source: yes
---

Validate the server-returned PR body after integrations can mutate it.

**What happened:** A tracker integration appended a generated Markdown reference definition after the canonical footer,
even though the submitted PR body ended with the footer and passed the pre-emit gate.

**Root cause:** Re-fetching the PR body after the edit confirmed that the integration materialized the reference
definition server-side, moving the footer away from the last-content position.

**Suggested fix:** After creating or editing a PR body, re-fetch the server-returned body and rerun footer placement
validation; if generated reference metadata follows the footer, preserve it before the footer and submit once more.
