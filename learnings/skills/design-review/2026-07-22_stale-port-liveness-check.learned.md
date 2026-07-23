---
skill: wk-design-review
date: 2026-07-22
type: gap
severity: medium
---

A "port responds with 200" check is not proof the target app is running there.

**What happened:** Before rendering a UI change with the Playwright MCP, a quick `curl` liveness check against the expected dev-server port returned 200, so the render step proceeded straight to navigation. The port turned out to be an unrelated service reached via a long-lived SSH port-forward (from prior local setup), rendering a completely different, stale page. The mismatch surfaced only because the rendered markup didn't match any expected class name — a screenshot alone would have looked plausible.

**Root cause:** Liveness (`curl` 200 / TCP connect) confirms *something* answers on the port, not that it is *this* app's dev server on the current branch. Local `mkdir/lsof` showed the "server" was actually an `ssh` process forwarding elsewhere, not the app's own process.

**Suggested fix:** Before trusting a live render, grep the fetched page source for one project-specific marker (a known class/id/string from the current diff) rather than relying on HTTP status alone. On mismatch, `lsof -i :<port>` to confirm the actual listener is the project's own server process before spending further time rendering; if it isn't, fall back to static source analysis and say so explicitly in the findings rather than silently skipping the render step.
