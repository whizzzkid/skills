---
skill: wk-adversarial-review
date: 2026-06-29
type: pattern
severity: medium
---

Before trusting a doc/list/config artifact's self-description, grep for its actual runtime consumer — it may be vestigial.

**What happened:** A skill-prompt file (`reviewer.md`) carried a generated list that a build-time generator kept "in sync." Review revealed the compiled binary discovered the same data at runtime and never read the file's list — the list (and the generator maintaining it) were pure duplication that silently drifted (listed 27 items while 34 existed).

**Root cause:** The artifact read like the source of truth (it's the "orchestrator" prompt), so prior work added machinery to keep it accurate instead of asking whether anything consumed it. A `grep` of the source for the filename returned zero hits — the consumer was code, not the doc.

**Suggested fix:** Add a sweep step: when a diff edits or removes an enumeration/list/config artifact, grep the whole repo for its filename and the values it lists to identify the real consumer. If nothing reads it at runtime, flag the artifact as documentation (drift-prone, not load-bearing) and prefer count-agnostic prose over maintained counts. A maintained count with no enforcing consumer is a future drift blocker.
