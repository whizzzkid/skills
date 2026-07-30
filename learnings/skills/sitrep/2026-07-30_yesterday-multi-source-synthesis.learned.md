---
skill: wk-sitrep
date: 2026-07-30
type: correction
severity: high
verified-against-source: yes
---

Standup Yesterday must be a date-bounded synthesis of contributions across all work sources, not a merged-PR report.

**What happened:** A start run reused the previous day's Yesterday bullets after a date-scoped merged-PR search returned
no results. That duplicated stale accomplishments and omitted substantive work that had not reached a terminal artifact
state: progress on draft PRs, meetings with collaborators, replies in decision-making threads, and strategy decisions.

**Root cause:** Stage 4b's missing-snapshot fallback only names merged GitHub PRs and Jira tickets moved to Done. It
therefore equates "Yesterday wins" with terminal tracker events and provides no required collection contract for
non-terminal engineering progress, collaboration, or decision work. It also lacks a freshness gate preventing a prior
standup block from being reused when its evidence falls outside the previous-workday window.

**Suggested fix:** Replace the narrow fallback with a required previous-workday contribution sweep across every
available source:

- GitHub: authored PRs created, drafted, substantially updated, reviewed, or commented on; commits and merges are only
  some possible evidence.
- Calendar and meeting artifacts: meetings attended plus concrete decisions, alignment, unblockings, or follow-ups.
- Slack: authored replies and threads where the user made or materially shaped a technical or strategy decision.
- Docs and Drive: documents created or materially edited, especially decision records, proposals, and meeting prep.
- Jira and other trackers: tickets advanced, clarified, unblocked, completed, or updated with substantive context.
- Gmail or other communication sources: consequential outgoing responses when they changed a decision or unblocked work.

Require every Yesterday bullet to cite evidence timestamped inside the resolved previous-workday window. Rank outcomes,
decisions, progress, and unblockings by impact rather than preferring terminal artifact states. Never use the prior
standup text itself as evidence. If no verified contribution survives after all available domains are queried, say that
no verified accomplishments were found instead of duplicating an older section. Add a semantic-freshness verification
step that checks each bullet's evidence date before render validation.
