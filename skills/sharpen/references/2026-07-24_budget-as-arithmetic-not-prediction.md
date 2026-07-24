---
class: principle
---

**Rule** — The de-bloat byte budget must be arithmetic, not prediction. Before applying
any content-adding fold: byte-measure the *drafted addition* itself (write it to a scratch
file, `LC_ALL=C wc -c` — correct for a bare fragment, never for a `SKILL.md`, whose
front-matter must be excluded via the hook's `measure()`); for a rewrite-style reclaim
measure the *replacement* text too and net it `old - new`; then write the numbers down —
addition, each reclaim's net, the total. A budget that cannot be stated as arithmetic has
not been computed.

**Why** — A fold measured the staged body correctly, picked reclaim targets up front, and
staged/measured once as the rule requires, yet still landed net positive (+43 B). Two of
three budget inputs were estimates: the drafted addition's size was eyeballed from bullet
prose, and rewrite-style reclaims (merging bullets, collapsing a nested list) were scored
as "gross minus a guess" when only the post-edit text reveals the net. Estimating either
side of a ~40 B margin makes the single-pass outcome a coin flip, so an agent can obey
every written instruction and still miss.

**Re-violation → escalation** — At least five prior learnings cover this same
budget/reclaim family (undershoot, one-pass-vs-loop, measure-once, reclaim-before-draft,
net-not-gross); each landed as a prose refinement of the same rule and the failure recurred.
Escalated one notch: the family's sibling sub-bullets sit at `**Very important:**`, so the
new first-pass-prediction rule enters at `**CRITICAL:**`, and carries a mechanical step
rather than more words.

**Not escalated** — The *recovery* half ("a second measure-and-trim cycle is the
re-violation signal — one decisive structural cut, not another prose nibble") worked as
written in the reported run: the agent took a single structural relocation and landed
net -485 B. Positive-steering evidence blocks escalating that bullet.

**Already covered, not re-folded** — "Prefer delete-outright and relocate-large-block
reclaims over merge/collapse rewrites" is already stated in the "content-removing
structural moves" bullet; the new rule cites its measurement discipline instead of
restating the preference.

**Where** — Step 7.5, first sub-bullet under "Measure the staged body BEFORE drafting any
content-adding fold".
