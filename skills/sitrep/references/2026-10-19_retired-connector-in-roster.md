---
class: principle
---

# Offer roster migration before a waiver

**Rule**

- On a missing-connector abort, check whether an available connector covers the same evidence domain. If so, offer
  "migrate roster" alongside "waive once" / "waive always".
- User confirms the migration → edit the skill source in one pass: roster agent line, ToolSearch hint,
  `allowed-tools`, and the Requirements MCP list. Never migrate on inference.

**Why**

- The required set derives from a hard-coded roster, so a connector the user retired stays mandatory and aborts every
  run. A waiver silences one run (or hides the domain); only a roster edit fixes the cause while keeping the domain
  required under its replacement.

**Guard check**

- Does not relax the abort: the domain stays required; only the connector serving it changes, with user consent.

**Where**

`skills/sitrep/SKILL.md` → Core hard rules (connector abort, waiver sub-bullets).
