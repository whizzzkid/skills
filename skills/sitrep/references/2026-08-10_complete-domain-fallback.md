---
class: principle
---

# Main-context fallbacks replay the full domain contract

**Rule** — When a gathering subagent returns `tool_unavailable`, replay every
query window and output field in the main context, then finish each dependent
orchestrator action before compiling.

**Why** — Replacing only visible data silently skips time-bounded scans and
side effects owned by the orchestrator.

**Where** — `start` Stage 2 fallback handling and Stage 2c interview-prep
verification.
