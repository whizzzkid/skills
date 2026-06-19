---
class: principle
---

**Rule:** Two pre-flight checks before encoding values in a new code path:
1. Before hardcoding any environment-specific constant (OS, arch, version, path), grep the file for the same value in an existing path; if a sibling computes it dynamically (`uname -s`/`uname -m`, etc.), reuse that computation.
2. Treat a version/naming/query string shown in a feature request — especially inside a CLI snippet — as illustrative, not normative; confirm the exact production format before encoding it across more than one file.

**Why:** A beta binary path hardcoded `…-beta-linux-x64` while the adjacent stable path already derived OS/arch dynamically — the parallel path was authored in isolation, requiring a user correction. Separately, an example version string `beta-PR<N>-<sha-7>` from a CLI snippet was implemented literally, then corrected twice (`beta-<sha-7>`, then `beta-<full_sha>`). Examples in requests are illustrative; encoding them as the spec multiplies correction cycles across code/specs/docs.

**Where:** Phase 2 Code Standards in `SKILL.md` — "No hardcoded env-specific constant beside a dynamic sibling" and "Confirm example formats before encoding" bullets.
