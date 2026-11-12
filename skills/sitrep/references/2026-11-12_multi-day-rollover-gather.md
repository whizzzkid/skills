---
class: principle
---

**Rule** — Every missed-end rollover shares one agent fleet, even when gap days (holiday, PTO, missed weekday) sit
between the closed day and today: each brief carries one explicit half-open window per day, and part B returns one
evidence block per past day. A Yesterday window that comes back empty in every domain steps back to the latest day
with evidence, never past the prior live page's `date:`, and Meta names the day used.

**Why** — The old split ("closed day older than the previous workday → separate gathers") assumed differing windows
need differing fleets; explicit per-part bounds already keep windows apart, so a second fleet only re-queries the same
domains. A no-work day is not the last worked day, so a strict previous-workday window yields an empty standup.

**Where** — `SKILL.md` start Stage 0.5; `references/missed-end-rollover.md` "Shared gather";
`references/yesterday-synthesis.md` Evidence window + Selection; sibling `README.md`.

**Already covered, fired correctly (no escalation)** — in-place transform of the prior page keyed by `data-t` with
renumber + uniqueness assert and canonical handler bytes (`SKILL.md` Stage 4, "Mostly carry-over → transform").

**Parked (not folded)** — a Playwright MCP screenshot given a relative filename lands under the MCP server's
`.playwright-mcp/` output dir at the launching repo's root, not the agent's cwd. Verified on disk; the sitrep repo
gitignores that dir and the screenshot is a transient visual check, so no rule changes.
