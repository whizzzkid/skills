---
name: cross-module-filter-parity
description: Metrics counting another module's artifacts must mirror the producer's filter.
class: principle
---

- **Rule:** Any metric, counter, or summary that purports to count
  artifacts produced by another module must apply the same filter as
  the producer. Grep the producer for its filter and compare.
- **Why:** When a metric is extracted or refactored, copying the
  filter without consulting the producer silently splits the
  definition across modules — drift between them overcounts or
  undercounts forever, undetected by unit tests.
- **Where:** Sweep 2.8 (Cross-doc enumeration sync), "Cross-module
  filter parity" paragraph.
