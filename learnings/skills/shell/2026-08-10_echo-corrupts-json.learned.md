---
skill: wk-shell
date: 2026-08-10
type: correction
severity: low
verified-against-source: yes
---

Use `printf '%s'` instead of `echo` when passing captured JSON to a parser.

**What happened:** A shell command captured JSON containing escaped carriage returns, then `echo` interpreted those
escapes and caused `jq` to fail with `Invalid string: control characters from U+0000 through U+001F must be escaped`.

**Root cause:** The active shell's `echo` implementation interpreted backslash escapes in the captured JSON instead
of preserving the bytes returned by the producer.

**Suggested fix:** Pipe JSON directly into the parser or emit a captured JSON string with `printf '%s'` so escape
sequences remain intact.
