---
skill: wk-workflow
date: 2026-08-13
type: correction
severity: high
verified-against-source: yes
---

`chrome.sidePanel.setPanelBehavior({openPanelOnActionClick: true})` suppresses `action.onClicked` entirely — do not combine it with click-handler logic.

**What happened:** Agent called `setPanelBehavior({openPanelOnActionClick: true})` during background init, expecting Chrome to handle panel toggling natively while still firing `action.onClicked` for session/overlay logic. The extension regressed to only toggling the panel — the user reported "The feature has regressed after your last change, it is now only toggling the panel."

**Root cause:** When `openPanelOnActionClick` is enabled, Chrome takes over the toolbar click entirely: it toggles the side panel natively and **does not fire** the `action.onClicked` event. Any logic registered in that handler (session lifecycle, overlay injection, badge updates) silently stops running. This is documented Chrome behavior but counter-intuitive — the API name suggests additive behavior, not exclusive takeover.

**Suggested fix:** Never enable `setPanelBehavior({openPanelOnActionClick: true})` in extensions that rely on `action.onClicked` for custom logic. If both native panel toggling and custom click behavior are needed, use the manual `sidePanel.open()` approach (called synchronously in the gesture handler) alongside the custom logic. Add a workflow guardrail: "before using a browser API that automates a user-facing action, verify whether it suppresses the event handler for that same action."
