---
class: principle
---

# Yesterday synthesis

## Evidence window

- Resolve the previous-workday start and end once in the user's timezone.
- Carry a source timestamp and canonical URL or record ID with every candidate.
- Keep only evidence timestamped inside the resolved half-open window.
- Treat the previous snapshot and session memory as candidate leads only.
- Reject prior standup text as evidence; never copy its bullets forward.

## Available-domain sweep

- Query every connected domain below; record unavailable domains instead of
  treating them as empty.
- **GitHub:** authored PRs created, drafted, substantially updated, reviewed, or
  commented on; commits and merges.
- **Calendar and meeting notes:** meetings attended plus decisions,
  alignment, unblockings, or follow-ups.
- **Slack:** authored replies or threads that materially shaped a technical or
  strategy decision.
- **Docs and Drive:** documents created or materially edited, especially
  proposals, decision records, and meeting preparation.
- **Jira and Confluence:** work advanced, clarified, unblocked, completed, or
  updated with substantive context.
- **Gmail:** consequential sent responses that changed a decision or unblocked
  work.

## Selection

- Apply the canonical authorship and standup privacy filters.
- Prefer outcomes, decisions, progress, and unblockings over activity counts.
- Include substantive non-terminal work; merged or completed status adds no
  priority by itself.
- Deduplicate one contribution evidenced across multiple domains.
- Cite each bullet with its canonical source URL or record.
- Rank by impact and emit the strongest 3–4 contributions, one per bullet.
- Emit `No verified accomplishments found` only after every available domain
  returns no qualifying evidence.
