---
class: principle
skill: wk-workstyle-shell
date: 2026-07-27
severity: high
---

**Rule** — A fallback attached to a scan carries a *verdict*, and non-zero is at least two
verdicts: rc=1 is "read the input, matched nothing", rc>=2 is "never read the input".
`scan || echo NONE` collapses them onto the clean branch, so an unreadable input is
indistinguishable from a clean one. Discriminate all three statuses and treat rc>=2 as an
aborting scan failure. Capture the status with `rc=0; cmd || rc=$?` — never `cmd; rc=$?`,
which `errexit` kills before the assignment runs.

**Why** — On a prohibited-content gate the false-clean is what ships the prohibited
content. Only stderr separates the two verdicts, and a scan whose stderr is redirected
keeps no signal at all. This is the verdict-level twin of the value-level trap already
catalogued (`grep -c` writing `0` *and* returning rc=1, so `|| echo 0` appends): there the
fallback yields a wrong number, here a wrong conclusion.

**Composed with** — the zsh no-word-splitting trap. A file list built in a shell variable
and passed unquoted arrives as one argument, grep opens nothing, rc=2 — and the fallback
prints clean. Either defect alone is sufficient; together the scan reports clean without
examining a file.

**Escalation — one notch, rung 2 (`**Important:**`) → rung 3 (`**Very important:**`)** on
the word-splitting trap. Justified: re-violated **after** the framing fix (any position,
not just `for`) shipped — verified installed-vs-worktree identical, and the prior fold's
own note predicted volume alone would not prevent recurrence. The shape fix this pass adds
is the load-bearing half: forbid materializing the list at all (pipe the producer into the
loop) rather than prescribing safe handling of a variable that need not exist.

**Rejected** — the report's `cmd; rc=$?` capture form. It contradicts this skill's
`errexit` rule; under `set -e` the script dies before `rc` is assigned.

**Where** — Rules list: zsh-portability trap family, first trap (escalation + shape fix);
`|| echo <default>` bullet, nested verdict-level twin. Also corrected the warning-text
discriminator in the wk-sharpen staged-path-scan reference, which read a `No such file`
warning as the failure signal.
