---
skill: wk-workflow
date: 2026-08-13
type: correction
severity: high
verified-against-source: yes
---

Chrome's `sidePanel.open()` must be called synchronously within the user-gesture handler — not after an awaited promise.

**What happened:** Agent sequenced `sidePanel.open()` after `await controller.toggle()` in the `action.onClicked` handler, attempting to conditionally open the panel only on session start. The panel stopped appearing entirely — the user reported "the fix you made stopped the panel from showing up entirely, it's broken now."

**Root cause:** Chrome's side panel API requires `sidePanel.open()` to be invoked within the synchronous call stack of a user-gesture event (click or keyboard shortcut). Inserting an `await` before the call breaks the gesture context chain, and Chrome silently drops the `open()` request with no error. The API does not throw or reject — it simply does nothing.

**Suggested fix:** When implementing browser extension features that combine side panel visibility with other async operations, always fire `sidePanel.open()` in the same synchronous tick as the gesture handler. Run async work (session toggle, content script injection) in parallel via `void promise.catch(…)`, never sequenced before the panel call. Add a workflow guardrail: "browser APIs requiring user-gesture context (sidePanel.open, window.open, downloads.download) must be called synchronously in the event handler — never after an await."
