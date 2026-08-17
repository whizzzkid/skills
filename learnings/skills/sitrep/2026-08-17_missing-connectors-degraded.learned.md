---
skill: wk-sitrep
date: 2026-08-17
type: correction
severity: high
verified-against-source: yes
---

Missing evidence connectors must produce an explicit degraded sitrep, never a partial success presented as complete.

**What happened:** A scheduled daily run had repository and authenticated source-control access, but none of the
company-data connectors were callable. The workflow stopped without producing a current page, while an earlier
partial run had demonstrated that source-control-only synthesis omits meetings, drafts, and strategic communication.

**Root cause:** The task runtime's callable-tool registry contained no read tools for the required evidence domains.
The skill correctly treated the sources as hard blocks but lacked a user-authorized degraded-output path that both
preserved carry-over and made the evidence gap unmistakable.

**Suggested fix:** Add an explicit degraded-mode branch for direct rerun requests after connector validation fails.
It must preserve checkbox state and carry-over, remove stale dated meetings, refuse to claim unverified outcomes,
label every unavailable source, retain the standup hierarchy, and never update rollover or brag artifacts until full
evidence reconciliation is possible.
