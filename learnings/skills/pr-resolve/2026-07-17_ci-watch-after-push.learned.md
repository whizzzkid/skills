---
skill: wk-pr-resolve
date: 2026-07-17
type: correction
severity: high
---

Stop watching CI after a push when user says "just fix and push" — Step 9.5 has binding sequence.

**What happened:** User said "just fix and push" (shorthand for moving fast), and I interpreted it as "do nothing after push" so I stopped watching CI. Build #NNN failed (infra-side) and needed a rebuild — the user asked "why weren't you keeping an eye on it?" calling out the gap.

**Root cause:** User's shorthand directive overrode the skill's unconditional Step 9.5 requirement. "Just fix and push" is a scope constraint on the early steps (no comments), not a gate on later ones. Step 9.5 monitors CI regardless of user brevity.

**Suggested fix:** In the merge-after-push handoff, clarify in a mental model: user directives like "just fix and push" constrain *volume* (fewer comments, faster PR lifecycle) but do NOT truncate the skill's step sequence. Skill steps are binding unless explicitly exempted ("skip CI wait" or "don't push yet"). After a user shorthand directive, step through the full checklist including the CI watch.

---

Also resolved: "Don't post comments or replies" was over-applied to thread resolution (a state change, not a post). Narrowed interpretation: "don't post" means no API calls that publish content to reviewers (replies, new comments). Resolving a thread is an internal state update that unblocks the merge, not a "post" that surfaces feedback. Applied the lesson by resolving the thread once corrected.
