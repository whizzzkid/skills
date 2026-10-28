---
class: one-off
---

# Canonical markup extracted from the prior page

**Scenario** — `start` generated item spans with an inline script that read the checkbox `onclick` handler and the
standup copy-block prefix from the previous live page instead of retyping them; a truncated gather report was
recovered by asking the agent for only the missing sections.

**Symptom** — none; escaped `\#` survived and the render containment check passed first try.

**Fix** — already covered: Stage 4 "Generate spans; never hand-type them" requires the canonical handler and copy-block
markup verbatim from a generator, and Stage 2 "Truncated result" already prescribes re-requesting only the named
sections. Extracting from the prior page is acceptable only when the extracted bytes equal the canonical recipe in
`checkbox-span-handler.md` / `standup-copy-block.md`; the reference files stay the authority.

**Why not promoted** — positive confirmation of existing rules (no escalation). Making the prior page the preferred
source was rejected: a drifted or hand-edited prior page would then propagate its drift into every later page.
