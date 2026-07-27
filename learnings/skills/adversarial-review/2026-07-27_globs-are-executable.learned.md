---
skill: wk-adversarial-review
date: 2026-07-27
type: gap
severity: medium
verified-against-source: n/a
---

A documented glob that matched zero files read as a valid reference through two review rounds.

**What happened:** A plan item instructed a future agent to inspect
`<bundle>/components/*.card.html`. The files actually live one directory deeper, under per-category
subdirectories, so the glob matched nothing. Two prior adversarial rounds read the path, found it
plausible, and cleared it. It was only caught by mechanically expanding every documented path
pattern and asserting a non-zero match count.

**Root cause:** Path references in docs are reviewed as prose, not driven as commands. A pattern
that is syntactically valid and semantically plausible passes a reading review; it only fails for
the agent who later runs it, by which point the doc reads as authoritative and the agent concludes
the files do not exist.

**Suggested fix:** Add a sweep: for every path pattern in the diff containing a glob (`*`, `**`,
`?`) or brace expansion, expand it against the working tree and assert at least one match. Brace
patterns need real expansion — a naive existence check on the literal string reports a false
MISSING and masks the genuine zero-match glob sitting next to it. Treat a documented path pattern
as executable, exactly as the catalog already treats a documented command.
