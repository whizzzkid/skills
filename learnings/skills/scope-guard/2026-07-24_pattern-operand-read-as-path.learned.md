---
skill: wk-scope-guard
date: 2026-07-24
type: gap
severity: medium
verified-against-source: yes
---

A path-like literal inside a search command's own *pattern* operand is charged as a search root, false-blocking a fully repo-scoped grep — and the sibling quoted-prose fix does not cover this case.

**What happened:** A scrub check grepped two repo-relative files for forbidden tokens, including
absolute-home path shapes. The pattern operand itself carried those shapes:

```bash
grep -niE '<abs-home-prefix>|<other-abs-prefix>|<name>' <repo-relative-file> <repo-relative-file>
```

The guard blocked it, reporting the home prefix as the out-of-scope path, even though every
*operand that is a path* was repo-relative. Restructuring the same scan to read patterns from a
file (`grep -Ef <patternfile>`) passed, and produced the intended result.

**Root cause:** Path-like tokens are classified by shape, not by argument role. Within a search
command's argv, the pattern operand and the path operands are not distinguished, so a path shape
appearing *as data to match* is indistinguishable from a directory *to search*. This is adjacent to
the known bare-token-in-quoted-prose defect but is not the same case, and the fix proposed there
would not resolve it: that fix exempts quoted tokens only when the enclosing command is **not** a
search command, and attributes tokens to the command they are arguments of. Here the enclosing
command *is* the search command and the literal *is* one of its arguments — so both halves of that
fix leave this blocked.

**Suggested fix:** Classify by argument *role* inside the search command, not just by ownership.
For a search invocation, resolve which argv slots are path operands under that tool's own grammar —
for grep-family tools the first non-flag operand is the pattern and only subsequent operands are
paths, and the pattern operand is absent entirely when `-e` or `-f` supplies it — then scope-check
only the path operands. Do not relax the shape matcher itself; a genuinely out-of-scope search root
must still block, so verify any fix against both this reproduction and a true positive that
searches an absolute system directory.

**Do not work around it with the opt-out.** Setting the guard's bypass to complete a scrub check
voids the check's result, which is exactly the verification the scrub is performing. The correct
workaround while unfixed is to move the patterns into a file and use the read-patterns-from-file
flag, which keeps the path shapes out of argv entirely.
