---
class: principle
---

# `\s*$` in a `perl -p` substitution eats the newline

**Rule**

- In line-mode perl (`-p`/`-pi`), end a pattern with `[ \t]*$`, never `\s*$` — or add `-l`.
- Diff or re-parse any structured file after a bulk regex edit.

**Why**

- Under `-p`, `$_` includes the trailing `\n`; `\s` matches it, so the replacement drops the newline. A version-bump
  one-liner joined each edited frontmatter line to the next key, corrupting YAML with rc=0 and no warning.
- Reproduced: `s/^(version:\s*)"1"\s*$/$1"2"/` on `version: "1"\nname: x\n` yields `version: "2"name: x`;
  `[ \t]*$`, or the same `\s*$` under `-lpe`, keeps the newline.

**Where**

`skills/workstyle-shell/references/shell-traps.md` → perl Line-Mode Traps (catalog ID listed inline in `SKILL.md`).
