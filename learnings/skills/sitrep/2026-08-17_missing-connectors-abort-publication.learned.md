---
skill: wk-sitrep
date: 2026-08-17
type: correction
severity: high
verified-against-source: yes
---

Missing required evidence connectors must stop publication and prompt the user.

**What happened:** A scheduled daily run had repository and authenticated source-control access, but none of the
company-data connectors were callable. The skill's degraded-output rule was followed, producing and publishing an
incomplete page that preserved carry-over but could not reconstruct meetings, drafts, messages, or strategy work.

**Root cause:** The skill explicitly says evidence gaps degrade rather than stop and separately forbids interactive
triage. Those instructions conflict with the user's quality requirement that a sitrep must not be published when its
required evidence domains are unavailable.

**Suggested fix:** Treat any unavailable required evidence connector as a pre-write hard block. Preserve the existing
live page unchanged, perform no rollover or brag accrual, make no commit or push, and prompt the user to restore the
missing connectors or explicitly authorize a one-time incomplete artifact.
