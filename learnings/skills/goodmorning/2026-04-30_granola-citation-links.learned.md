---
skill: wk-goodmorning
date: 2026-04-30
type: gap
severity: high
---

Items derived from Granola meeting notes (or other internal/non-URL sources) lack citation links AND single-source claims get rendered as hard facts without confirming with the user — broader pattern: auto mode is over-resolving ambiguity silently instead of asking.

**What happened:** The Apr 30 morning brief listed "AI fluency quarterly review — deadline today" as a top priority with no link. The claim came from a single line in yesterday's Adam Neumann 1:1 Granola note ("Quarterly AI fluency reviews deadline tomorrow"). User asked where the link was; the answer was: there isn't one, because Granola notes weren't surfaced as citable sources. The brief therefore presented Adam's offhand framing as a hard deadline without traceability — and a separate Gmail-sourced item (AI Fluency Scorecard rollout May 4 + AMA May 5) suggested Adam's "tomorrow" framing may have been wrong.

**Root cause:** The skill's source-link rule (Stage 2 "Source-link rule for summary/priorities lists") covers external artifacts (Slack threads, GitHub PRs, Jira tickets, Calendar Zooms, Google Docs) but is silent on **internal sources like Granola meeting notes, Slack DMs surfaced via search, or claims extracted by Stage 1 agents themselves**. When an item's only source is "a Granola note from yesterday's 1:1 with X" or "from yesterday's evening.md follow-through", the renderer has no convention for citing it, so the citation gets dropped.

A second related gap: the skill doesn't distinguish between **verified facts** (a calendar invite, a Jira ticket, a PR URL) and **single-source claims** (someone's offhand remark in a meeting). Both get rendered as flat priority items, so soft claims become hard deadlines in the user's view.

**Suggested fix:**

1. **Extend the source-link rule** in Stage 2 to require citations for ALL priority and action items, including internal sources:
   - Granola note → link to `granola://meeting/<id>` or include `(Granola: {meeting} {date})` inline
   - Slack DM/thread → permalink (already covered)
   - evening.md / morning.md carry-over → cite as `(carry-over from {YYYY-MM-DD})` linking to the relative file path
   - Agent-derived inference (e.g., "{repo}#NNN superseded by #82?") → mark with `(inferred)` and link both PRs

2. **Add a "claim confidence" annotation** to action items extracted from meeting notes:
   - `(verified: <link>)` for items with a concrete external artifact
   - `(claim: {source})` for single-source claims that need verification before treating as hard deadlines
   - Render `(claim: ...)` items in a softer style (italics, muted color) so they don't read as authoritative

3. **Cross-reference detection**: when a single-source claim conflicts with another data point (e.g., Adam's "fluency review deadline tomorrow" vs. Gmail's "Scorecard share May 4 + AMA May 5"), flag inline as `⚠ conflicts with: {other source}` rather than silently picking one.

4. **Subagent prompts should require citations**: each Stage 1 agent should be instructed to return the **source URL or identifier** alongside every item, not just the summary. Calendar agent should return Granola note IDs/URLs per meeting; Slack agent should return permalinks (already does); Granola sub-step in Agent 3 should return the specific note URL alongside the extracted insight.

5. **Stage 2 compilation should reject** any item that arrives without a source identifier — either drop it, demote it to a "claim" with explicit framing, or require the agent to re-fetch with sourcing.

6. **Auto mode is not a license to silently resolve uncertainty.** When agent data contains a vague single-source claim that becomes a "hard deadline" or "critical priority," the skill should either (a) demote it to "claim: ..." in the rendered output, or (b) surface a confirmation prompt to the user even in auto mode for items flagged as `unverified-but-promoted-to-priority`. The current behavior — flatten everything into authoritative priorities and skip prompting — accumulates errors. Add an exception to the "non-interactive / auto mode" rules: auto mode skips routine triage, but high-impact unverified claims still warrant a single confirmation. User feedback verbatim: "you've stopped confirming with me regarding what is happening and that is causing issues."

This applies equally to wk-goodevening — meeting follow-through items in evening.md should carry Granola URLs back to the source meeting, and unverified meeting claims should be flagged not promoted.
