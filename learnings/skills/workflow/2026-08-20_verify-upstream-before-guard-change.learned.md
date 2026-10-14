---
skill: wk-workflow
date: 2026-08-20
type: correction
severity: high
verified-against-source: yes
---

Verify whether an upstream function change already satisfies an existing guard before replacing it

**What happened:** After updating `domainFromUrl` to return non-null for `file://` and `chrome-extension://`/`moz-extension://` URLs, the agent also replaced the tab-lifecycle guard (`tabDomain !== null && active.domain !== tabDomain`) with a broader check (`tab.url !== undefined && tabDomain !== active.domain`). This introduced two bugs: empty-string `tab.url` (`""`) incorrectly triggered session termination, and navigating to any browser-internal URL (`chrome://`, `about:`) ended the running session — contradicting the documented "null domain does not reset" policy.

**Root cause:** The agent assumed the guard needed widening to handle the new URL schemes, without first tracing whether the upstream `domainFromUrl` change already made the existing guard correct. Since `domainFromUrl` now returns non-null for `file://` and extension URLs, the original `tabDomain !== null` check already passes for those schemes — no guard change was needed.

**Suggested fix:** Add a workflow step: "Before modifying a guard, filter, or conditional that consumes a function's output, verify whether changes to that function already make the existing guard correct. When a function returns non-null for new inputs, existing null-checks naturally cover those inputs without modification."
