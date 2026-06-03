---
skill: wk-sitrep
date: 2026-06-03
type: correction
severity: high
---

Seven structural improvements to snapshot + live.md format validated by user feedback.

**What happened:** First run of wk-sitrep:end produced a snapshot that mixed historical achievements with pending action items, a live.md that was mostly empty, and both files lacked consistent formatting for dates, urgency, and links.

**Root cause:** Skill was scaffolded without a clear separation of concerns between the two output files, and without formatting conventions for the SilverBullet rendering context.

**Suggested fix — apply all seven rules to every wk-sitrep end run:**

1. **Snapshot = historical record only.** Completed `[x]` items and meeting notes stay in snapshot. Pending `[ ]` items MUST move to live.md. Never write a pending checklist item into snapshot.

2. **live.md owns all pending work.** Every unchecked item from every section (carry-forward, tomorrow's prep, DX improvement actions, unresolved follow-ups) lives in live.md. The snapshot is append-only for future runs.

3. **No last_working_day file.** Embed `date:` in live.md frontmatter. Do not write a separate `.last_working_day` file.

4. **Every item must have a link.** If a canonical URL is unavailable, use `link_unavailable: true` in the agent output and omit the item from the checklist rather than surfacing it linkless. No exceptions.

5. **Nested checkboxes for multi-step items.** When an action item has sub-tasks (e.g., a meeting with prep sub-items), use indented `  - [ ]` under the parent.

6. **Sort by due-date / priority / severity.** Within each section: overdue or ASAP items first, then dated items ascending, then undated. Use emoji urgency markers: 🔴 (overdue/ASAP), 🟡 (due within 3 days), 🟢 (later / no hard date).

7. **Formatted due-dates.** Render dates as bold with a 📅 prefix: `**📅 2026-06-08**`. Never embed a date as plain prose inside a sentence — it must be scannable at a glance.
