---
class: principle
---

# Verdict is the body's first line

**Rule** — the pre-POST body gate also checks the first line: it must be one of the verdict tokens (`LGTM 🚀`,
`LGTM, one minor nit`, `Approving with concerns`, …). No lead-in, narration, praise, or finding comes first. A
text-only draft (no GitHub API, e.g. the user asks for a body to paste) keeps the same shape: verdict line, then the
findings as an inline-comment list.

**Why** — the weekly eval's `pr_review_verdict` probe fell from 8/10 to 6/10. Failing drafts opened with "A few things
worth calling out…", a diff summary, or a `suggestion:` line. The verdict rule existed, but the gate only counted
sentences, so a draft with the verdict missing or moved down still passed. Text-only drafts had no shape at all, so
findings filled the body.

**Where** — `SKILL.md` → Phase 5 → *pre-POST body gate*.
