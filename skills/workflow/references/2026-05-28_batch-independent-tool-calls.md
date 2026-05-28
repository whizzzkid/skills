---
class: principle
date: 2026-05-28
source:
  - ~/.claude/memory/feedback_parallel_independent_tool_calls.md
severity: medium
---

- **Rule** — emit tool calls with no data dependency on each other as parallel `tool_use` blocks in a single response; never serialize them across turns.
- **Why** — serialized independent calls waste a round-trip and prompt cache each; the user corrected this mid-session after two consecutive channel-member probes (private then public) that shared no dependency.
- **Where** — wk-workflow Autonomy Rules section, "Batch independent tool calls into one response" bullet after "Run the full skill flow."
