---
skill: wk-renovate
date: 2026-11-20
type: gap
severity: high
verified-against-source: yes
---

Dependabot grouped lockfiles can carry unadvertised transitive majors; regenerate scoped and pinned to advertised targets.

**What happened:** A "patches group, 4 updates" bundler PR's lockfile also bumped several transitive gems, among them
a native-library major and three pre-1.0 majors, and added generic `ruby`-platform entries for gems although
`ruby` was absent from PLATFORMS. None appeared in the PR title or body. The skill's Step 4 lockfile-vs-base diff
caught them only after both picks were applied. `bundle lock --conservative --update <named gems>` then overshot to
releases newer than Dependabot's targets.

**Root cause:** Step 3 cherry-picks Dependabot's lockfile wholesale, assuming it changes only the named packages. The
user's confirmation covers only the advertised bumps.

**Suggested fix:** In Step 3, for bundler (and analogous managers): restore the base lockfile, then run a conservative
update scoped to the named packages. Pin each to the exact advertised version (edit the lock line, rerun install to
validate), and diff vs base to confirm that only the named packages and their exact-pinned companions move. Report
any transitive bump Dependabot included that the scoped resolve shows is not required, and leave it for a later run.
Separately: discarding your own unpushed picks via `reset --hard` may be classifier-denied; restoring the lockfile
from base and landing a corrective commit gives the same net diff.
