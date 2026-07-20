---
class: principle
---

# Dismissed registry — jq write + filter recipes

Canonical implementations for the cross-run de-dup registry described in
`SKILL.md` § Dismissed registry. `$WEEK_MEM_FILE` is defined in Step 0.

## Write (both sub-commands)

`jq`-constructed JSON only; never raw interpolation. Strip markdown escapes,
validate the file still parses, and remove the last line on failure.

```bash
title=$(printf '%s' "$raw_title" | sed 's/\\#/#/g')   # strip markdown escapes
jq -nc --arg key "$key" --arg type "$type" --arg title "$title" \
   --arg at "$TODAY" --arg because "$reason" --arg week "$YEAR-W$WEEK" \
   '{key:$key,type:$type,title:$title,dismissed_at:$at,dismissed_because:$because,week:$week}' \
   >> "$WEEK_MEM_FILE"
if ! jq -r '.key' "$WEEK_MEM_FILE" >/dev/null 2>&1; then
  echo "ERROR: $WEEK_MEM_FILE failed to parse after write — removing last line"
  sed -i '' '$d' "$WEEK_MEM_FILE"
fi
```

## Filter (`start`)

Drop any gathered or carry-over item whose key is in this week's registry.

```bash
is_dismissed() { [ -f "$WEEK_MEM_FILE" ] && jq -e --arg k "$1" \
  'select(.key==$k)' "$WEEK_MEM_FILE" >/dev/null 2>&1; }
```
