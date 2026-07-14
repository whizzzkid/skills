---
class: principle
---

**Rule** — Sweep 2.75: a broad `rescue <ParentError>` returning a fail-closed default is a
finding. Enumerate the concrete subtypes and split — a should-never-happen config/deploy
bug alerts then denies; the documented steady state denies quietly. Verify the alert
helper self-rescues so it cannot raise into the response path.

**Why** — "Fail closed" conflated with "fail silent": one rescue treating a
never-provisioned value (expected) and an unregistered/misconfigured value (a bug that
never self-heals) identically swallows the bug with zero signal. Alerting on the steady
state instead drowns real signal.

**Where** — `references/sweep-catalog-extended.md` row 2.75; inline pointer list in
`SKILL.md`.
