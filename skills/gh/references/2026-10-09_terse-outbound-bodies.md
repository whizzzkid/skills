---
class: principle
---

# Keep the agent's process out of outbound bodies

**Rule**

- Leave process notes out of GitHub bodies: review depth, which tools ran, what was checked and found fine,
  bot-thread bookkeeping. Report those to the user in the terminal.
- Inline comment shape: `**<severity>:** <what is wrong, with a code ref>. <ask or fix>?`
- Before posting, drop any sentence that only describes what the agent did.

**Why**

- A four-sentence body (verdict, review depth, what looked fine, bot-thread note) was cut to the verdict line. The
  default drift is toward explaining what the agent did, which the reader does not need.

**Where**

`skills/gh/SKILL.md` → Step 3 terse-body HARD RULE (merged with `2026-10-09_outbound-terse-tone.md`).
