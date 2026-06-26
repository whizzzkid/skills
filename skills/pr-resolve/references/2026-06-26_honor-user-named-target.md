---
class: principle
---

**Rule:** When the user points to a specific artifact (PR comment, CI log, bot review),
extract and name the exact finding they referenced before writing any code. If multiple
findings are present, ask which one the user means rather than inferring. Do not act on
adjacent findings until the user's stated issue is resolved.

**Why:** An agent fetched a bot review the user named, then got distracted by a different
finding in the same comment and implemented that instead. Each subsequent CI run surfaced
a new finding the agent chased, compounding the deviation and introducing extra bugs; the
actual fix landed many rounds later.

**Where:** Step 4 (Generate Suggestions) — HARD RULE at the top of the step.
