---
skill: wk-sitrep
date: 2026-11-13
type: gap
severity: low
verified-against-source: n/a
---

In-place page transform: resolve every target line index up front, mark drops with a sentinel, then insert.

**What happened:** An inline transform script replaced a span (which resets its `data-t` placeholder), then looked the
same span up by its old `data-t` to insert siblings after it, and aborted on the assertion. A second attempt that
collected drops as raw indexes and then inserted lines would have shifted every drop index.

**Root cause:** Lookups by `data-t` are only valid until the first replacement of that span, and list indexes are only
valid until the first insert or delete.

**Suggested fix:** In Stage 4's "transform the prior page" bullet: build an `{old data-t: line index}` map before any
edit, set dropped lines to a sentinel, apply inserts from the highest index down, filter sentinels, then renumber.
Also: a browser clipboard readback can hang on a missing permission, so run it with a timeout and report the copy
button as unverified rather than waiting.
