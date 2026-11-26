---
class: principle
---

# Needs attention now — col2's first section

The first col2 section, above ASAP, is a checklist of what the user must clear today. Every line in it is an open
`st-item st-nested` checkbox; group headings are `st-info` lines.

## Title and groups

Title: `**🚨 Needs attention now**`. Groups, in this order, each led by one `st-info` line:

1. **Review drafts created this run** — every PENDING draft Stage 7 posted:
   `[repo\#N: short title](review URL) — N comments, light review`. Before Stage 7 runs, the group's info line says
   reviews are pending launch; Stage 7 replaces it in place (see [Stage 7 write-back](#stage-7-write-back)).
2. **Pending review drafts — submit or discard** — every older unsubmitted PENDING draft of the user's on an open PR,
   split by two `st-info` lines: drafts on the user's own PRs (self-review) and drafts on PRs awaiting their review.
   Each line carries the review URL, comment count and PR state.
3. **Blocking others / due today** — items where a named person waits on the user to unblock them (merge owner,
   requested approval, a question they cannot proceed without), plus anything with a hard deadline today or already
   passed that is still owed (an unsubmitted scorecard, a form). Move each such item here from its source section;
   never copy it.

- **Live, never carried.** Rebuild groups 1–2 every run from the Stage 2 GraphQL draft sweep (candidates: the user's
  open PRs plus every review-requested PR). A carried draft line may already be submitted or orphaned.
- **Empty group → one info line saying none**, with the count of PRs checked (so "none" is visibly a checked result,
  not a skipped one).
- **One home per artifact.** A draft or PR listed here is not repeated in the GitHub Inbox, ASAP or Jira sections.
- **No blank line inside the column** (it ends the HTML block and drops the next column).

## Stage 7 write-back

Stage 7 runs after the page is committed, so its drafts reach the page only through an explicit write-back:

1. After every review returns and its live state is re-checked, take the posted drafts that are still `PENDING` on
   an open PR.
2. Patch group 1 in place: replace its placeholder info line with one open checkbox item per draft (generator rules
   from `SKILL.md` Stage 4). Keep the ⚙️ Auto-Actions launch line done; the draft line is the open work.
3. Re-run the Stage 5 render gate, then commit and push (`chore(sitrep): 📝 add auto-review drafts $TODAY`; push
   only when `PUSH_ALLOWED=1`).
4. No draft posted → replace the placeholder with an info line naming why (none awaiting, all settled, no clone).

- A done ⚙️ Auto-Action is not a substitute for the draft line: a ticked launch reads as finished while the draft
  still waits to be submitted.
