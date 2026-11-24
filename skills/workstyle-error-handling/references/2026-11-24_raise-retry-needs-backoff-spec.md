---
class: principle
---

# A raise-to-retry path is specified by its class-dispatching hooks

**Rule** — When code raises a new exception class so a downstream mechanism handles it (job retry, requeue,
dead-letter, error mapping), treat the outcome as defined by the code's own hooks that branch on exception class, not
by the framework default:

1. Grep the enclosing class and its ancestors for every class-dispatching hook (retry-delay/backoff,
   retries-exhausted, rescue/error-mapping handlers) and add an explicit branch for the new class.
2. Spec each hook directly with the new class — total retry window and exhaustion outcome — not only the raise.
3. Make comments state the window and terminal outcome those hooks produce.

**Why** — A job's custom retry-delay hook had no branch for the new class, so the framework default (a window of
minutes) applied, and the exhaustion hook ignored the class, sending the job to the dead queue. Comments claimed it
"retries until it can"; the only spec asserted the first raise, so it stayed green. The plan treated "raise → retried"
as a framework property when the job's own hooks decided it. Caught by adversarial review, not by tests.

**Where** — `SKILL.md` → Rules (fires on any edit that writes a raise/throw). The reporter tagged the general
workflow skill; ownership moved here because this skill is the one auto-invoked at the moment the raise is written,
and the workflow body has no byte headroom for a duplicate.
