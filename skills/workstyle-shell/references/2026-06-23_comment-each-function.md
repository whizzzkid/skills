---
class: principle
skill: wk-workstyle-shell
date: 2026-06-23
---

**Rule**

Add a one-line comment above each function in shell scripts with ≥3 functions,
describing what it does and any non-obvious output format. Single-/two-function
scripts may skip it.

**Why**

The "no comments unless WHY is non-obvious" default over-applies to shell: bash
functions lack type signatures and docstrings, so a one-liner is the only signal
about inputs, side effects, and output shape (the WHAT is non-obvious from the
name alone).

**Where**

Rules list, beside named-constants.
