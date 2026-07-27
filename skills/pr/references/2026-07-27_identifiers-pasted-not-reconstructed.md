---
class: principle
skill: wk-pr
date: 2026-07-27
severity: high
---

**Rule** — Every identifier written into a PR body — run id, SHA, count, artifact
URL — is pasted from the output of a command executed in the same turn, never
reconstructed from surrounding context. A ticked checkbox is a claim, and a link
inside it is an identifier, so the rule binds the body-sync step as much as prose.

**Why** — Re-checking a CI checkbox after a force-push, a plausible-looking numeric
run id was written into the PR body without any command having been run; the link
pointed at a run that does not exist. It was self-caught one step later when
`gh pr checks` and `gh run list --branch <branch> --json databaseId,headSha,
conclusion` returned a different, real id.

The root cause is where the rule was missing, not that it was unknown: the
body-sync step treats a checkbox update as *prose*, so the run id was
reconstructed like the rest of the sentence. Nothing in the step required an
identifier to come from a command run in the same turn. The failure mode is a
*plausible* value rather than a malformed one — the surrounding sentence stays
wholly true while the identifier names nothing — so nothing in its shape prompts a
check.

**Placement** — folded as an extension of Hard Rule 4 (*derive behavioral claims
from the implementation, never narrate from intent*) rather than as a new numbered
rule: same family, with a command substituted for the source file as the authority.
A pointer was added at the Step 5 checkbox-sync HARD RULE, since the learning
identifies that step — not the review skills that already carry sibling rules
(`wk-self-review`'s never-fabricate-a-quantitative-claim) — as the surface where
invented identifiers get in.

**Where** — `wk-pr` → Hard Rule 4 (identifier clause + `gh run list` recipe); Step 5
checkbox-sync HARD RULE (cross-reference).
