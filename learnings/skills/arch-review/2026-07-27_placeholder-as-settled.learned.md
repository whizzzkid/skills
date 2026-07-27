---
skill: wk-arch-review
date: 2026-07-27
type: gap
severity: high
verified-against-source: n/a
---

A provisional value was promoted into a "resolved / pin exactly" section, and every consistency check still passed.

**What happened:** A document set carried two tables — settled values, and values explicitly
marked pending a later work item. A guessed browser-floor pair (a build `target` string) was
written into the settled table under a "pin exactly" heading while the item that resolves it was
still open. The plan's own assertion (manifest floor equals the exported `SUPPORTED` constant)
compared the guess against itself and passed green, so nothing surfaced the error. Shipped, it
would have excluded a large installed base of one browser.

**Root cause:** The review lenses check internal consistency and unstated assumptions, but nothing
forbids a settled-values section from absorbing a value that is still a placeholder elsewhere in
the same document set. A wrong-but-internally-consistent pair is invisible to every consistency
assertion, because both sides of the assertion trace back to the same guess.

**Suggested fix:** Add a check to Lens C (Underlying Assumptions): for every value in a section
headed "settled", "resolved", or "pin exactly", grep the rest of the document set for the same
value or concept marked pending/TBD/unresolved. Any hit is a finding — leave the cell explicitly
unresolved and name the item that resolves it. Additionally, require derived values to be stated
as derivations (read from the exported constant) rather than restated as literals, so a single
literal cannot be self-consistent with a copy of itself.
