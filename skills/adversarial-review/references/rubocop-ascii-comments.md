---
class: principle
---

**Rule**

On a Ruby diff, when `.rubocop.yml` enables `Style/AsciiComments`, grep new `+`
comment lines for non-ASCII characters (`[^\x00-\x7F]` — em-dash, curly quotes,
arrows) and flag as a blocker. Sweep 2.39.

**Why**

Non-ASCII comment characters pass local review but fail CI with
`Style/AsciiComments: Use only ascii symbols in comments`, costing a fix cycle.

**Where**

`skills/adversarial-review/SKILL.md` → sweep 2.39.
