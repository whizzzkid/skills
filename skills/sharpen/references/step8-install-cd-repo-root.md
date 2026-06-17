---
class: principle
---

**Rule**

Prefix the Step 8 install (and any `.`-relative command) with an explicit `cd
"$WK_SKILLS_HOME"` (or an absolute path).

**Why**

The Bash tool's cwd persists across calls, so a `cd` from an earlier rename/scan
step leaves a `.`-relative install resolving in the wrong directory — `npx skills
add .` then prints "No valid skills found".

**Where**

`skills/sharpen/SKILL.md` → Step 8 (Verify and Commit).
