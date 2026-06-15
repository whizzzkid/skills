---
class: principle
date: 2026-06-12
---

# Structured return-type changes must propagate to every stored-shape field comment

**Rule:** After a diff introduces or changes a structured return-type
requirement in one section, grep the whole document for every field comment that
stores that return value and verify shape and vocabulary match. Keep one
canonical name per value across all sections.

**Why:** A fix applied at the requirement site (where the shape is stated) but
not at the struct/field-comment site (where the shape is stored) leaves two
canonical names for the same values, so implementers see contradictory shapes.
Cross-file enumeration sweeps miss intra-document field-comment drift.

**Where:** Step 2 Mechanical Sweep Catalog, row 2.35.
