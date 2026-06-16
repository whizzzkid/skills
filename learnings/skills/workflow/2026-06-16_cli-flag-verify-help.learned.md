---
skill: wk-workflow
date: 2026-06-16
type: correction
severity: medium
---

An external review CLI uses `--repo-path`, not `--repo`; the wrong flag causes immediate exit-code-2 failure.

**What happened:** A global instruction hard-codes the CLI with `--repo .`, which fails with "flag provided but not defined: -repo" (exit 2). The correct flag is `--repo-path .`.

**Root cause:** The flag name changed or was never `--repo`; the instruction was written with the wrong flag and not validated against the actual CLI help output.

**Suggested fix:** Use the correct flag in the instruction, and add a note to verify any flag against the tool's `--help` before embedding it in any doc.
