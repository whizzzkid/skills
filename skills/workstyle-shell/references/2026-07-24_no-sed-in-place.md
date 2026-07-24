---
class: principle
skill: wk-workstyle-shell
date: 2026-07-24
severity: low
---

- **Rule:** Never emit `sed -i` for an in-place edit. Use `perl -pi -e 's{a}{b};' file`
  instead. Reserve `sed` for read-only stream transforms.
- **Why:** GNU and BSD `sed` disagree on whether `-i` takes an argument. On BSD/macOS the
  suffix is mandatory, so the GNU spelling `sed -i 's/a/b/' file` consumes the script as
  the backup suffix and fails. `perl -pi -e` has identical semantics on both platforms,
  needs no platform branch, and its `{}` delimiters avoid escaping slashes in paths.
- **Where:** The GNU-vs-BSD portability cluster in the Rules section, alongside the
  option-reordering rule — the same failure class, where the GNU spelling is silently
  wrong rather than unavailable.
- **Note:** Filed against a `wk-bash` skill that does not exist. Routed here rather than
  bootstrapping one: this skill already owns portability rules for ad-hoc command forms,
  not just script bodies, and one low-severity finding does not meet the two-finding bar
  for creating a new tool skill.
