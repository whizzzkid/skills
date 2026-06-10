---
skill: wk-sitrep
date: 2026-06-10
type: gap
severity: medium
---

The dismissed registry write path has no validation step — invalid entries accumulate silently and the parse failure only surfaces later when the filter tries to read keys.

**What happened:** Multiple entries were written to the `.jsonl` registry using raw bash string interpolation. One entry contained an invalid JSON escape, causing all subsequent `jq` reads to fail at that line. The filter appeared to work (no error surfaced at write time) but had silently stopped applying after the first bad entry.

**Root cause:** The skill spec describes the bash `echo '...'` write pattern without requiring post-write validation. There is no guard between "write entry" and "confirm registry is still parseable."

**Suggested fix:** Add a validation step immediately after every write to the dismissed registry:

```bash
# After appending a new entry:
if ! jq -r '.key' "$WEEK_MEM_FILE" > /dev/null 2>&1; then
  echo "ERROR: week memory file failed to parse after write — removing last line"
  sed -i '' '$d' "$WEEK_MEM_FILE"
fi
```

Also mandate `jq`-constructed writes (not raw interpolation) as the only permitted write pattern in the skill spec.
