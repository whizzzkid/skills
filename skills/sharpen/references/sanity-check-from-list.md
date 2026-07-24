---
class: principle
---

**Rule:** When sanity-checking that the prohibited-term grep fires, source the
known-positive pattern FROM `.skillprohibit` itself (e.g. its first non-comment
line), not a guessed term.

**Why:** A guessed employer/codename may not be in the pattern file (some tokens
are handled by a separate scrub-identifiers hook), so the probe prints a false
"grep broken" signal even when the grep is fully functional.

**Where:** Step 5 (Mechanical overfit scan) — the NONE-result verification bullet.

**Superseded (2026-07-24):** Step 5 now runs the owning hook scripts against the
staged index, so no probe is needed for the hook-covered scans. The residual probe
rule (path-string scan only) additionally requires a **non-comment, non-blank**
source line — sourcing "the first line" lands on the file's comment header.
