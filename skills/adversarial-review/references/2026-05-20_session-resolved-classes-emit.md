---
name: session-resolved-classes-emit
description: Verdict emits a session_resolved_classes set so callers can match bot echoes by class.
class: principle
---

- **Rule:** On a clear verdict where the session addressed any
  findings, emit `session_resolved_classes` — one entry per fix,
  keyed by `(path_prefix, concern_class)`. Callers match incoming
  bot threads against this set by concern class first, tagging
  matches as `already-addressed` and skipping triage.
- **Why:** Review bots that re-evaluate from a stale post-push
  snapshot echo every prior finding as a new thread. Without a
  class-level matcher, the resolve loop re-enters triage for the
  full echo batch on every push.
- **Where:** Step 5 verdict, "Note bot reviewers in the verdict"
  block, new bullet.
