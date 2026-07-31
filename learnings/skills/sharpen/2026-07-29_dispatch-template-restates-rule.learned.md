---
skill: wk-sharpen
date: 2026-07-29
type: gap
severity: medium
verified-against-source: yes
---

A skill's own dispatch/spawn prompt template restates a selection rule in its own words, so
folding the rule leaves the template as a second, silently-drifted copy.

**What happened:** A fold added an intra-severity tie-break to the batch-mode queue-ordering
rule. Reading the skill's reference files during Step 2 surfaced that its loop-mode spawn
prompt — the literal text the skill tells itself to hand a background cycle — independently
phrased the selection as "drain the oldest unprocessed learning", omitting the severity sort
the same skill prescribes two files away. The template was already wrong before the fold
(oldest-regardless-of-severity contradicts severity-ordered) and the fold would have shipped
it still wrong. Nothing in the Step 7 drift check names dispatch templates; the check
enumerates description, argument-hint, allowed-tools, quick-reference/trigger tables, and the
step list.

**Root cause:** Confirmed by reading both files. A prompt template is prose the skill emits,
not a link, so no cross-reference check can see that it encodes a rule stated elsewhere.
`check-reference-orphans.sh` and `check-links.sh` validate link targets and both passed with
the contradiction in place — a paraphrase is invisible to a link checker by construction. The
drift check's enumerated surfaces are all *metadata* about the skill; a template is content,
so it falls outside every listed item while behaving exactly like a duplicated rule.

**Suggested fix:** Add dispatch/spawn prompt templates to the Step 7 drift check's enumerated
surfaces, and state the trigger: a fold that changes an ordering, selection, or scoping rule
must grep the skill's own reference files for prompt templates that phrase the same selection
independently, and re-sync them in the same pass. Generalize beyond prompts to any place the
skill quotes itself — a template is a rule copy the link checkers cannot reach.
