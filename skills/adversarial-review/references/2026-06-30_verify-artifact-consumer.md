---
class: principle
---

**Rule:** When a diff edits, removes, or maintains an enumeration/list/config
artifact (doc, prompt, manifest) that reads like a source of truth, grep the
whole repo for the artifact's filename and the values it lists to find the real
runtime consumer. If nothing reads it at runtime, treat it as drift-prone
documentation, not load-bearing — prefer count-agnostic prose over a
hand-maintained count, and flag the artifact and any generator syncing it as
vestigial duplication.

**Why:** An artifact that reads like the orchestrator/source-of-truth invites
machinery to keep it accurate even when the compiled consumer discovers the same
data at runtime and never reads the file. A `grep` of the source for the
filename returning zero hits proves the consumer is code, not the doc. A
maintained count with no enforcing consumer silently drifts (listed N while M
existed) and is a future drift blocker.

**Where:** Sweep catalog row 2.60 (extended catalog). Complements 2.59
(generator-as-source-of-truth must update every consumer) from the inverse
angle: a maintained list with no consumer at all.
