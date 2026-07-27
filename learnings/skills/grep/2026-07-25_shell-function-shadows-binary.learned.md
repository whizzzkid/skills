---
skill: wk-grep
date: 2026-07-25
type: surprise
severity: high
verified-against-source: yes
---

Bare `grep` can be a shell function routing to a different engine, so a gate-shaped scan silently false-cleans while the same flags under `command grep` match.

**What happened:** During a denylist scan the agent ran
`grep -iEf <pattern-file> <subject>` where the subject contained a term listed
verbatim in the pattern file. It returned **0 matches, rc=1, and empty stderr** —
indistinguishable from a genuine clean result. Re-running the identical flags as
`command grep -iEf <pattern-file> <subject>` returned **1 match, rc=0**.

`type grep` reported an alias; `declare -f grep` additionally revealed a **shell
function** wrapping it. The function inspects its arguments and, for most flag
combinations, re-executes the agent CLI under `ARGV0=ugrep` with
`-G --ignore-files --hidden --exclude-dir=…` prepended — i.e. a different regex
engine with implicit file-filtering options the caller never asked for. Only a
few argument shapes fall through to `command grep`.

The interactive-only alias is a red herring: zsh does not expand aliases in
non-interactive shells, so a bare `grep` in an agent Bash call resolves to the
**function**, not the alias and not the binary.

**Root cause:** Confirmed by driving both forms against the same two files and by
reading the function body. The wrapper's `--ignore-files` and engine substitution
change match semantics for `-f <pattern-file>` input; the divergence surfaces as a
missing match rather than an error, so nothing in the exit status or stderr signals
that a different tool ran. A canary proving "the scan fires" is worthless unless the
canary uses the same invocation form as the scan — a canary run bare while the scan
runs bare still shares the defect, and one run under each form hides it.

**Suggested fix:** For any scan whose **zero result is load-bearing** (denylist,
secret, prohibited-term, staged-path gates):

- Invoke `command grep`, never bare `grep`, to bypass function and alias shadowing.
- Prove the scan with a positive control run in the *same* invocation form, in the
  same command, as the real scan.
- Treat `No such file or directory` and any non-zero rc as **scan failure**, never as
  a clean result.
- Before trusting a hand-rolled matcher at all, prefer running the owning hook or
  script that already implements the gate.
