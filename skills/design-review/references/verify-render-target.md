---
class: principle
---

**Rule** — Before trusting a live render, confirm the port is serving this app's
own dev server on the current branch. Grep the fetched page source for a
project-specific marker from the diff (class/id/string); on mismatch,
`lsof -i :<port>` to confirm the listener is the project's process. If not, fall
back to static source analysis and say so in the findings.

**Why** — HTTP 200 / a TCP connect proves only that *something* answers on the
port, not that it is the right server. A stale SSH port-forward or an unrelated
local service renders a plausible-looking wrong page that a screenshot alone
would not expose.

**Where** — Step 1 (render-target verification) and the Common Mistakes row on
trusting a 200.
