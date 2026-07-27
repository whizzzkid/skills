---
skill: wk-grep
date: 2026-07-27
type: gap
severity: high
verified-against-source: yes
---

`grep … || echo NONE` reports a clean scan when grep never read the files at all — rc=2
(file error) and rc=1 (no match) are different verdicts, and the idiom collapses both.

**What happened:** A pre-commit content scan built its file list in a shell variable and
passed it unquoted:

```bash
PATHS="a.md b.md c.md"
command grep -nE '<pattern>' $PATHS || echo "NONE"
```

Under zsh this printed one `No such file or directory` line naming the entire list as a
single filename, then printed `NONE`. Both the ticket-token scan and the absolute-path scan
reported clean without having examined a single file. Re-running per-file after staging
produced the same clean verdict, so nothing shipped wrong — but only the visible error text
distinguished the real zero from the fake one, and a scan whose stderr is redirected loses
even that.

**Root cause:** Two independent defects compose, and either alone is enough.

- **zsh does not word-split unquoted parameter expansions.** Confirmed directly:
  `V="a b c"; set -- $V; echo $#` prints `3` under bash and `1` under zsh. A list built in a
  variable and passed unquoted therefore arrives as one argument — a filename containing
  spaces — so grep opens nothing. The same line is correct under bash, which is why the
  pattern survives review and why a snippet documented as portable is not.
- **`|| echo NONE` treats every non-zero rc as "no match".** Confirmed directly: grep returns
  rc=1 for no-match and rc=2 for a file error. The idiom maps rc=2 onto the clean branch, so
  an inability to read the input is indistinguishable from a clean input. This is the
  verdict-level sibling of the value-level corruption in
  `2026-07-26_count-fallback-doubles-value.md`: there `||` appends a wrong number, here it
  asserts a wrong conclusion, and a false-clean on a prohibited-content gate is what ships
  the prohibited content.

**Suggested fix:**

- **Never build a scan's file list in a shell variable.** Drive it from the authoritative
  producer through a read loop, one file per iteration, so word-splitting is never involved
  and each file is opened by name:

  ```bash
  git diff --cached --name-only | while IFS= read -r p; do
    command grep -nE '<pattern>' "$p" && echo "  ^^ MATCH in $p"
  done
  ```

- **Never write `scan || echo NONE`.** Branch on the three rc values explicitly, and treat
  rc>=2 as a scan *failure* that aborts, never as a clean result:

  ```bash
  command grep -nE '<pattern>' "$p"; rc=$?
  case $rc in 0) echo MATCH;; 1) : ;; *) echo "SCAN FAILED on $p"; exit 1;; esac
  ```

- **A clean verdict needs proof the scan reached its input.** Pair every zero with a canary
  the pattern is known to match, planted in the same invocation form; a control that fires
  is what separates "found nothing" from "looked at nothing".
