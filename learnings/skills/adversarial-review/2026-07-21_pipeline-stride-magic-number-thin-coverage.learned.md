---
skill: wk-adversarial-review
date: 2026-07-21
type: gap
severity: low
---

A batch-read helper that pipelines a fixed number of commands per item is a common home for a magic-number stride bug, and it correlates with missing direct unit coverage.

**What happened:** A generalized Redis-pipeline batch-read helper (emits N commands per key in a loop, then reads results back with `index * N` positional math) had zero direct unit test — it was only exercised transitively through higher-level request specs, which assert on the final shape, not the pipeline indexing itself. The bot reviewer, not the human review pass, caught that the stride (`N`) was a bare literal disconnected from the emit loop's actual command count, so adding/removing a pipelined command would silently misalign every read.

**Root cause:** Sweeps that check "is this tested" (2.15/2.19a-style) verify presence of *some* test, but a transitively-covered helper looks tested from the outside while its internal indexing math (emit-count vs. read-stride coupling) is never independently exercised. The magic-number-stride pattern (`i * <literal>` reading back a pipelined/paginated/chunked result) is a recurring shape worth its own trigger, not just a generic "add a test" note.

**Suggested fix:** Add an explicit trigger: any loop that reads pipelined/batched results via `index * <literal>` positional arithmetic, where the literal isn't a named constant tied to the emit loop's command count, is a candidate for the same class of bug regardless of test presence elsewhere — flag it directly rather than relying on coverage sweeps to surface it indirectly. When such a helper also lacks a *direct* unit test (not just transitive coverage via a caller), treat the two findings as correlated and call out both together.
