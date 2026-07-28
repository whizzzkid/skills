---
skill: wk-adversarial-review
date: 2026-07-27
type: gap
severity: medium
verified-against-source: yes
---

A diff that promotes one of several documented alternatives to the only one makes that command load-bearing — execute it before shipping.

**What happened:** Agent-instruction docs offered two opt-in speedups for the test
suite. The diff deleted one, leaving the other as the sole documented path. That
surviving command had been wrong since it was written: it passed a non-integer to a
flag the tool declares as an integer, so it aborts with an argument-parse error and
never runs. Pre-existing, and outside the diff's changed lines — but the diff is what
made the section 100% wrong instead of 50% wrong. Running the documented sequence
end to end surfaced it in one command.

**Root cause:** 2.4 checks doc *claims* against implementation, and the relocation-aware
stance correctly downgrades pre-existing issues a diff merely carries along. Neither
covers the case where a deletion changes a survivor's **criticality** without changing
its text. The survivor is unmodified, so no sweep looks at it.

**Suggested fix:** Add to 2.4 — when a diff removes one member of a documented set of
alternatives (install paths, test modes, deploy targets, config options), treat every
surviving member as newly load-bearing: execute each documented command verbatim, and
fix a failure in this diff rather than deferring it as pre-existing. The
relocation-aware downgrade does not apply when the diff removed the alternative that
was masking the defect.
