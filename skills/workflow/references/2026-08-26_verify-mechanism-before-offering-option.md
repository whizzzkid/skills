---
skill: wk-workflow
date: 2026-08-26
class: principle
source: learnings/skills/workflow/2026-08-26_verify-capability-before-offering-option.md
---

# Verify Mechanism Before Offering Options

- **Incident:** Agent offered an AskUserQuestion option with a code preview
  showing argv passthrough for a container entrypoint — without reading the
  entrypoint's actual contract. The entrypoint was a session launcher, not a
  command wrapper. User selected the mislabeled option; agent had to re-scope.

- **Root cause:** The "external-capability claims cite upstream source" rule
  applied only to PR-body and code claims, not to decision surfaces
  (AskUserQuestion options, previews, proposed approaches).

- **Principle:** An option framed as "accomplish X routing through
  capability/tool Y" is a behavioral claim about Y's interface. Read Y's
  upstream source before presenting the option. Unverified mechanisms transfer
  a false premise into the plan when selected.

- **Rule added:** Autonomy Rules → "Verify mechanism before offering options"
  bullet — extends external-capability-source rule to cover decision surfaces.
