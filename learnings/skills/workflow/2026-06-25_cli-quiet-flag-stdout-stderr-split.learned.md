---
skill: wk-workflow
date: 2026-06-25
type: correction
severity: high
---

When writing skill instructions that parse CLI output, verify which stream (stdout vs stderr) each output line uses and which flags suppress which stream.

**What happened:** A skill was written to grep for a line emitted on stdout ("Findings written to: <path>"), but that line is gated by `--quiet`. A different line with the same path info ("Done in %v: %d findings → <path>") is emitted on stderr via log.Printf and is never suppressed. Grepping for the wrong line always returned empty, silently producing no findings.

**Root cause:** CLI output documentation often doesn't distinguish stdout vs stderr or flag-conditioned vs always-emitted lines. The skill author assumed the human-readable summary line was always present without checking the source.

**Suggested fix:** Before writing parse instructions for any CLI tool, verify by reading the source or testing with flags: (1) which output goes to stdout vs stderr, (2) which lines are gated by --quiet/--json/--no-color, (3) capture both streams with 2>&1 and grep the always-emitted line, not the conditional one.
