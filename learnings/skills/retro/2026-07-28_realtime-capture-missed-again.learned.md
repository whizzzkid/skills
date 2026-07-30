---
skill: wk-retro
date: 2026-07-28
type: gap
severity: medium
verified-against-source: n/a
---

Every finding in this session's retro was reconstructed at retro time, not captured when it happened.

**What happened:** Four distinct findings — a repeated-gate fatigue correction from {user}, three self-caught CI defects, and a false universal claim in a plan doc — all landed during the session, and none got a `wk-learn` call in the response that handled them. They were only written at the retro, after a context compaction had already blurred the details.

**Root cause:** The real-time capture rule is stated at the top of the skill, but the skill is only *loaded* at retro time — so during the session nothing is in context to enforce it. The rule lives in the wrong artifact to steer the moment it describes.

**Suggested fix:** Move the real-time capture obligation into the always-loaded workflow skill (or a project-level rule) and have this skill merely verify it happened, reporting how many findings were captured live versus reconstructed. A retro that reconstructs everything is itself a signal worth printing.
