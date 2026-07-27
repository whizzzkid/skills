---
class: principle
---

# `-s` and `-q` decide which grep exit status wins

**Rule**

- `-s` suppresses the error *message* for a missing or unreadable path, never the
  exit status — it removes the only signal separating rc=1 from rc>=2.
- Without `-q`, an unreadable path yields rc=2 even when the pattern matched
  another file in the same invocation.
- With `-q`, a match yields rc=0 even when a path errored — so `grep -sq` over a
  path set reports success whenever anything matched and swallows the failed path.
- Where a path may be absent, prove it exists first or judge the check on its
  output; never on status alone.

**Why**

- The two flags invert the precedence between "matched" and "could not read", so
  the same path set produces opposite verdicts depending on a flag that reads as
  cosmetic noise-suppression.

**Reported mechanism — disproved, do not re-propose**

- The incident reported that `grep -s` over a missing path exits 2 on BSD and 1 on
  GNU, making a status gate invert by machine. Driven directly, both exit 2:
  BSD grep 2.6.0-FreeBSD and GNU grep 3.12 agree on every case tested (missing
  path, unreadable path, and each combined with a matching file, under `-s`, `-q`,
  and `-sq`). The remediation the report suggested is still right; its stated cause
  is not. Never branch on a supposed BSD-vs-GNU exit-status difference here.
- Fixtures held constant: macOS/darwin host, regular files, default locale. The
  varied axes were implementation, flag combination, and file-set composition.

**Where**

- `SKILL.md` → matcher traps → verdict-level fallback bullet.
