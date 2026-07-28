---
class: principle
---

# Capability verbs need grounding, not just figures

**Rule** — in any doc, README, announcement, or PR-body accuracy pass, extract the
capability verbs (runs, executes, validates, enforces, blocks, prevents, detects,
learns, remembers) alongside the statistics, and require each to name the file or
symbol implementing it. No implementing path → roadmap language or cut. Audit title,
subtitle, and one-line summary first. A regeneration from a source file is a
transform: it adds no claim the source lacks.

**Why** — a grounding audit scoped to citable numbers has no hook for a claim that
carries no number, so a rate collects three rigor caveats while a false statement
about what the system does passes unexamined. The compressed surfaces (title,
subtitle, thesis) are simultaneously the highest-traffic claims and the least likely
to carry a citation, so they fail this way first. A regeneration pass invents
plausible-sounding claims absent from the source, which bypasses every grounding
check the source already passed.

**Where** — `skills/docs/SKILL.md` → *Claim-Grounding Gate*; mirrored as a check-run
trigger in `skills/adversarial-review/SKILL.md` sweep row 2.4.
