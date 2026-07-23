---
class: principle
---

**Rule:** When a diff BOTH documents an authoring rule for an artifact class
("authors should include/omit/set field X") AND adds or edits an
example/fixture/template of that same class, grep the added fixture against the
rule the same PR just wrote. Confirm the fixture obeys its own PR's documented
guidance (field present when "include", absent when "omit").

**Why:** The prose-vs-code sweeps check docs against implementation but not the
PR's own newly-added sample artifacts against the rule the same PR introduced. A
PR documented "omit field X" while its own example fixture carried field X; the
review bot caught the self-contradiction, the adversarial sweep did not. This is
intra-PR guidance-vs-fixture consistency, distinct from prose-vs-code.

**Where:** Mechanical sweep 2.86 in `references/sweep-catalog-extended.md`; ID
added to the lower-frequency-sweeps list in SKILL.md.
