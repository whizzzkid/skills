---
skill: wk-adversarial-review
date: 2026-06-17
type: pattern
severity: high
---

Seed/sync step and write-back must be gated by the same success flag.

**What happened:** A PR added a `seed_state_from_remote` step to fetch remote state before the sweep ran. The fetch was gated: if `git fetch` failed, seeding was skipped and a warning emitted. However, `write_back!` was not gated — it still ran on fetch failure using the stale local baseline, opening a PR that clobbered the remote state the seed was intended to protect.

**Root cause:** The seed's guard (fetch success) and the write-back's guard (`state != before`) were independent conditions. A failed fetch meant the `before` baseline came from the stale local checkout, making any state change trigger a write-back from a stale baseline — the exact scenario the seed was added to prevent.

**Suggested fix:** Add a sweep to the adversarial review catalog: when a diff adds a seed/sync/fetch step that gates a baseline read, grep the same method for whether the write-back (or any downstream mutation) is also gated on that same success flag. A seed that only blocks itself — not the downstream write — leaves the clobber window open.
