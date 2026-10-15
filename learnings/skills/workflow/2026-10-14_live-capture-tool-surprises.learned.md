---
skill: wk-workflow
date: 2026-10-14
type: gap
severity: low
verified-against-source: n/a
---

Tool-level surprises (a build-entitlement failure, an API 422) were worked around without a live learning capture.

**What happened:** Two non-obvious tool failures were resolved mid-session but only captured at retro time.

**Root cause:** The live-capture rule triggers on "self-caught error", and workarounds for environment or API failures
didn't register as errors.

**Suggested fix:** Treat any environment or API failure that needs a non-obvious workaround as a self-caught error, and
invoke wk-learn for the tool in the same response.
