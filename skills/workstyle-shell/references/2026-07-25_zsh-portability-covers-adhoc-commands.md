---
class: principle
---

**Rule** — Scope the zsh-portability rule to *every shell command the agent runs*, both a
snippet a skill documents and one composed ad-hoc mid-task. Portability is a property of
the shell the command executes in, never of the context the command was authored in.

**Why** — The rule originally opened "Keep any snippet a skill documents for the agent to
run portable to zsh". The mechanics were right; the stated domain was narrower than the
domain where the mechanism actually bites. An agent hit the `for x in $LIST` /
unquoted-parameter trap on a one-off command it composed in the moment, read the rule's
scope as covering only documented snippets, and passed over it. The failure surfaces as a
plausible *domain* error (`No such file or directory`, `rc=2`) rather than a syntax error,
so a check branching on exit status alone can report a scan as clean when the scan never
ran — a false negative on the very pass meant to catch problems before ship.

An ad-hoc command is in fact the *higher*-risk case: a documented snippet is reviewed when
authored, while a one-off composed mid-task gets no review at all.

**Rejected** — pairing this with a restatement of the "positive control must move the
count" rule, as the source learning suggested. Already covered twice: the same bullet's
opening clause states that the failure is diagnosed as a real result, and the `awk`
zero / all-reject bullet carries the positive-control requirement. A third statement
would be bloat, not coverage.

**Where** — `wk-workstyle-shell` → Rules → zsh-portability bullet. Supersedes the scope
wording recorded in `2026-07-24_documented-snippet-shell-portability.md`.
