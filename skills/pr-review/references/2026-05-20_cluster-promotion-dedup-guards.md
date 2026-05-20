---
name: cluster-promotion-dedup-guards
description: Audit dedup guards in promotion/canonicalization algorithms — anchor vs representative mismatch.
class: principle
---

- **Rule:** When the diff includes a promotion / canonicalization /
  clustering algorithm that selects a representative from a cluster,
  check whether the dedup guard tests the iteration anchor or the
  chosen representative. Reverse-iterate the entries in a playground
  to expose mismatches.
- **Why:** A guard on the anchor passes while the chosen
  representative overlaps with an existing canonical, producing
  silent duplicates in the output set. Forward-iteration tests
  miss this — the bug only surfaces when anchor and representative
  diverge.
- **Where:** Phase 4 Playground, new "Cluster-promotion dedup
  guards" section immediately before "Interface contract violations".
