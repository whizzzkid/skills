---
class: principle
---

# Footer gate patterns are copied, never retyped

- **Rule:** Run the pre-emit footer gate with its patterns copied verbatim from Step 4, or grep `-F` the variable that
  rendered the footer. For a multi-body payload, gate each extracted body or expect an occurrence count of exactly
  1 + the number of inline comments.
- **Why:** A review-payload footer count used a URL fragment typed from memory that differed from the canonical
  footer; it returned 0 and nearly read as "footer missing" on a correct payload. A gate pattern built from memory
  fails in the false-dirty direction as readily as composed bodies fail in the false-clean one.
- **Where:** [`wk-gh`](../README.md) → Step 4, pre-emit gate; mechanics in `footer-gate-details.md`.
