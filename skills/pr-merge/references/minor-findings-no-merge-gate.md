---
class: principle
---

# Minor/Info findings never gate the merge

**Rule** — In the Step 4 review-thread triage, Minor/Info findings never gate the
merge. Do not file (or ask to file) tickets pre-merge — merge first, then offer to
file follow-up tickets in the Step 8 output. Ask for the epic/parent only if the
user accepts the offer. The ask-and-file flow is a post-merge follow-up gate, not
a merge gate.

**Why** — The prior flow read "propose → ask → file → resolve → proceed," which
delayed a merge-ready PR on follow-up decisions unrelated to merge readiness. The
rule "Minor threads must not block a merge-ready PR" was already stated, but the
instructional sequence read as if the ask-and-file steps gated the merge. Moving
the offer to Step 8 cleanly separates merge gating (none for Minor) from
post-merge follow-ups.

**Where** — `wk-pr-merge` Step 4 (Minor or Info branch); follow-up offer in
Step 8 output.
