---
class: principle
source: learnings/skills/renovate/2026-10-23_transitive-downgrade-defaults.learned.md
date: 2026-10-23
skill: wk-renovate
---

**Rule** — Treat a major-version *downgrade* in the lockfile as an audited major, and audit default-behavior changes,
not only API breakage. A reverted safety-relevant default is restored explicitly at each call site, pinned by a spec
that fails against the reverted default first.

**Why** — A package's new major can pin a dependency to its previous major, so the lockfile rolls it back with no PR
naming it. The suite stays green because no test asserts the stricter default (duplicate-key or comment rejection in a
parser); behavior silently loosens. The installed rule said "major version changed" but was framed as "major bump" and
scoped the audit to "changed APIs", so the downgrade read as out of scope and defaults went unread.

**Escalation** — Partial re-violation: the listing clause already covered any major change (installed 2026-10-20,
before the report), so the downgrade clause took one notch (`**Important:**`). The framing fix (heading reworded to
"up or down") is the load-bearing change; the default-behavior audit and explicit-restore bullet are a genuine gap.

**Where** — `SKILL.md` → Step 4 (HARD RULE: audit every major-version change) and Step 6 (adversarial-review gate);
PR body template → major-bump audit section; README Key Rules and flow.
