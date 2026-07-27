---
skill: wk-env
date: 2026-07-24
type: gap
severity: medium
verified-against-source: yes
---

The env-check hook resolves a skill's directory with a blind prefix strip, so it silently
no-ops for any skill whose on-disk dir keeps the prefix.

**What happened:** Reading the hook while folding an unrelated learning: it derives the
skill dir as `DIR_NAME="${SKILL_NAME#wk-}"`, builds `$SKILLS_HOME/skills/$DIR_NAME/SKILL.md`,
and `exit 0`s when that file is absent. At least one skill dir in the tree retains the
`wk-` prefix, so for that skill the constructed path never exists, the hook exits silently,
and none of its declared `env-vars:` are ever checked — the diagnostic the hook exists to
provide is skipped with no warning. Not fixed in this pass: it is shipped executable code
outside the queued lesson's scope, and the skill ships no test suite to validate a change.

**Root cause:** Dir naming is not invariant with the `name:` field — most dirs drop the
leading `wk-`, some keep it — so a mechanical transform cannot resolve every skill. The
same discipline is already written down as a rule in the distillation skill ("resolve the
on-disk skill dir by listing, never by transforming the display name"), but the rule lives
in prose for the agent and was never applied to this hook's shell implementation. The
failure is invisible because the not-found branch is also the legitimate
"skill declares no env-vars" branch: both exit 0 quietly.

**Suggested fix:** Resolve the dir by listing rather than transforming — try the name
verbatim first, then the stripped form, and take the first path that exists:

```bash
for cand in "$SKILL_NAME" "${SKILL_NAME#wk-}"; do
  [ -f "$SKILLS_HOME/skills/$cand/SKILL.md" ] && { DIR_NAME="$cand"; break; }
done
```

Separate the two exit-0 branches so an unresolvable skill name is distinguishable from a
skill with nothing declared. Add a test suite covering both dir-naming conventions before
changing the resolution logic, so the fix is verified rather than assumed.
