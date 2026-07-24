---
class: principle
---

**Rule** — A red test is not a verdict on the fold. When a newly added case fails while every
pre-existing case passes, drive the artifact directly with the same input before touching the
fold. Disagreement between the direct run and the harness indicts the harness → fix it in the
same pass and count it as audit cleanup.

**Why** — The "report is a hypothesis" rule covers an untrustworthy field report, but the
verification tooling is a second non-authoritative source. A fixture layer that mangles input
fails open-looking: it reports a plausible assertion failure rather than an error, so it reads
as evidence about the code instead of evidence about itself. The obvious reading — "the fold is
wrong" — sends the agent to revert a correct fix.

**Where** — Step 1, merged into the "read the owning source / reproduce where cheap" bullet
rather than added as a fifth bullet, to respect the four-bullet section cap.

**Mechanics corollary routed elsewhere** — the concrete fixture defect (test input interpolated
into a shell command string cannot carry a quote character; pass it through the environment)
belongs to the test-authoring skill, not here. Folded into that skill's shell-harness gotcha
catalog in the same pass.
