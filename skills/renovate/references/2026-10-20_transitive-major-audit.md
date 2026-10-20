---
class: principle
source: learnings/skills/renovate/2026-10-20_transitive-major-audit.learned.md
date: 2026-10-20
skill: wk-renovate
---

**Rule** — Diff every lockfile against base and audit each major-version change, direct or transitive, against the
app's usage before calling a combined update safe. Any major bump forces the adversarial review that Step 6 would
otherwise skip for dependency-only diffs.

**Why** — A grouped patch bump can pull a transitive major that no PR title names. The suite stays green when the
broken path is untested; only reading the upstream changelog or source surfaces the regression. Step 1's table and the
old Step 6 skip rule both saw only direct bumps, so the major went unreviewed.

**Where** — `SKILL.md` → Step 4 (HARD RULE: audit every major bump) and Step 6 (adversarial-review gate); PR body
template → major-bump audit section.
