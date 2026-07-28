---
skill: wk-workflow
date: 2026-07-27
type: correction
severity: high
verified-against-source: yes
---

Marketing/docs copy asserted a product capability the system does not have; grounding audits checked cited numbers but never the capability claims.

**What happened:** A blog draft's title, subtitle, thesis, and build-vs-buy
differentiator all claimed the tool "runs your change" in a "CI-like sandbox."
The agent ran a full grounding audit against internal reference docs, verified
every statistic, added rigor caveats — and still shipped the false capability
claim, because the audit only checked claims that had a citable number attached.
The system is read-only: its execution environment exposes read/glob/grep and no
shell. The user caught it, not the audit. A separate instance of the same failure:
while regenerating a doc from the source markdown, the agent invented a
"design commitment" bullet restating the same false capability, which existed in
no source file.

**Root cause:** Grounding was scoped to verifiable *figures* (rates, counts,
costs) rather than *capability verbs*. A claim like "runs your change" has no
number to check, so it passed unexamined while `67%` got three caveats. Nothing
in the workflow required tracing a stated capability to the code path that
implements it. Confirmed by reading the check-authoring contract, which states
the execution environment provides read/glob/grep only and no shell access, and
the clone helper, which does a `--depth 1` clone and nothing more.

**Suggested fix:** In any doc/marketing/PR-body accuracy pass, extract the
**capability verbs** (runs, executes, validates, enforces, blocks, prevents,
learns, remembers) — not just the numbers — and require each to name the file or
symbol that implements it, or be downgraded to roadmap language. Treat the title
and one-line summary as the highest-risk claims, since they compress hardest and
are the least likely to carry a citation. Also: when regenerating an artifact
from a source file, never add substantive claims absent from the source — a
regeneration is a transform, not a rewrite, and invented content bypasses every
grounding check the source already passed.
