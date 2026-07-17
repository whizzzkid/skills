---
skill: wk-sitrep
date: 2026-07-17
type: gap
severity: low
---

Stage 5 render-verification opens a visible browser tab and leaves it open after the assertion passes, cluttering the user's desktop.

**What happened:** To satisfy the "gate the announcement on a verified render" hard rule, the agent used a browser-automation tool to `navigate` to the live page and `evaluate` the 3-column assertion. That tool call opens a real, visible browser window. After the assertion returned `true`, the agent moved on to `open`-ing the user-facing tab and never closed the verification window — leaving an extra, unexplained browser window behind for the user to notice and close manually.

**Root cause:** The skill's render-verification step specifies *what* to assert (3 non-empty `.sitrep-col` elements) but not *how* the browser session should be scoped. Without an explicit instruction to run headless and tear down afterward, the natural approach reuses whatever default (headed) browser context the automation tool provides, and nothing in the flow prompts closing it since it's a separate concern from the assertion result.

**Suggested fix:** When the render-verification step needs a browser-automation tool, explicitly: (1) prefer/request a headless context if the tool supports one, and (2) close/dispose that browser session immediately after reading the assertion result, before proceeding to the separate `open` call that shows the user-facing tab. Treat the verification browser and the user-facing tab as two distinct sessions with different lifecycles — one is disposable tooling, the other is what the user actually wants left open.
