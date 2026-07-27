---
skill: wk-workstyle-shell
date: 2026-07-25
type: gap
severity: medium
verified-against-source: yes
---

The zsh-portability rule is scoped to "documented snippets", so it did not fire on an ad-hoc agent command that hit the same trap.

**What happened:** While running the overfit scan for an unrelated fold, the agent
built a file list as `FILES="a b c"` and ran `grep -nE '<pat>' $FILES`. Under zsh
the unquoted parameter expansion did not word-split, so grep received all four
paths as a single filename and returned `rc=2` with `No such file or directory`.
Had the check been written to branch on `rc != 0` alone, that would have read as
"scan clean" — a false negative on a scan whose entire purpose is catching
overfit tokens before they ship.

**Root cause:** The trap is already documented in this skill, but the owning rule
opens "Keep any snippet **a skill documents for the agent to run** portable to
zsh". That scoping is what let it be read past: the failing command was not a
documented snippet, it was a one-off Bash call the agent composed in the moment.
Verified by re-running the same command with explicit positional args, which
resolved all four paths correctly. The rule's mechanics are right; its stated
domain is narrower than the domain where the mechanism actually bites.

**Suggested fix:** Widen the rule's opening scope from snippets a skill documents
to **any** shell command the agent composes, documented or ad-hoc — the agent's
shell is zsh either way. Consider pairing it with the existing "positive control
must move the count" rule, since a non-zero rc from a mis-split command is the
same class of unproven verdict.
