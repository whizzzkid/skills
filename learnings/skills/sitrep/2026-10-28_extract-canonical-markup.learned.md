---
skill: wk-sitrep
date: 2026-10-28
type: pattern
severity: low
verified-against-source: n/a
---

Generate the page by extracting the canonical handler and copy-block markup from the prior page, not retyping it.

**What happened:** An inline script read the checkbox onclick handler and the standup copy-block prefix verbatim from
the previous live page, took item text from a scratch file, and emitted sequential spans. Escaped hashes survived and
the render containment check passed on the first attempt. A truncated gather report was recovered by messaging the
agent for only the missing sections.

**Root cause:** n/a (worked as intended).

**Suggested fix:** Document extraction-from-prior-page as the preferred source for canonical markup, and name
"resend only the missing sections" as the truncation follow-up.
