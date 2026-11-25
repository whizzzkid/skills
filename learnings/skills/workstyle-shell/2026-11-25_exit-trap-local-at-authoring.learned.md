---
skill: wk-workstyle-shell
date: 2026-11-25
type: correction
severity: medium
verified-against-source: yes
---

The EXIT-trap/`local` rule was skipped while writing a new script, so every success path exited non-zero.

**What happened:** A function created a tempfile in a `local` variable and then re-registered the script-level
`trap '... "$var" ...' EXIT`. Under `set -u`, the trap ran after the function returned and aborted with
`var: unbound variable` *after* the success line was printed. The output looked right but the exit status was
non-zero, so every happy-path test failed. Only the bats run caught it.

**Root cause:** The rule "An EXIT trap cannot see a `local` variable" lives in the skill, but nothing applies it at
the moment a trap is written. It reads like a review-time finding, and it also undersells the `set -u` effect: the
trap does more than expand to empty and leak the file. It changes the script's exit status after its output has
already printed.

**Suggested fix:** Add an authoring-time check: whenever a `trap` body names a variable, declare that variable at
script scope (initialised to `""`) before the first function is defined, and have one script-level cleanup function
own every resource. Mention the `set -u` symptom too: output is correct but the exit status is non-zero, because
the unbound error is raised inside the trap.
