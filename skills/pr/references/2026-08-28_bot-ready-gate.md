---
class: principle
---

# Bot-ready gate overrides draft default

**Rule** — When a repo's automated review bot approves only non-draft (ready)
PRs, mark the PR ready immediately after creation instead of waiting for CI.
The draft-until-CI default yields to the bot's gate requirement.

**Why** — The default draft mode prevents the bot from reviewing, which blocks
the approval path. The user had to manually override, which is the signal that
the default should auto-detect this.

**Where** — `SKILL.md` → Step 2 → *Bot-ready gate*.
