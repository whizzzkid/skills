---
skill: wk-devcontainer
date: 2026-08-05
type: correction
severity: high
verified-against-source: yes
---

Never surface raw devcontainer startup output when Compose interpolates forwarded secrets.

**What happened:** The startup command printed its internally generated `docker compose config` output, including the
resolved value of a host credential forwarded into the application service.

**Root cause:** Driving the current CLI confirmed that its normal startup logging emits the fully interpolated Compose
configuration before creating containers; the available log-level choices do not include a quiet or error-only mode.

**Suggested fix:** Before startup, detect sensitive host-forwarded variables in Compose. Capture startup output to a
restricted temporary log and expose only a mechanically redacted view, or use a verified secret-injection path whose
values do not appear in the generated Compose configuration.
