---
skill: wk-adversarial-review
date: 2026-06-01
type: pattern
severity: medium
---

A local-variable rename must trigger the cross-doc enumeration sweep, including spec word-choice/mapping tables and test descriptions.

**What happened:** A reviewer asked to rename two local variables in a function (severity-bucket accumulators). The rename touched only the function body, but the feature's spec doc carried a word-choice mapping table whose column headers and bullet definitions used the old names, and the test file had comments + test-function names + error-label strings referencing the old names. The existing cross-doc enumeration sweep (2.8) caught the stale spec table during pre-flight, before push.

**Root cause:** None — the sweep worked as designed. The reinforcement worth recording: a "trivial local rename" is exactly the change an author assumes is self-contained, so the doc/test sweep is most valuable precisely when the diff looks too small to need it.

**Suggested fix:** Keep treating renames (even local-scope, behavior-preserving ones) as enumeration-affecting changes. Detection sketch that worked: `grep -rn '<old-name>' <source-dir> docs/` after the rename — flag every hit in (a) spec mapping/word-choice tables, (b) test-function names, (c) test error-label strings, not just prose. Confidence: high (mechanical grep detection).
