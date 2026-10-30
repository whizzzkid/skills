---
class: principle
---

# An implementation directive under a mandated PR lifecycle authorizes the first push

**Rule** — The first push of a brand-new branch with no PR proceeds without asking whenever the session is authorized:
any implementation directive (*implement*, *fix*, *build*, *ship X*) running under `wk-workflow`'s mandated PR
lifecycle, a repo or agent-instruction mandate, or an explicit publish prompt. Auto mode is not a precondition. Confirm
only in exploratory, analysis-only, or spike sessions where publishing is genuinely optional.

**Why** — The gate's heading read "confirm intent first" and its exception was a conjunction (auto mode **and** an
authorizing directive) illustrated only by explicit publish prompts. An agent finishing a requested implementation saw
an unlabelled default to confirm, an exception whose examples did not resemble "implement this", and a mode conjunct
it could not satisfy — so it stalled a lifecycle the workflow skill already authorizes unconditionally ("a mandated PR
lifecycle authorizes push + PR creation"). The conjunct contradicted the installed workflow rule; aligning to it
resolves that contradiction rather than relaxing the guard, which still fires for sessions where publishing is
optional.

**Where** — `skills/commit/SKILL.md` → Pushing, first-push bullet: restructured so the authorized branch leads and the
confirm branch is the narrow case; README Noteworthy bullet synced.

## Escalation record

- Re-violation of text installed before the report (repo-mandate exception landed 2026-08-17) → escalated exactly one
  rung: **rung 1 (bold-lead prose) → rung 2 (`**Important —**`)**.
- Report's root-cause claim was partly wrong: the exception already named a repo mandate. The verified gaps were the
  auto-mode conjunct and the default-confirm heading, not a missing mandate source.
- Whether the reporting session ran in auto mode is unverified (`verified-against-source: n/a`); the fold holds either
  way, since the conjunct was the only path by which a non-auto session could legitimately confirm.
