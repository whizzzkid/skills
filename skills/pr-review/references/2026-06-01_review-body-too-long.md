---
skill: wk-pr-review
date: 2026-06-01
class: principle
type: correction
severity: medium
---

# Review body mirrors the author's style — one line on LGTM

- **Rule:** When the verdict is LGTM with no blockers, the review body is
  one line max (`LGTM 🚀` or equivalent) plus the footer. Investigation
  rationale (mutation results, contract checks, return-type verification)
  stays in TERMINAL output for the reviewer running the skill — never in
  the GitHub body. The body is for the author; the terminal summary is for
  the reviewer. The "what's strong / too-large / structural concerns"
  include-list applies only when the author must act on something, not to a
  clean LGTM.
- **Why:** The skill said "concise impression" but paired it with an
  include-list, pulling every LGTM toward a verbose justification. An agent
  wrote a multi-paragraph body narrating what it verified; the user
  stripped it to `LGTM 🚀` + footer. A clean approval needs no
  justification.
- **Where:** Phase 6 "Compose the review body" — body-vs-terminal split in
  the lead paragraph; HARD RULE one-line-LGTM bullet replacing the
  "Clean, focused PR" bullet; scope note limiting the include-list to
  actionable cases.
