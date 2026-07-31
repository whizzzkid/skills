---
skill: wk-testing-skeleton
date: 2026-07-28
type: surprise
severity: medium
verified-against-source: yes
---

Drive the browser action before testing an activeTab-gated extension flow.

**What happened:** A real-browser screenshot runner opened the extension popup URL directly, then
timed out waiting for gesture-gated content injection.

**Root cause:** Direct extension-page navigation does not grant activeTab; the working end-to-end
path first triggers the browser action through the browser protocol and only then drives the popup.

**Suggested fix:** Add an extension-test checklist item requiring the real browser action or command
gesture before any assertion that depends on activeTab permission.
