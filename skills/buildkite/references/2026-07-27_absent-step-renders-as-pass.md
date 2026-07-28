---
class: principle
---

**Rule** — Before reporting any *named* check's outcome, confirm a matching job exists in
the build's job list. An empty match is a **finding** ("that check does not run here"),
never a pass. Count the matches, guarding the name:

```bash
jq -r --arg s '<step-name>' '[.jobs[] | select(.name // "" | test($s))] | length'
```

- Count `0` → grep the repo for the tool's wiring (pipeline definition, CI workflow dir,
  setup TODO) and report an **unwired gate**. A config file present in the repo is not
  wiring; something must invoke it.

**Why** — The pre-existing per-job rule corrects a rollup that *collapses* many jobs into
one entry, but it still assumes the job exists and frames the task as reading its state.
The absent-step case fails one level earlier: every job in the build is `passed`/exit 0
precisely *because* the check was never wired in, so both the rollup and the build state
read fully green. Absence of evidence renders identically to a pass.

The `// ""` guard is load-bearing, not cosmetic: a null-named job (waiter/block steps)
aborts `test()` with jq **rc=5 and no stdout**, which a presence probe reads as zero. The
failure is **open** — indistinguishable from a real absence, and it would fire exactly
when the probe is being trusted. Verified by driving both forms over a fixture holding a
null-named job: unguarded aborted at rc=5, guarded returned the true count. The same gap
existed in the pre-existing per-job snippet and was corrected in the same pass.

**Where** — `SKILL.md` → *Checking Build Status*; Quick Reference row "Did check X pass?".
