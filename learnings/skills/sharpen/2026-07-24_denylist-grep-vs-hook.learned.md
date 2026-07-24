---
skill: wk-sharpen
date: 2026-07-24
type: gap
severity: medium
---

Hand-rolling a hook's denylist grep produced both a false-clean probe and a
false-noise scan; running the hook scripts themselves against the index was
authoritative, cheap, and validated every gate at once.

**What happened:** Step 5 prescribes two `grep -iEf <denylist>` one-liners plus a
synthetic probe to prove the grep fires. Two failures followed:

1. The probe token was taken with `head -1` of the denylist, which returned the
   file's **comment header**. A comment line in a pattern file is itself a valid
   regex that matches its own text, so the probe "fired" while proving nothing —
   a false-clean result on a safety scan.
2. The second denylist is PCRE with `(?i)` prefixes and comment lines. Fed to
   `grep -iEf`, its `#` comments matched every markdown heading in every staged
   file, so the scan reported hits on `# Title` and `## Section` — noise that
   buries a real hit.

Running each `.githooks/*.sh` directly against the staged index instead passed
all gates, used each hook's own matcher semantics, and surfaced the true result
before the commit attempt.

**Root cause:** The skill treats a hook's config file as a plain list of `grep -E`
patterns. A denylist is not portable across matchers: it may carry comments,
PCRE-only constructs, or inline flags that only the owning script handles
correctly. The probe rule says "copy a token from a real line" but does not
exclude comment/blank lines, which are the lines `head -1` reaches first.

**Suggested fix:** (1) Prefer executing the owning hook script against the index
over reimplementing its grep — run every relevant `.githooks/*.sh` pre-commit as
a batch; a local hook run costs seconds and replaces the failed-commit cycle the
skill currently accepts as the backstop. (2) When a synthetic probe is still
needed, require the token come from a **non-comment, non-blank** pattern line
(skip lines matching `^\s*#` or empty) and state that a self-matching comment
line makes the probe vacuous. (3) Note that a denylist may be PCRE with inline
flags, so `grep -E` is the wrong matcher for it regardless.
