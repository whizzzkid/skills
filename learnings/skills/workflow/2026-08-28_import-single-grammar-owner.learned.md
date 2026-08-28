---
skill: wk-workflow
date: 2026-08-28
type: gap
severity: low
verified-against-source: n/a
---

New helper logic that needs a contract an existing module already owns must import it, not fork a copy.

**What happened:** A new helper module reimplemented the URL-hash grammar (which segment is an anchor, how state serializes) that an existing module already owned. Review flagged it as a module-boundaries violation, forcing a follow-up PR to collapse the duplicated grammar back to the single owner and have the consumer import it.

**Root cause:** The task authored the helper as self-contained for testability without checking whether the contract it needed was already owned elsewhere; a parallel copy of a shared grammar diverges silently and is a boundaries finding waiting to happen.

**Suggested fix:** Before writing helper logic that parses/serializes a shared format or enforces a shared contract, grep for an existing owner of that grammar and import from it; extract only the genuinely helper-specific pure logic into the new module.
