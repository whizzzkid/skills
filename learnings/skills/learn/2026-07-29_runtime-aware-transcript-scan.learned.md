---
skill: wk-learn
date: 2026-07-29
type: gap
severity: medium
verified-against-source: yes
---

Make interruption scans runtime-aware.

**What happened:** The interruption scan found no matching transcript for the current session
because it searched only one agent runtime's transcript tree, while the live conversation still
contained actionable corrections.

**Root cause:** Scan mode hard-codes one transcript root and schema without accepting a runtime
adapter or current-conversation fallback.

**Suggested fix:** Detect the active runtime or accept a transcript provider, then fall back to
the available conversation history with an explicit degradation notice when no matching session
directory exists.
