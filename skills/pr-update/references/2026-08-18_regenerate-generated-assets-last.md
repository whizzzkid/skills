---
class: principle
date: 2026-08-18
severity: medium
escalation: rung 1 → 2 (`**Important:**`)
---

# Generated output is regenerated once, last

**Rule** — Any build/generate output in a conflict (schema dumps, digest manifests,
captured screenshots, lockfiles) is regenerated from source and verified, never
side-picked or textually resolved. Regenerate **once, last**: resolve either way to
clear the conflict, mark the path, and run the generate command only after every other
conflict resolution and source fix has landed, as the final commit before push.

**Why** — A derived artifact is a function of the whole source tree, so any later source
commit — a formatting fix, a doc edit — re-invalidates it. Regenerating eagerly at
resolution time therefore guarantees one regenerate-commit-invalidate cycle per
subsequent source fix; a field report saw the same manifest digest conflict three times
in one session for exactly this reason. Ordering, not detection, is the missing half:
the pre-existing rule already said "regenerate from source", but said nothing about
*when*, so a compliant agent still churned.

**Escalation** — the pre-existing bullet ("For auto-generated files (schema dumps like
`schema.rb`, `*.lock`), regenerate from source …") landed before the report and did not
steer the run, so the repeat is a genuine re-violation → escalated one rung to
`**Important:**`. The repeat traced to the rule's *shape*, so the framing fix is
load-bearing and the notch only records it: the example list read as scoped to schema
dumps and lockfiles, excluding the digest manifests and screenshots that actually
failed, and the rule carried no idempotence/ordering dimension at all. Both are now
fixed in the rule text.

**Same-pass reclaim** — headroom was 353 B against a 193 B net addition, so four
audit-cleanup targets were priced first (combined NET 234 B): the lockfile bullet's
regeneration clause (now stated generally one bullet above, real-install authority
preserved), and explanatory filler in the patch-replay cost note, the Stage 5 abort
note, and the Stage 7 head-naming rule. Net body **−41 B** (24223 → 24182).

**Where** — `SKILL.md` → Stage 4 (Conflict resolution loop), the auto-generated-file
bullet above "For each conflicted file".
