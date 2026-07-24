---
class: principle
skill: wk-learn
date: 2026-07-24
severity: medium
---

- **Rule:** A learning that names a deterministic artifact (hook, script, CI check,
  linter, generator) must declare provenance for its root cause —
  `verified-against-source: <yes | no | n/a>` in the frontmatter, plus an
  `(unverified — inferred from symptom)` mark on the root-cause line when the author
  did not read or drive that artifact. Scan-mode findings default to `no`.
- **Why:** The report template offers one root-cause slot in the declarative voice and
  no place to record that the mechanism is a guess, so an author who only saw a symptom
  writes the guess as fact. The failure compounds because a workaround that works reads
  as evidence for the mechanism it was chosen to avoid — it can succeed for an unrelated
  reason, and "I could not reproduce it another way" is a symptom, not a cause. An
  unmarked guess reaching the distiller either burns a full verification pass per report
  or, if it slips through, drives an edit that routes the skill around a block that was
  never there.
- **Where:** Step 3 — `verified-against-source` added to the template frontmatter, the
  root-cause placeholder carries the unverified mark, and a HARD RULE after the template
  states when each applies. Step S4 sets the scan-mode default.
- **Deliberately not promoted:** the source learning's framing that the key lets the
  distiller "triage which claims need verifying" was **not** folded into `wk-sharpen`.
  That skill already requires source verification unconditionally; treating
  `verified-against-source: yes` as a licence to skip it would relax an existing guard
  and make the check rationalizable by a self-reported field. The key is a producer-side
  honesty signal only — it never shortens the consumer-side verification pass. Recorded
  here so it is not re-proposed.
