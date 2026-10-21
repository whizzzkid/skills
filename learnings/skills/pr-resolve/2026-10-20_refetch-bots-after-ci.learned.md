---
skill: wk-pr-resolve
date: 2026-10-20
type: gap
severity: medium
verified-against-source: yes
---

Re-fetch review threads after CI goes green; the bot reviews each push and may escalate.

**What happened:** After pushing a fix and seeing green CI, the run reported done without re-running the thread fetch. The review bot had re-reviewed the new head and posted a blocking finding that only surfaced when the user asked about the watch.

**Root cause:** The CI watch was started several calls after the push, and the post-CI loop (re-run the fetch step) was skipped.

**Suggested fix:** Start the CI watch in the same turn as the push, and on its completion always re-fetch threads and bot summary comments before any "done" report.
