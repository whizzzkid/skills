---
skill: wk-pr-review
date: 2026-11-24
type: gap
severity: low
verified-against-source: n/a
---

The mandatory "open URL" step can be denied by an auto-mode permission classifier.

**What happened:** After the approval went through, the required `open <html_url>` Bash call was denied by the auto-mode
classifier. The review was already submitted, so the only thing lost was the browser tab.

**Root cause:** The skill treats `open` as always available. In auto mode, launching a browser can be classified as an
outward-facing action and blocked.

**Suggested fix:** If `open` is denied, print the `html_url` in the terminal summary and move on. Never retry it or
work around the denial.
