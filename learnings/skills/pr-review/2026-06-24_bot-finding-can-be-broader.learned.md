---
skill: wk-pr-review
date: 2026-06-24
type: pattern
severity: medium
---

A bot finding's severity can be an *under*-estimate; validation must check whether the real impact is broader, not only whether the claim reproduces.

**What happened:** A bot flagged "three error variants missing from `all_variants()`" as a test-coverage Minor/Major. Validation confirmed it — but reading the variants showed each referenced a docs file (`<name>.md`) that did not exist on disk, so the user-facing help URLs would 404. The doc-existence test could not catch it precisely *because* those variants were absent from the enumeration. The true impact was broken user-facing links, not just a coverage gap.

**Root cause:** The skill's bot-validation guidance emphasizes downgrading over-stated findings (verify trigger wiring, Confirmed-but-narrower) but has no symmetric prompt to check whether a confirmed finding is *broader* than the bot framed it.

**Suggested fix:** When validating a confirmed bot finding, also trace one hop downstream for amplified impact (e.g. a referenced file/URL/symbol that doesn't resolve, a value that reaches a user-facing surface). If impact exceeds the bot's framing, that is "new evidence" justifying a body anchor — cross-check referenced doc/URL targets against the filesystem rather than trusting that an enumeration test already covers them.
