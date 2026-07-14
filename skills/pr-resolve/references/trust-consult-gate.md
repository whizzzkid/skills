---
class: principle
---

# Trust the consult gate; never re-confirm decided actions mid-execution

**Rule.** Once the consult phase (Step 5) has collected a decision for an item,
Step 6 executes it without pausing to ask "proceed?" on that item. The only
in-flow stop during execution is a verification failure. Re-asking on an
already-decided action violates the skill's explicit decision-collection gate
and wastes the user's time.

**Why.** The skill front-loads all tradeoff decisions into one consult phase
precisely so execution runs unattended. A field re-violation (agent re-prompted
mid-execution on Step-5-decided actions) proved the existing final-gate rule
(Step 7) did not cover the *execution* moment — the failure site had no rule.

**Where.** Step 6 opening `**Important — Step 5 decisions are binding …**`;
reinforced by Step 5 Auto-Mode ("act and report; never confirm per-item") and
Step 7 ("do not re-ask 'proceed?' after a fully decided Step 5").
