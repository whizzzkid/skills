---
class: principle
date: 2026-05-28
source:
  - ~/.claude/memory/feedback_check_entrypoint_before_edit.md
severity: medium
---

- **Rule** — grep the Dockerfile for `ENTRYPOINT` / `CMD` before editing any `entrypoint.*`, `run.*`, or `start.*` script; confirm the target file is actually invoked.
- **Why** — repos that ship a compiled binary as the real entrypoint frequently keep a same-named shell script for local-dev; editing the shell script produces a change that passes review but has no effect in production.
- **Where** — new section "Verify the ENTRYPOINT Before Editing a Wrapper Script" in `wk-docker` SKILL.md, after the ENTRYPOINT Awareness section.
