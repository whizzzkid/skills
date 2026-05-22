---
class: principle
date: 2026-05-22
source: learnings/skills/wk-workflow/2026-05-22_side-effects-in-library-code.md
---

- **Rule:** Before adding I/O (`puts`, `print`, `console.log`, file writes, env reads, network calls) to a module, classify the module as decision/pure or side-effecting/entrypoint. Side effects belong only in entrypoint layers (CLI script, HTTP handler, job runner, controller, view); decision modules return values and let the entrypoint render / log / read ENV.
- **Why:** Adding `puts` and env reads to library modules duplicates parsing across siblings, contaminates pure decision logic with stdout, and forces tests to capture output to assert behaviour.
- **Where:** Code Standards section — new "Layer responsibility — side effects live at the entrypoint" subsection between Diagrams and ADRs.
