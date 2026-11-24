---
skill: wk-workflow
date: 2026-11-24
type: gap
severity: high
verified-against-source: yes
---

A new "raise so the job retries" path needs its retry policy specified and tested, not assumed.

**What happened:** A background job was changed to raise a new error class so the queue would retry it rather than
skip permanently. Comments claimed it "retries until it can". The job's custom retry-delay hook had no branch for the
new class, so the framework default (minutes total) applied, and the exhaustion hook ignored it, sending the job to the
dead queue. The only spec asserted the first raise. Adversarial review caught it.

**Root cause:** The plan treated "raise → retried" as a property of the framework instead of the job's own retry-delay
and exhaustion hooks, which dispatch on exception class.

**Suggested fix:** When adding a raise-to-retry path: (1) grep the job for its retry-delay and exhaustion hooks and add
a branch for the new class; (2) spec those hooks directly with the new exception (total retry window, exhaustion
outcome); (3) make comments state the real window.
