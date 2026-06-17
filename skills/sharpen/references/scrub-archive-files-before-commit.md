---
class: principle
---

**Rule**

Run the prohibited-term/overfit scrub on staged learning and retrospect archive
files too — not only the SKILL.md edits and reference files.

**Why**

A `.learned.md` rename commits the archive into the public repo; an internal
tool/project/service/org name there blocks the commit at the prohibited-term hook,
after the skill edits already passed their scan.

**Where**

`skills/sharpen/SKILL.md` → Step 5 (Mechanical overfit scan).
