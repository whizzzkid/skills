---
class: principle
---

**Rule** — In Phase 3.5, alongside the refactor-opportunity scan, audit every removed line/symbol/file in the diff and classify each deletion intentional or accidental. A removed symbol with surviving references, a dropped guard/validation/test with no replacement, or a deleted file something still imports is an accidental drop → restore or migrate it. Deletions collateral to the change's stated goal split into their own commit.

**Why** — Additive review focus lets accidental removals slip through: a refactor that drops a still-called helper, a merge that loses a validation branch, or "cleanup" that deletes a referenced file ships a silent regression. Treating every deletion as a thing to account for — not a style nit — catches the loss before review.

**Where** — Phase 3.5 (Refactor & Deletion-Safety Scan). Complements the adversarial-review refactor-removed sweeps by gating at the pre-review scan.
