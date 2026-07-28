---
class: principle
---

# A verification rule scoped to one scan does not carry to a sibling scan

**Rule** — The load-bearing-zero grep discipline was **hoisted out of Step 5** into the new
top-level *Cross-Cutting Rules* section and restated as a property of the **grep**, not of
the scan that happens to use it:

> **Important — any grep whose zero over a resolved path is load-bearing:** `command grep`,
> one quoted path per invocation, rc 0/1/≥2 = hit/clean/error; never let `||` or a banner
> supply a verdict.

It now subsumes three previously separate statements, each deleted or reduced to a nod:

- the Step 2 "zero-match grep whose emptiness is load-bearing" bullet (deleted — also stated
  in full by the linked [`skill-dir-resolution.md`](skill-dir-resolution.md));
- the Step 5 staged-path-scan restatement (reduced to "both take the load-bearing-zero rule
  above");
- the Step 3 parenthetical asserting the `command` prefix for every load-bearing zero
  (deleted — now the hoisted rule's own first clause).

**Why** — The rule was installed and stated the fix exactly, but it sat as a sub-bullet of
the Step 5 instruction about scanning **staged path strings**, so it read as a property of
that particular scan. The overfit-category scan is a different file set at a different
moment, and the discipline did not carry: five paths were joined into one quoted argument,
`grep` resolved it as a single nonexistent filename, and a trailing `|| echo none` mapped
the resulting rc≥2 onto the clean branch — two categories reported clean having scanned
nothing. The same misreading was available for every other load-bearing zero the skill runs
(the prohibited-subject gate, the Step 2 subject grep, the drift greps), each of which
restated or omitted the discipline separately. Scoping a discipline to its first site is what
produced both the miss and the duplication.

**Escalation — one notch, rung 1 → 2 (`**Important:**`)** — the repeat is genuine and the
escalation is valid against text installed *before* the report: `git log -S` dates the rule
("a banner is not a verdict", "one quoted path per grep") to commit `f65ece1`, **2026-07-27**,
against a 2026-07-28 report. No positive-steering evidence existed — the defect surfaced from
reading grep's stderr, which is self-correction, not the rule firing. Per the skill, the
repeat traces to the rule's **shape**, so the relocating-and-generalizing rewrite is the
load-bearing change and the notch only records it.

**Self-governing fold** — the hoisted (post-edit) text is the stricter of the two and was
applied to this run's own scans: the prohibited-subject gate ran subject-on-stdin with
patterns via `-f`, proven live by a metachar-derived in-memory canary, with the verdict taken
from the scan's own rc (canary rc 0, subject rc 1) and no banner anywhere.

**Where** — `SKILL.md` → *Cross-Cutting Rules* (load-bearing zeros); mechanics remain in
[`staged-path-scan.md`](staged-path-scan.md), whose "verdict protocol binds every hand-rolled
scan this skill runs" section is now matched by the body's framing rather than contradicted
by it.
