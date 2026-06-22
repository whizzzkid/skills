---
class: principle
---

**Rule** — When sweep 2.20 fires on a changed `env:`/forwarding list that was replaced wholesale (e.g. a CI template ported from a branch), diff the full new list against the `origin/$BASE` version of the same file — not just the diff delta. Any var present in base but absent from the replaced list is a candidate dropped-forwarding regression → re-add or justify.

**Why** — Sweep 2.20 audits net-new env reads vs the forwarding list, but a wholesale file replacement can remove forwarding that existed in base and was never part of the current session's diff delta. A template ported from a branch that predated env additions in base silently drops those vars; downstream scripts/binaries still read them and fail in production (fail-exits, disabled features, missing required values).

**Where** — Sweep 2.20, env-list-deletion substep. Delta-only diff inspection misses base-vs-replacement removals.
