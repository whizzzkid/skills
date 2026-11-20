---
class: principle
source: learnings/skills/renovate/2026-11-20_unadvertised-transitive-bumps.learned.md
date: 2026-11-20
skill: wk-renovate
---

**Rule** — Never take a Dependabot lockfile wholesale, on a clean pick or a conflict. Keep the PR's manifest change,
drop its lockfile, re-resolve scoped to the named packages, pin each to its exact advertised version, and diff the
lockfile vs base so only the named packages and the companions their pins require move. Report any transitive bump
Dependabot carried that the scoped resolve does not need, and leave it for a later run.

**Why** — A grouped "patches" PR's lockfile also bumped several transitive packages (a native-library major and three
pre-1.0 majors) and added platform entries for a platform absent from the lockfile's platform list. Neither the title
nor the body named them, so the user's Step 1 confirmation never covered them. Step 4's lockfile-vs-base audit caught
them, but only after both picks were applied. A conservative scoped update alone overshot to releases newer than
Dependabot's targets, so exact pinning is required.

**Classification** — `principle`, new rule. Not an escalation: the Step 4 audit (installed 2026-10-20) fired correctly
in the same session; the gap was Step 3's "conflict-only regenerate" assumption that a clean pick changes only the
named packages.

**Also observed (one-off)** — discarding your own unpushed picks via `reset --hard` can be denied by the permission
classifier; restoring the lockfile from base and landing a corrective commit gives the same net diff.

**Scope note** — Step 1.5 (lone PR) is unchanged: it merges Dependabot's branch as-is and never pushes onto it, and
its Step 4 audit plus adversarial-review gate still cover any unadvertised major.

**Where** — `SKILL.md` → Step 3 (HARD RULE: land only the advertised bumps; cherry-pick loop); README flow and Key
Rules.
