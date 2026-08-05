---
skill: wk-testing-skeleton
date: 2026-08-04
type: correction
severity: high
verified-against-source: yes
---

Permission-gated browser API fixes must test both the grant and the exact invocation signature.

**What happened:** A manifest regression test proved that a privileged namespace was granted, but
the first runtime validation exposed that its method was still modeled as a callback API instead
of returning its native Promise.

**Root cause:** The test seam covered target-specific manifest output without driving the adapter
through a strict fake that enforced the browser API's supported argument count and return shape.

**Suggested fix:** For every permission-gated browser API change, pair the manifest assertion with
an adapter test whose fake rejects unsupported arguments and reproduces the documented return
contract.
