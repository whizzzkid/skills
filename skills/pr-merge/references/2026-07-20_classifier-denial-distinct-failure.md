---
class: principle
---

**Rule** — Treat a host permission-classifier denial of `gh pr merge` ("Blocked by
classifier") as a failure mode distinct from a branch-protection / non-zero merge
error. On denial: do not retry verbatim, do not fall back to another merge method;
explain the two-layer model (skill allowlist vs. host classifier) and that an
explicit `Bash(gh pr merge:*)` settings.json rule — or a manual user merge — is
required. A manual/past-tense merge after denial is the already-`MERGED` resume path.

**Why** — The host layer blocks irreversible actions independent of the invoking
skill's own tool allowlist, so a different merge method is denied identically and a
verbatim retry loops. The skill previously assumed merge failure meant branch
protection and fell back on method, which never clears a classifier block. Listing
the command in the skill's `allowed-tools` cannot fix it (redundant with bare `Bash`
for the allowlist, powerless against the classifier).

**Where** — `skills/pr-merge/SKILL.md` Step 6 (Merge PR), failure-handling bullets;
resume path lands on Step 1 already-`MERGED` → Step 7.
