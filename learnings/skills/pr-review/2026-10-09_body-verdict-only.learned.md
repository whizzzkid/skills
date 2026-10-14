---
skill: wk-pr-review
date: 2026-10-09
type: correction
severity: medium
verified-against-source: yes
---

When there are concerns, the review body should be the verdict phrase and the footer, nothing else.

**What happened:** The agent posted this pending-review body: "Approving with concerns: one fail-open edge on
the minimal empty-diff path (see the `file:line` thread). The rest of the resolution logic and test coverage
looks right for a no-behavior-change part 1." Before submitting, the user cut it to `Approving with concerns`
plus the footer. They left the inline comment unchanged. The edit removed three things:
- the `: <biggest risk>` clause,
- the "see the L<n> thread" pointer,
- the general approval/praise sentence.

**Root cause:** The skill's body rules still allow all three cuts: the `Approving with concerns — <biggest
risk>` template, the "at most a one-line pointer to the key thread" allowance, and the "genuine praise goes in a
later line" carve-out. The agent treated those allowances as defaults. Earlier distilled learnings on body
verbosity (too verbose, too long, quality rules, no inline restate) never removed them, so the problem keeps
coming back.

**Suggested fix:**
- Body = verdict phrase only (`LGTM 🚀` / `LGTM, one minor nit` / `Approving with concerns`), then the footer.
- Remove the `<biggest risk>` suffix, the key-thread pointer, and the praise line from the body template. Inline
  comments already carry that content, and GitHub shows them under the review.
- Add prose to the body only for a concern that spans the whole change and has no inline anchor. Keep it to one
  sentence.
- Before posting, check: does the body have anything besides the verdict phrase and the footer? If so, justify
  each extra sentence as "no inline anchor exists", or cut it.
