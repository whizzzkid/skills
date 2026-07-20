---
class: principle
---

# `end` snapshot.md template

Verbatim body for `SKILL.md` § Sub-command: end / Stage 4. Snapshot is
historical only — never write pending items. The Authorship filter rule lives
inline in `SKILL.md`; it governs which PRs count as the user's here.

```markdown
---
date: {TODAY}
employer: {EMPLOYER}
generated_with: {SKILL_VERSION}
generated_at: {ISO_8601_UTC}
---

# Snapshot — {TODAY}

## Achievements

### Code & PRs
- {shipped, reviewed, unblocked — strong verbs, with links}

### Meetings & Collaboration
- {decisions led, context shared, people unblocked}

### Communication
- {threads closed, announcements, knowledge shared}

### Feedback
- {given / received}

## Meeting Notes
{per-meeting summaries — decisions made, action items, open questions}

## Issues Created Today
- [{repo}\#{N}: {title}](url)

## DX Metrics
| Metric | You | Team | Org | Trend |
|--------|-----|------|-----|-------|
| Review turnaround | | | | |
| PR cycle time | | | | |
| Deploy frequency | | | | |

## Day Stats
- Completed: {N} items · Meetings: {N} · PRs: {created}/{reviewed}/{merged} · Commits: {N}
```
