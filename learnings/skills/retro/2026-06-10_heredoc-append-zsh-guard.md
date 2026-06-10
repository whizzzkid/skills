---
skill: wk-retro
date: 2026-06-10
type: gap
severity: low
---

Heredoc append `cat >> "$FILE" <<'MARKER'...MARKER` can fail silently in zsh when the inline heredoc contains a variable that expands to empty.

**What happened:** The retro entry was written using a bash variable `$DRAFT` that expanded to an empty string (the mktemp temp file had already been removed), causing the heredoc append to write nothing to the log file without error.

**Root cause:** The retro flow uses a `$DRAFT` intermediate variable; when it is unset or empty, the redirect silently produces an empty file. No guard exists on the variable before writing.

**Suggested fix:** Always validate `$DRAFT` / `$FILE` is non-empty before the append. Better: skip the temp file entirely and write the entry inline with `cat >> "$FILE" <<'EOF'...EOF` using a fixed quoted marker, which does not involve an expandable variable.
