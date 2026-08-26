---
skill: wk-workflow
date: 2026-08-26
type: correction
severity: medium
verified-against-source: yes
---

Verify a capability's real interface from source BEFORE offering "do X via Y" as a user option, not just before writing prose.

**What happened:** While triaging a review finding (a container launched a CLI
directly, bypassing a hardened entrypoint that owns the egress firewall), the
agent offered the user an AskUserQuestion option "route through {entrypoint}"
with a code preview showing an argv passthrough (`IMAGE {entrypoint} <cmd>`). The
user picked it. Only then did the agent read the entrypoint's actual contract and
find it is an agent-session launcher driven by an env-var prompt that writes
output to a bind-mounted workspace file — NOT a command wrapper. The chosen
option was mislabeled, so the agent had to ask a second question re-scoping the
work as a refactor. The user called this out: "you should've researched this
before implementing this."

**Root cause:** The existing wk-workflow rule "external-capability claims cite
their upstream source" was applied only to PR-body/code claims, not to
AskUserQuestion option descriptions and previews. An option preview is a
behavioral claim about a capability; offering it unverified transfers a
plausible-but-wrong mechanism to the user with the authority of a real choice.

**Suggested fix:** Extend the external-capability-source rule to explicitly cover
decision surfaces (AskUserQuestion options, previews, proposed approaches): when
an option is framed as "accomplish X by routing through capability/tool Y" —
especially on a security/infra path — read Y's interface from an upstream source
before presenting the option. If unverified, either research first or label the
option's mechanism as unconfirmed so the user is not choosing a mislabeled path.
