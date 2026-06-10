---
skill: wk-workflow
date: 2026-06-09
type: gap
severity: low
---

When introducing a new language toolchain to a repo, run the full new CI gate set locally (including formatters) immediately before push — files added after the last local lint run silently skip it.

**What happened:** A Go file added late in the session failed CI's `gofmt -l` gate (doc-comment indentation) although earlier files had been checked; the local gofmt sweep predated the file.

**Root cause:** Lint was run once mid-session, not as a final pre-push gate covering all files.

**Suggested fix:** The pre-push checklist for a diff that adds a new toolchain must re-run every gate the new CI step will run, verbatim, against final HEAD.
