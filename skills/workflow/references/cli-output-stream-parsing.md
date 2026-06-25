---
class: principle
---

**Rule:** Before writing instructions/scripts that parse a CLI tool's output, verify
which stream (stdout vs stderr) each line uses and which flags gate which line.
Capture both with `2>&1` and grep an always-emitted line, never a flag-conditioned
one.

**Why:** CLI docs often don't distinguish stdout/stderr or flag-gated vs
always-emitted lines. Grepping a line gated by `--quiet`/`--json`/`--no-color`
unconditionally returns empty silently — the parse produces no results and the
failure is invisible.

**Where:** wk-workflow Phase 2 → Code Standards.
