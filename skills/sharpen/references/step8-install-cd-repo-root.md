---
class: principle
---

**Rule**

Prefix the Step 8 installer (and any `.`-relative command) with an explicit
`cd "$WK_SKILLS_HOME"` (or an absolute path). Target the active runtime and
byte-compare its installed skill files with repository source before accepting
success output.

## Reference-only refresh recovery

- Normal install succeeds but a changed reference is missing/mismatched → read
  `scripts/install-skills.sh`; preserve its package, scope, and agent targets.
- Re-run its `skills add` invocation for the owning skill with
  `--skill <skill-name> --copy`.
- Re-compare `SKILL.md` and every changed reference. Any remaining mismatch
  fails the gate; never commit from the installer banner alone.

**Why**

The Bash tool's cwd persists across calls, so a `cd` from an earlier
rename/scan step leaves a relative installer resolving in the wrong directory.
A generic success marker also proves only that some target received files, not
that the runtime executing the skill received the current bytes.

**Where**

`skills/sharpen/SKILL.md` → Step 8 (Verify and Commit).
