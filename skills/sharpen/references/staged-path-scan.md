---
class: principle
---

**Rule** — Scan staged **path strings** against `.skillprohibit` per-file, never as a
bare multi-line list:

```bash
git diff --cached --name-only | grep -iEf .skillprohibit
```

- A stricter `grep` alias false-cleans one bad path inside a multi-line argument.
- A `No such file` warning is a scan failure, not a clean result.
- Treat a hand-rolled `NONE` as **unverified** until the grep is proven to fire: probe it
  with a literal expanded from a real **non-comment, non-blank** denylist line
  (`a[-_]?b` → `a-b`) — never a guess, and never a comment line, which is itself a valid
  regex matching its own text, so the probe "fires" while proving nothing.

**Why** — Content hooks grep the diff and the commit message, never filenames, so a
prohibited term living in a slug or filename ships clean. Pick a generic slug for a
prohibited-subject lesson up front; never derive it from the subject. Scrub staged
`.learned.md` / retro archives too — a rename commits them publicly, and a
term-handling learning's example IS the term.

**Where** — wk-sharpen Step 5, mechanical overfit scan, after the owning hooks run.
