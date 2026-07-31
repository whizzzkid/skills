---
class: principle
skill: wk-sharpen
date: 2026-07-27
severity: medium
---

# A batch-mode source re-list is a scan, and its verdict comes from rc plus output

**Rule** — The verdict discipline stated for Step 5's hand-rolled scans binds every scan
whose result the run acts on, batch-mode source re-lists included. A source is drained only
when its scan **exited 0 and returned nothing**. A printed banner is a label, never a
verdict.

**Companion rule landed with it** — Source 2 now names the rename primitive: plain `mv`,
never `git mv`, and check its rc. A learning file is deliberately left untracked until
distillation, so `git mv` fails on it every time.

**Verified against source** — `git mv` on an untracked path exits **128** with
`fatal: not under version control`. Reproduced in a throwaway repo, not inferred from the
report.

**The incident** — In the same run that landed "a printed banner is not a verdict", the
Source 2 re-list ran `find` unconditionally and echoed `(empty = drained)` beneath its own
non-empty output. The rename had failed (`git mv` on the untracked learning), so the file
was still listed while the banner claimed the source was drained. The contradiction was
visible only because the raw `find` output happened to sit in the same block — the same
accident that caught the original incident.

**Root cause of the earlier fold falling short** — it generalized one notch short. The
property was restated for "any hand-rolled scan" but anchored to the Step 5 staged-path
enumeration, so batch mode's own scans (`find` over the learnings tree, the memory listing
gate, the marker diff) inherited none of it. The "drained" verdict is exactly the
high-stakes zero this skill elsewhere insists on proving with a canary, so the omission sat
where it cost most.

**Placement** — the rule is stated where the drained verdict is *defined* (batch-mode
sources), not only in the Step 5 reference a batch run never re-reads. A failed rename is
the most likely way a stale "drained" gets produced, which is why the primitive is named at
the point the rename is prescribed.

**Byte budget** — addition +115 B across two sites; reclaim −129 B by prose-tightening two
Step 1 bullets (dropping one redundant example and one restated clause, no rule, command, or
failure mode lost, no rule's earliest statement touched). Net **−14 B**, body 24571 → 24557
of 24576. Both readings of the budget gate are satisfied: net non-positive **and** under
every ceiling.

**Not relocated — amended 2026-07-28:** Re-testing with a cut-site pointer superseded the
recorded reachability ground. The block remains inline because it is a control-construction
verification checklist, which the ceiling rule permanently protects under every edit shape.
