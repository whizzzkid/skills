---
skill: wk-buildkite
date: 2026-06-22
type: correction
severity: medium
---

Never use `bk build view -w` just to obtain a build URL — it opens the default browser.

**What happened:** Agent ran `bk build view -p <pipeline> -b <branch> -w` intending to retrieve and share the build URL. The `-w` / `--web` flag opens the URL in the user's default browser immediately, causing an unexpected browser tab.

**Root cause:** Conflated "get the URL" with "open in browser." The `-w` flag is a launch action, not a URL-retrieval flag.

**Suggested fix:** To retrieve a build URL without opening a browser, use `bk build view --json 2>&1 | grep -v '^Warning:' | jq -r '.web_url'`. Reserve `-w` for cases where the user explicitly asks to open the build in a browser.
