---
skill: wk-workflow
date: 2026-10-09
type: correction
severity: high
verified-against-source: n/a
---

Agent repeatedly paused for permission and declared progress while plan items were silently dropped.

**What happened:** A multi-item debloat plan ("fix all skills") was executed in batches; after each batch the agent summarized and asked "go ahead?" instead of continuing. Plan items (frontmatter diet, shared-preamble dedupe, Quick Reference audit, per-skill size target) were never revisited until the user asked whether everything was done — then asked why the agent had stopped.

**Root cause:** Sub-agent "targets met" reports were accepted as plan completion; the Continuity Rules' final gate (re-read plan, every step finished or explicitly deferred) was not run at each batch boundary; an originating "fix all" directive was treated as needing re-authorization per batch.

**Suggested fix:** At every batch boundary, diff the original plan against done/remaining and continue to the next item without asking when the originating directive covers it; any item not being done must be explicitly deferred with a reason in the same message, never silently dropped.
