---
class: principle
---

# Record an invariant where it is enforced, not only in an ADR

**Rule** — When a decision constrains a specific list, config key, or build input,
state the invariant as a short note beside that thing — in the file an agent edits
to violate it, or the repo's agent-instructions file — and let the ADR carry the
reasoning. Note plus pointer only; never duplicate the rationale.

**Why** — An ADR explains *why*, but it is not on the path of the next edit. An
agent about to re-add an excluded entry to a source list opens the list, not
`docs/adr/`. Placing the constraint at the constrained site puts it in front of
the only reader who can still break it. The reasoning stays in the ADR because a
bare prohibition with no recorded grounds can never be safely retired — the same
failure mode as an unexplained rejection note.

**Where** — `skills/docs/SKILL.md` → Step 1, after the config-schema spec rule,
since both concern where a change's documentation obligation actually lands.

## Provenance and routing

- Source: a "What worked" retrospect bullet, so no escalation applies.
- Filed against the workflow skill but folded into the docs skill: the workflow
  skill's ADR rule already delegates documentation placement to `wk-docs`, and its
  own body is within ~175 B of the size ceiling while `wk-docs` had ample room.
  Placement follows ownership, not the filing label.
- The same retrospect's two corrective lessons (subtractive-first; branch
  follow-ups from `origin/<default>`) were **already covered** — both landed
  2026-08-13 with reference files, so this pass only archived the retrospect.
