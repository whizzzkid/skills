---
skill: wk-workstyle-shell
date: 2026-07-25
type: gap
severity: high
verified-against-source: yes
---

A verification guard read `${PIPESTATUS[0]}` under zsh, where the array is never populated, and printed a false pass.

**What happened:** A probe guard captured a pipeline's exit status with
`rc=${PIPESTATUS[0]}` and branched on `[ "${rc:-0}" -eq 0 ]`. The agent's shell
was zsh, which does not populate `PIPESTATUS`, so `rc` expanded empty, the
`:-0` default supplied a success code, and the guard printed `OK` while the
probe's own output on the same screen stated plainly that it had failed. The
false green was taken as the verdict and the run proceeded on it.

**Root cause:** `PIPESTATUS` is a bash-only array; zsh spells it `pipestatus`
(lowercase) and leaves the uppercase name unset. Confirmed by driving both
shells directly: `zsh -c 'true | false; echo ${#PIPESTATUS[@]}'` prints `0`
while `pipestatus` holds `0 1`; the same line under bash prints `2`. The
failure is silent in the worst way — an unset array plus a `:-` default does
not error, does not warn, and exits 0, so a shell-dialect assumption is
laundered into an affirmative verdict rather than a visible break. Same class
as the awk PCRE-escape trap already folded into this skill, but inverted in
consequence: the awk trap yields a false *zero*, this yields a false *pass*.

**Suggested fix:** Extend the existing zsh-portability rule with a third trap:
never read `${PIPESTATUS[…]}` in a snippet that may run under zsh. Capture a
pipeline's status without a pipeline instead — redirect to a file and read
`$?`, or run the command bare — and treat a guard whose verdict contradicts the
output it is summarizing as an indictment of the guard, not of the output.
