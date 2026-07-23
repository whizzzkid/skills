---
skill: wk-adversarial-review
date: 2026-07-23
type: gap
severity: high
---

Recompute embedded checksums against the base branch's current algorithm before clearing a hash-backfill PR.

**What happened:** A PR backfilled precomputed `content_hash` values into 36 files. File-count and uniformity sweeps passed cleanly, but the hashing algorithm lived in already-merged base code that had been hardened *after* the values were computed (CRLF normalization + top-level-only key exclusion). Stale hashes would silently pass every mechanical sweep yet fail the runtime drift guard once enforcement landed.

**Root cause:** The sweep catalog verifies structure (count, shape, uniformity) but never re-derives precomputed data values against the production function. The PR body's "computed by tooling" claim was taken on faith; the tooling and the corpus can drift independently.

**Suggested fix:** When a diff backfills precomputed hashes/checksums/digests into many files, add a check: write a throwaway test that invokes the *base branch's* production hash function over the whole corpus and asserts every embedded value matches (zero mismatches). Do not trust a "computed by tooling" body claim — the algorithm may have hardened since the values were generated. This catches a correctness class that grep/count sweeps structurally cannot.
