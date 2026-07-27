---
class: principle
---

**Rule** — Resolve a skill's on-disk directory by listing candidates and taking the first
that exists (verbatim name before prefix-stripped form), never by a mechanical transform of
the display name.

**Why** — Dir naming is not invariant with a skill's `name:` field: most dirs drop the
leading `wk-`, some retain it. A blind `${SKILL_NAME#wk-}` strip builds a path that never
exists for a prefix-retaining dir, so the consumer takes its not-found branch. In the env
hook that branch is `exit 0` — identical to the legitimate "skill declares no env-vars"
branch — so every declared var goes unchecked with no warning. The failure is invisible
precisely because the two exit-0 paths are indistinguishable from outside.

**Reproduction** — Drive the hook with a fixture tree containing a prefix-retaining dir
that declares an env-var: the hook emits nothing. The same fixture under a prefix-dropping
dir emits the expected warning. Verbatim-first ordering matters when both forms exist.

**Rejected suggestion** — "Separate the two exit-0 branches so an unresolvable skill name
is distinguishable" (i.e. warn on unresolvable). Rejected: the hook fires before *every*
skill invocation, and plugin/third-party skills legitimately ship no dir in this repo, so
an unresolvable name is the common case. Warning on it would emit noise on nearly every
skill call and train the user to ignore the hook. The unresolvable branch stays silent; only
a *resolved* skill is ever checked.

**Where** — wk-env: the shipped `PreToolUse` hook's dir resolution, and the skill body's
documented lookup command. The same discipline is already written as prose in the
distillation skill's "read the full skill" step; this applies it to shell implementations.

**Harness note** — The suite's bats does not run test bodies under `errexit`: a failing
assertion that is not the final command in the body is inert and the test still reports
`ok`. Every assertion must carry an explicit `|| return 1`. Discovered when a
mutation check showed one test passing against a deliberately broken hook.
