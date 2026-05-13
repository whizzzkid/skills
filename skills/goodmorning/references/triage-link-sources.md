# Triage link sources

Every item presented to the user during interactive triage MUST carry a
clickable link to the underlying artifact. The presentation format
`{item summary} [link]` is a HARD RULE, not a hint.

## Link-source table

| Group | Link target | Source field |
|-------|-------------|--------------|
| Slack — Needs Response / Follow-ups | Permalink to the message or thread root | `chat.getPermalink` / `permalink` on the message |
| Email — Needs Response / Follow-ups | Gmail thread URL | `https://mail.google.com/mail/u/0/#inbox/{threadId}` |
| GitHub — PRs to Review / Your PRs | PR URL | `pull_request.html_url` from the GitHub API |
| GitHub — Issues | Issue URL | `issue.html_url` |
| Jira — Tickets / Mentions | Issue browse URL | `https://{tenant}.atlassian.net/browse/{KEY}` |
| Confluence — Mentions | Page URL | Confluence REST `_links.webui` joined with the base URL |
| Today's Meeting Prep / Tomorrow's Meeting Prep | Calendar event URL + agenda doc URL | `event.htmlLink` + Granola/Doc URL |
| Yesterday's Meeting Follow-Through | Granola note URL + source-item URL when the follow-through points to one | `meeting.notes_url` + the linked artifact |
| Carry-Over | Original item's link from the prior day's brief | `evening.md` / `morning.md` link |
| Untracked Action Items | Source meeting note URL | Granola `notes_url` |
| Lattice Feedback / Peer Feedback | Lattice request or profile URL | Lattice deep-link |

## Rules

- Resolve the link **at fetch time**, not at present time — Stage 1 agents
  must return a `url` field with every item they emit.
- If a fetch yields no canonical URL, the orchestrator MUST refuse to
  triage the item until a link is produced (re-fetch, fallback search,
  or mark `link_unavailable: true` with a reason and skip).
- Never present `{item summary}` without a `[link]` slot filled — even
  in auto mode, the dashboard render uses the same link slot.
- Plain text is not a link. Render as markdown autolink `<url>` or
  labeled link `[title](url)` so terminals and the HTML dashboard both
  resolve it.
