---
skill: wk-bash
date: 2026-06-23
type: correction
severity: medium
---

Always add a one-line comment above each function in bash scripts describing what it does.

**What happened:** A bash scope-doctor script was written with no inline comments on any of its helper functions. The user explicitly requested comments be added to explain what each function does.

**Root cause:** The "no comments" default from CLAUDE.md ("default to writing no comments; only add one when the WHY is non-obvious") was over-applied to bash scripts where the WHAT is not immediately obvious from function names alone. Bash helper functions lack type signatures and docstrings, so a one-line comment is the only signal about inputs, side effects, and expected output format.

**Suggested fix:** For every function in a bash file, add a single comment line above the `function` keyword describing what it does and any non-obvious output format (e.g., "Returns the OS name in lowercase for package lookup"). This applies to scripts with ≥3 functions — single-purpose scripts with one or two obvious functions may skip it.
