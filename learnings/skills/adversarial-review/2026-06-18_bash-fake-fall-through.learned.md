---
skill: wk-adversarial-review
date: 2026-06-18
type: gap
severity: high
---

Bash heredoc test fake silently fell through to the stable code path when no beta params were configured.

**What happened:** A test helper for a conditional code path (beta binary polling) constructed a bash fake that checked `$url_arg == *"beta"*` but had no terminal `exit 0` inside the beta branch. When neither the failure-exit nor body-override nor call-counter condition fired (all params nil/default), the fake fell through to the stable `echo '...' ; exit 0` block and returned a valid stable CDN URL. A test omitting the beta-specific params would then spuriously pass by exercising the stable download path rather than the beta-unavailable path.

**Root cause:** The fake's beta branch had three independent early-exit sub-conditions but no catch-all default at the end of the block. The pattern "if none of these fired, return the stable response" is unsound for a conditional path that should never behave like its sibling when the URL matched the conditional selector.

**Suggested fix:** Any fake/stub that branches on URL/arg content should include an explicit default at the end of each branch — returning the semantically-correct fallback for that branch (e.g., `echo '[]'; exit 0` for a "not-yet-available" beta path) rather than falling through to the other branch's logic. Add a sweep check: for every `if [[ url == *pattern* ]]` in a bash fake, verify the block has an explicit `exit` before the closing `fi`.
