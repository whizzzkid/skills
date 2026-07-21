---
class: principle
---

# Magic-number stride reading pipelined/batched results (sweep 2.79)

**Rule** — Flag any loop that reads pipelined/batched/paginated/chunked results
via `index * <literal>` positional arithmetic where the stride literal is not a
named constant tied to the emit loop's per-item command count. Bind the stride to
a constant derived from the emit loop and add a DIRECT unit test of the index
math. When the helper also lacks direct coverage (only transitive), call out both
findings together — they correlate. (Sweep 2.79.)

**Why** — The stride and the emit count are two encodings of one number; adding
or removing a pipelined command silently misaligns every read. A helper exercised
only through higher-level specs (which assert final shape, not indexing) looks
tested from the outside, so presence-of-test sweeps pass while the indexing math
is never independently exercised.

**Where** — `wk-adversarial-review` sweep catalog →
`references/sweep-catalog-extended.md` row 2.79.
