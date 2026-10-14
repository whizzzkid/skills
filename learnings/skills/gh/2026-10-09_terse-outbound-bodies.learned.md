---
skill: wk-gh
date: 2026-10-09
type: correction
severity: medium
verified-against-source: n/a
---

Bodies posted on the user's behalf should be terse: verdict or ask first, nothing about the agent's process.

**What happened:** A review body posted on {user}'s behalf ran four sentences: a verdict, a note on
how deep the review went, a summary of what looked fine, and a note about a bot thread. {user} cut it
to just the verdict line. The kept inline comments were already short: one observation plus one
direct question, each with a severity prefix.

**Root cause:** Step 3/4 cover where bodies go and the footer, but say nothing about length or tone.
Each calling skill picks its own verbosity, and the default tends toward explaining what the agent did.

**Suggested fix:** Add a "Voice for outbound bodies" rule to Step 3 that every write surface inherits:
- Lead with the verdict, ask, or finding. One to two sentences per comment, then the footer.
- Leave out process notes (how deep the review was, which tools ran, what was checked and found fine,
  bot-thread bookkeeping). Those go to the user in the terminal, not to GitHub.
- No restating the diff, no filler praise, no hedging.
- Shape for an inline comment: `**<severity>:** <what is wrong, with a code ref>. <ask or fix>?`
- Before posting, drop any sentence that only describes what the agent did.
