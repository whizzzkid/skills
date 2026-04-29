---
skill: wk:pr-review
date: 2026-04-29
type: gap
severity: low
---

After posting a pending review, automatically open the review's `html_url` in the browser so the user can immediately review and submit.

**What happened:** The skill posts the pending review, prints the URL in confirmation text, and stops. The user has to copy/click the link manually. User asked for the URL to be opened automatically.

**Root cause:** Phase 6's "After posting" step only prints the URL ("Pending review created with N comments. Go to {pr-url} to review and submit when ready."). No action to launch the browser.

**Suggested fix:** Add an `open` step to Phase 6 immediately after the `gh api` POST, using the `html_url` returned in the response. Cross-platform:

```bash
# macOS
open "<html_url>"
# Linux
xdg-open "<html_url>"
# Windows
start "<html_url>"
```

Detect platform from `uname` or rely on macOS default for $EMPLOYER laptops. The skill should capture `html_url` from the `--jq` output (already done in the example) and pipe it to `open`. Confirmation message stays — the URL is still useful for terminal scrollback and remote sessions where the browser can't launch.
