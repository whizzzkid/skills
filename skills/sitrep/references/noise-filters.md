---
class: principle
---

# Noise filters — Stage 3 pruning

Run every filter over the compiled list (agent results plus carry-over) before Stage 4 writes the page. Each filter
names where a dropped item goes, so nothing vanishes silently.

| Filter | Test | Action |
|--------|------|--------|
| Duplicate | Same canonical URL (PR, ticket, thread, mail) appears in more than one item or section | Keep one, in the highest section (Needs attention → ASAP → GitHub Inbox → Jira → others); merge the notes |
| Stacked urgency | Item text starts with more than one urgency glyph (`🔴`/`🟡`/`🟢`) | Strip all leading glyphs, then prefix exactly one recomputed glyph |
| Already handled | Source shows the user replied, merged, submitted, or the ticket is Done since the item was written | Drop; register as pruned |
| Not the user's | Owner is another named person, or the note says no owner is named for the user / nothing is addressed to them | Drop and register, or one `st-info` line if the user asked to track it |
| FYI only | Announcement, reschedule notice, "read when convenient", transient-incident all-clear | `st-info` line in its section, never a checkbox; older than 3 days → drop and register |
| Empty status line | An Auto-Actions or sweep line that only says none happened | Fold into one Meta line; never a section body line |
| Lapsed deadline | Hard deadline passed more than 7 days ago and nothing is still owed | Drop; register as pruned |
| Expired carry-over | No new activity in the source for 21+ days and no hard date | Drop; register as pruned, with the last-activity date in the title |
| Stale account notice | Sign-in, device or security notice older than 3 days with no follow-up mail | Drop; register as pruned |
| Unreadable claim | The agent could not read the content (no permalink, body not read) | One `st-info` line per domain summarizing the count, never one checkbox each |

- **Register every drop, or the next gather resurrects it.** Write each dropped item to the week's dismissed registry
  ([`dismissed-registry.md`](dismissed-registry.md)) with `dismissed_because: "pruned:<filter>"`; a duplicate merge
  or an `st-info` demotion is not a drop. The registry is week-scoped, so an item that gains new activity can return.
- **Never drop a still-owed artifact.** A draft, unsubmitted scorecard or pending form survives every filter until its
  source shows the submitted state (terminal-state rule in [`rendering-contract.md`](rendering-contract.md)).
- **Bot-originated asks stay, deduped.** Untrusted bot text keeps its "not acted on" tag; merge repeat posts of the
  same finding set into one item.
- **Meta records the prune.** One line: `pruned N (dup X, handled Y, expired Z, …)`, so a shrinking page is visibly
  intentional.
