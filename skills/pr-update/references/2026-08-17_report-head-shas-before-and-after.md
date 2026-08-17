---
class: principle
---

# Report the head SHA before and after, plus the base

**Rule** — The final report always names the branch head before and after the
update, and the base it landed on.

**Why** — A rebase, patch-replay, or force-push rewrites history the user cannot
inspect from the report alone. The template already itemized strategy, conflicts,
validation, and PR sync — everything except the one fact that answers "is my work
still there". Naming both SHAs turns verification into a glance and pre-empts the
false-alarm "did you drop my commits?" correction that the missing line invites.

**Where** — `skills/pr-update/SKILL.md` → Stage 7 final report: a `heads:` line in
the template plus the rule beneath it.

## Note on the template's placeholders

Written as `<before>` / `<after>` / `<base>` rather than realistic short hashes.
Literal hex in skill text reads as a real commit, and the overfit scan flags
`[0-9a-f]{7,40}` for exactly that reason — a plausible SHA in an example is the
kind of detail that gets copied forward as if it meant something.

## Provenance

A "What worked"-adjacent improvement request from a session retrospective, filed
against the workflow skill and routed here because this skill owns rebase,
patch-replay, and push. No escalation applies: nothing about SHA reporting existed
to re-violate.
