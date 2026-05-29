---
class: principle
date: 2026-05-29
skill: wk-slack
---

# ClipboardItem text/html copy needs a writeText fallback

- **Rule:** Copy buttons that write Slack-compatible rich text via
  `ClipboardItem` (`text/html`) must fall back to
  `navigator.clipboard.writeText(el.innerText)` when `ClipboardItem` is
  unavailable.
- **Why:** `ClipboardItem` is absent in older browsers and insecure
  (non-HTTPS) contexts; without a fallback the copy button silently does
  nothing. The core text/html rule was already in Step 3a "Context C".
- **Where:** Step 3a "Context C" — appended fallback clause.
