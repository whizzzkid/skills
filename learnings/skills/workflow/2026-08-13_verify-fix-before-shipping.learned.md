---
skill: wk-workflow
date: 2026-08-13
type: correction
severity: medium
verified-against-source: n/a
---

Shipping a fix without observable user-side verification invites "I dunno what you fixed" feedback.

**What happened:** Agent added a polling-based `waitForContentReady` helper to address a content-script readiness race. The user tested and reported no visible change in behavior. The fix addressed a theoretical timing window but had no observable effect on the actual symptom (panel and toolbar appearing on separate keypresses).

**Root cause:** The agent diagnosed a race condition and added retry/polling code without first confirming the root cause matched the user's observed symptom. The real issue was that the content script's async `loadSettings()` await delayed `initializeContent()` — a fundamentally different problem from message-delivery timing. The polling fix targeted the wrong layer.

**Suggested fix:** Before shipping a fix for a user-reported behavior issue, verify that the fix addresses the exact symptom the user described, not a plausible-but-different failure mode. When the fix cannot be tested in-agent (UI behavior requiring manual browser interaction), state explicitly what the user should observe differently and why. If multiple hypotheses exist, test the simplest one first (synchronous init) before adding complexity (polling/retry).
