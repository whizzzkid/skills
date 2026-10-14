---
skill: wk-sitrep
date: 2026-10-14
type: gap
severity: medium
verified-against-source: n/a
---

A stale prior page plus unavailable evidence connectors blocks `start` entirely; the user must be able to waive both.

**What happened:** `start` aborted because the rollover `end` roster needed a connector the user had no permission for, and another connector was unauthenticated. The user waived the first for all runs, declared the stale page closed, and later waived the second for the run.

**Root cause:** The required-connector rule has no persistent waiver list and no way to mark a stale page as closed without running `end`, so any permanent access gap deadlocks every `start`.

**Suggested fix:** Support a per-project waived-connectors config consulted when deriving the required set, and let a user-confirmed "treat as closed" skip rollover. Both waivers must be echoed in the page's sweep notes.
