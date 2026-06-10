---
skill: wk-sharpen
date: 2026-06-10
type: gap
severity: medium
---

When scrubbing a set of tokens where some are substrings of others, process longest-first.

**What happened:** A token-scrub pass had a short token and a long token that contained the short one as a prefix; correct ordering was needed to avoid partial corruption.

**Root cause:** No ordering rule exists in wk-sharpen for the mechanical overfit scan or for replacement maps (e.g., git filter-repo).

**Suggested fix:** When building a scrub or replacement map, sort entries by descending token length so the longer token is always replaced before any of its shorter substrings. Document this in the relevant sections of wk-sharpen.
