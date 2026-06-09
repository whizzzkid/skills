---
skill: wk-adversarial-review
date: 2026-06-09
type: gap
severity: medium
---

Flag `curl -s` (without `-S`) on any external call whose failure path is parsed — silent mode swallows transport errors and produces empty-body diagnostics.

**What happened:** Skill instructions used `curl -s` to call an external API, then parsed the response body for an error message. When curl fails at the transport layer (DNS, TLS, connection refused), `-s` suppresses curl's own stderr diagnostic AND stdout is empty, so the body-parsing failure branch printed a misleading empty-reason message instead of the actual network error.

**Root cause:** No mechanical sweep checks for `curl -s` paired with response-body error parsing. `-s` alone (without `-S`) is the anti-pattern; the call needs `-sS` plus an exit-status check to distinguish transport failures from API errors.

**Suggested fix:** Add an error-handling sweep: grep the diff for `curl -s` not immediately followed by `S` (i.e., `curl -s ` or `curl -s\b` but not `-sS`/`-Ss`). For each hit where the response is later parsed for errors, flag as a transport-error-swallowing gap. Detection: `git diff | grep -nE 'curl\s+-s\b' | grep -v 'sS\|Ss'`.
