---
class: one-off
date: 2026-05-28
source:
  - ~/.claude/memory/feedback_grep_struct_initializers_before_test.md
severity: low
---

- **Scenario** — adding a new required (non-optional) field to a public Rust struct, or any equivalent change that statically breaks every existing initializer/constructor of a type (e.g., a new positional arg to a public constructor, a new required key in a TypeScript interface used as an object literal).
- **Symptom** — the next `cargo test` / `tsc` / build fails with predictable per-site compile errors (e.g., Rust `E0063`) at every call site; the test cycle is wasted finding what a grep would have surfaced upfront.
- **Fix** — grep for every initializer before re-running the toolchain:

  ```bash
  # Rust struct gains a required field
  grep -rn 'StructName {' tests/ src/

  # Generalize: search for the type's constructor call shape
  ```

  Update all matches, then run tests once.
- **Why not promoted** — narrow language-specific recipe; the generic rule ("touch every call site of a type before recompiling") is implied by the existing "investigate variables before copy-paste" and "verify across the impact surface" guidance in workstyle/workflow.
