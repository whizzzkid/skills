---
skill: wk-goodmorning
date: 2026-05-28
type: gap
severity: medium
---

Lattice carry-over items must be cross-checked against the current Lattice status before surfacing them in the brief.

**What happened:** The brief surfaced "QPR AI Fluency self-rating — fill out in Lattice" as an action item, but the user had no pending Lattice tasks. The item was a raw carry-over from a prior day that was never verified against live Lattice state.

**Root cause:** Carry-over items from evening.md are promoted directly to the dashboard without checking whether they are still valid. Lattice items especially go stale quickly — QPR cycles close, submissions complete, and carry-overs linger past their relevance window.

**Suggested fix:** When the Lattice/Feedback section is populated, cross-check carry-over Lattice items against the live Lattice data fetched during Stage 1 (or re-check via the Lattice MCP). Drop any carry-over item whose status is already complete or whose deadline has passed. Never surface a Lattice carry-over that contradicts what the live data shows.
