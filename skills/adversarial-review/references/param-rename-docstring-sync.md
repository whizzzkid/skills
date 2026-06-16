---
class: principle
---

**Rule**

On a parameter/symbol rename, grep the owning class/module docstring for the old name
AND any behavioral phrase it qualified (e.g. "no findings" when the param narrowed to
"blocking findings only"), and sync stale phrasing in the same commit as the rename.

**Why**

A symbol-rename grep checks callers and the signature but not prose. Class docstrings
describe the contract in words, so a stale semantic claim survives the rename and is a
top bot-review flag, costing a follow-up CI cycle.

**Where**

`skills/adversarial-review/SKILL.md` → sweep 2.8.
