---
skill: wk-arch-review
date: 2026-05-29
type: correction
severity: medium
---

Never characterize blast radius or scope magnitude before completing the eight-lens analysis — the analysis determines blast radius, not the diff size.

**What happened:** A review body described a doc-only PR as having "low blast radius" before arch-review had run. Arch-review exists precisely to determine blast radius; pre-judging it from diff size defeats the purpose and can suppress reviewer attention on genuinely high-impact design docs.

**Root cause:** "Doc-only" is a diff-surface observation, not a blast-radius conclusion. A single spec can authorize an implementation with wide system impact.

**Suggested fix:** The executive summary must derive blast radius from lens findings (SPOFs, assumption failures, delivery risk), never from the diff type. If the eight lenses reveal no high-severity findings, then state low blast radius with that evidence. Starting from "it's doc-only so blast radius is low" inverts the reasoning.
