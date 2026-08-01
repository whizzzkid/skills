---
skill: wk-workstyle-shell
date: 2026-08-01
type: correction
severity: medium
verified-against-source: yes
---

Cross-shell probes must not enumerate optional config patterns with bare globs.

**What happened:** A config-discovery loop with optional wildcard paths aborted under a shell where an unmatched glob
is fatal. Enabling that shell's null-glob mode made the probe pass but violated the existing portability guidance.

**Root cause:** The probe expanded wildcard candidates before entering the loop, so zero matching files aborted the
command instead of producing an empty candidate set.

**Suggested fix:** Enumerate candidate files with a shell-neutral primitive that does not require wildcard expansion,
and cover the no-matching-config case with a negative fixture.
