---
skill: wk-learn
date: 2026-06-25
type: gap
severity: medium
---

Transcript scan fails silently when repo name contains underscores because Claude normalizes underscores to hyphens in project directory names.

**What happened:** The scan derived PROJECT_SLUG from $PWD using `sed 's|/|-|g'`, producing `my_repo` (with underscore). Claude's actual project directory used `my-repo` (with hyphen). The `find` command returned nothing, requiring manual directory lookup.

**Root cause:** Claude Code normalizes directory separator characters AND underscores when naming project directories — the sed command only replaces `/` with `-`, missing the `_` → `-` normalization. The mismatch is silent: find returns empty and the scan reports zero interruptions without warning.

**Suggested fix:** Add a fallback in Step S1: if the exact-slug find returns zero files, try a glob with underscores replaced by hyphens: `find "$TRANSCRIPT_ROOT/$(echo "$PWD" | sed 's|/|-|g; s|_|-|g')"`. Or list project dirs and fuzzy-match by longest common substring.
