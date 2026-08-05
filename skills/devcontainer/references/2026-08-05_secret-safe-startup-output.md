---
class: principle
---

# Redact interpolated startup output before display

**Rule:** Detect host credentials referenced by Compose before devcontainer
startup. Prefer file-backed secrets; otherwise capture output with restrictive
permissions and display only an exact-value-redacted copy.

**Why:** Some startup CLIs print the resolved Compose model, so forwarding a
credential through the environment can disclose it in ordinary terminal output.

**Where:** `wk-devcontainer` secret-safe startup-output gate.
