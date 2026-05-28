---
class: principle
date: 2026-05-28
source:
  - ~/.claude/memory/feedback_test_fixtures_use_full_schema.md
  - ~/.claude/memory/feedback_test_edge_case_before_coding_fallback.md
severity: medium
---

- **Rule A** — test fixtures must include every field the schema requires, not the minimal subset the current assertion exercises.
- **Why A** — minimal stubs create hidden coupling; the moment a sibling code path branches on a previously-unused field, every test using the minimal fixture silently asserts undefined behavior or crashes on key-access.
- **Rule B** — before writing a fallback that discriminates on a specific tool error message, run the failing command against a real-enough environment and capture the exact wording.
- **Why B** — error strings vary by tool version and platform; a guessed string makes the fallback either never fire or swallow unrelated failures. Corollary of `wk-workstyle`'s "probe capability, don't parse error text" — when text-matching is unavoidable, derive the string from observation.
- **Where** — Stage 3 in `wk-testing-skeleton` SKILL.md, two new subsections above "Nil-out consumed env vars in stubbed-ENV tests".
