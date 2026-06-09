---
class: principle
skill: wk-buildkite
date: 2026-06-09
severity: medium
---

- **Rule:** On `bk build view`, target a specific build with the build number
  as a **positional** argument (`bk build view -p <pipeline> <build-number>`);
  `-b` is `--branch`, not the build number.
- **Why:** Passing a build number to `-b` resolves to `null`, which breaks any
  downstream `jq` pipe with "Invalid numeric literal".
- **Where:** Canonical Build Query note + Tool Selection + Specific Build
  section. Note the overload: on `bk job log`, `-b` / `--build-number` *is*
  the build number — verified via `bk <subcmd> --help`.
