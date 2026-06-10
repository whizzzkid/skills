---
skill: wk-curl
date: 2026-06-09
type: pattern
severity: high
---

Always use `-sS` (not `-s`) when capturing curl output for parsing, and always capture the exit status.

**What happened:** Instructions used `curl -s` to call an external REST API, then parsed stdout for an error message. `-s` suppresses both the progress meter AND curl's own transport-error diagnostic (DNS failure, TLS error, connection refused) — stdout is empty on transport failure, so downstream error parsing produces a misleading empty-reason message.

**Root cause:** `-s` (silent) and `-S` (show errors) are orthogonal flags. `-s` alone is the anti-pattern when the call has an error-reporting path; `-sS` is the correct idiom. This is documented curl behavior but not instinctively applied.

**Suggested fix:** Any curl call whose response is parsed must use `-sS` and capture `$CURL_EXIT` with `RESPONSE=$(curl -sS ...) ; CURL_EXIT=$?`. Branch on exit status before parsing body: non-zero → transport failure (curl already printed the reason to stderr); zero + no expected field → API error. Template:
```bash
RESPONSE=$(curl -sS -X <METHOD> "<URL>" -H "..." -d "$PAYLOAD")
CURL_EXIT=$?
if [ $CURL_EXIT -ne 0 ]; then
  echo "Network error (curl exit $CURL_EXIT) — see stderr above"
elif [ -z "$(echo "$RESPONSE" | jq -r '.web_url // empty')" ]; then
  echo "API error: $(echo "$RESPONSE" | jq -r '.message // empty' || echo "$RESPONSE")"
else
  # success path
fi
```
