---
skill: wk-sharpen
date: 2026-07-27
type: gap
severity: high
verified-against-source: yes
---

A landing check must fail a zero-length needle as a harness defect; tolerating it as a merely
"short" cut is what lets a broken harness report a clean, unanimous pass.

**What happened:** A landing check cut each needle from the target file's own bytes, then
matched it back with `grep -qF`. A separate defect made the cut length resolve empty, so every
needle came out zero-length. `grep -qF -e ""` matches any input, so all 18 items landed OK —
a unanimous green that certified nothing. The run's length guard saw len=0 and treated it as a
short-but-acceptable cut, exactly the allowance the existing rule permits, so it passed the
item through instead of aborting. Only the mutated-needle control exposed the fault, by
returning rc=0 where rc=1 was required.

**Root cause:** The skill's reproduction/landing guidance said only "length-guard both",
leaving the len=0 case to be read as the shortest legal cut rather than an impossible one.
Confirmed by driving the primitives directly: a zero-length pattern makes `grep -qF` return
rc=0 against unrelated text, whereas a real needle returns rc=1. A zero-length needle is the
one cut that *cannot* fail, so admitting it under a "short cut" allowance converts the check
into an unconditional pass. The guard's weak wording is therefore not incidental to the
failure — it is the mechanism the defect travelled through.

**Suggested fix:** Amend the length-guard rule in place so len 0 is rejected outright as a
defect rather than tagged short. Amending the existing bullet is preferable to appending a new
one: the weaker wording is what the defect exploited, and the skill body sits close to its size
ceiling, so an in-place sharpening both fixes the rule and keeps the byte cost minimal.
