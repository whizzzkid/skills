---
skill: wk-sharpen
date: 2026-06-10
type: gap
severity: medium
---

A filter-repo replacement map run against its own example text corrupts the examples when one pattern is a substring of another and the map is not longest-first ordered.

**What happened:** A global `git filter-repo --replace-text` pass scrubbed PR-context tokens. The map file itself (committed as hook help text) contained before→after examples. A subsequent map application turned `repo#<n> -> repo#NNN` into `repo#NNN -> repo#NNN` because the short token was applied before the long one.

**Root cause:** The replacement-order rule (longest-first) in wk-sharpen covers proposed SKILL.md edits but not the filter-repo replacement map itself, which is a separate artifact the map can re-process.

**Suggested fix:** When building a multi-token filter-repo replacement map, always sort entries by descending token length (longest first) AND make the "before" examples in any help text use non-digit/non-matching placeholders (`<n>`, `{slug}`) so the map cannot match its own documentation.
