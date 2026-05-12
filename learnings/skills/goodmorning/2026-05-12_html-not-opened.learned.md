---
skill: wk-goodmorning
date: 2026-05-12
type: correction
severity: high
---

HTML dashboard not opened before announcing completion.

**What happened:** After writing morning.md and morning.html, the agent printed the completion announcement and commit/push offer without calling `open` on the HTML file. The user had to explicitly ask why the file wasn't opened.

**Root cause:** The `open` command in `§Open for review` was treated as optional or deferred to after the user acknowledged the announcement. Auto mode compounded this — the agent interpreted "Would you like to commit and push?" as the terminal step.

**Suggested fix:** Mark `open "$TODAY_DIR/morning.html"` as unconditional — runs immediately after both files are written, before any announcement, before any commit/push offer, with no auto-mode exemption. The announcement text should confirm "opened in browser" as a past fact, not offer it as a choice.
