---
skill: wk-grep
date: 2026-07-26
type: surprise
severity: medium
verified-against-source: yes
---

A `grep` pattern that begins with `-` is parsed as options, not as a pattern — and the
half of that failure which stays quiet is the half that corrupts a verdict.

**What happened:** During a landing check, a needle scored MISSING purely because the
phrase being searched for started with a hyphen. The rc was 1 and stderr was empty, so the
result read as a clean "not present" and was briefly acted on. The needle was in fact
present in the file.

**Root cause:** The pattern operand is just `argv[1]`; `grep` applies normal option parsing
to it before treating anything as a pattern. Driven directly against a three-line fixture
whose second line is `-Werror is set here`:

```
grep "-Werror" hay.txt   -> rc=2  stderr: grep: invalid option -- W
grep "--color" hay.txt   -> rc=1  stdout empty, stderr empty
grep "-x"      hay.txt   -> rc=1  stdout empty, stderr empty
grep -e "-Werror" hay.txt -> rc=0  "-Werror is set here"
grep -- "-Werror" hay.txt -> rc=0  "-Werror is set here"
grep "beta"    hay.txt   -> rc=0  "beta"          # control: haystack + invocation good
```

**The failure is bimodal, and only one mode is loud:**

- **Unrecognized letter → rc=2, loud.** `-W` is not a grep flag, so it aborts with
  `invalid option -- W`. Annoying but self-diagnosing.
- **Valid option → rc=1, silent.** `--color` and `-x` *are* real grep flags, so they are
  consumed as flags. The next argument — the file path — is then taken as the pattern, and
  with no file operand left `grep` reads **stdin**. Empty stdout, empty stderr, rc=1:
  indistinguishable from a genuine absence. This is the branch that produced the false
  MISSING, since rc=1 (not rc=2) is what a MISSING verdict keys on.

A second consequence of the silent branch: with stdin attached to a terminal, `grep` blocks
waiting for input rather than returning at all.

Not a BSD quirk — this is POSIX option parsing and reproduces on GNU grep identically. It
is also **not** the same trap as the existing "options are not reordered after the first
operand" rule: there, a flag written *after* an operand is demoted to an operand (BSD-only);
here an operand written *before* everything is promoted to a flag (everywhere). That rule's
remedy — "put flags before operands" — is actively wrong-footed by this case, because the
pattern already is before the operand and that is precisely the problem.

**Suggested fix:**

- Bind the pattern explicitly: `grep -e "$pat"`. Works in any argument position.
- `grep -- "$pat"` also works, but `--` demotes *every* later word to an operand, so a
  trailing `-r` or `-n` built into a composed command silently becomes a filename. Prefer
  `-e` when the invocation is assembled programmatically.
- Generalizes to any tool taking a pattern or path operand from a variable whose content is
  not controlled by the caller.
- Interacts with the existing positive-control rule: a control needle that itself begins
  with `-` certifies nothing, and its own rc=1 will be misread as the control failing.
