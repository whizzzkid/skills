---
skill: wk-sitrep
date: 2026-06-10
type: correction
severity: high
---

Dismissed registry `.jsonl` entries written via bash interpolation silently produce invalid JSON when titles contain `\#`, breaking all subsequent `jq` reads.

**What happened:** The bootstrap script extracted item titles from the live page (which uses `\#` for SilverBullet link-text escaping) and wrote them directly into JSON strings. `\#` is not a valid JSON escape sequence, so `jq` failed to parse the file and reported zero dismissed keys — meaning the filter had no effect.

**Root cause:** Bash interpolation into JSON strings was done without sanitization. The `\#` escape is a SilverBullet/Markdown convention, not a JSON one. JSON only permits `\"`, `\\`, `\/`, `\b`, `\f`, `\n`, `\r`, `\t`, and `\uXXXX`.

**Suggested fix:** Strip Markdown escapes from title values before writing to `.jsonl`. Use `jq` to construct the JSON object rather than raw string interpolation:

```bash
jq -nc --arg key "$url" --arg type "$type" --arg title "$title" \
   --arg dismissed_at "$TODAY" --arg because "$reason" --arg week "$YEAR-W$WEEK" \
   '{key:$key,type:$type,title:$title,dismissed_at:$dismissed_at,dismissed_because:$because,week:$week}' \
   >> "$WEEK_MEM_FILE"
```

After writing any entry, validate the file parses cleanly: `jq -r '.key' "$WEEK_MEM_FILE" > /dev/null || echo "PARSE ERROR"`.
