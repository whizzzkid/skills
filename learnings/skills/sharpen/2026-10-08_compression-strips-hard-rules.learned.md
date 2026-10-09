---
skill: wk-sharpen
date: 2026-10-08
type: gap
severity: high
verified-against-source: yes
---

Bulk de-bloat agents stripped HARD RULE labels and boilerplate triggers while claiming "all rules preserved".

**What happened:** Prose-compression sub-agents reported every HARD RULE intact, but counts fell to zero in several skills (labels demoted to plain prose; some clauses lost). A cross-cutting pass also deleted each skill's Post-Completion `wk-learn` trigger with no replacement, silently disabling learning capture.

**Root cause:** Sub-agent self-reports were accepted without a mechanical check; "boilerplate" was judged by repetition, not by whether it is a runtime trigger.

**Suggested fix:** After any de-bloat, gate on a per-skill HARD RULE count across SKILL.md + references (now `check-hard-rules.sh`) and phrase-audit each original rule; never delete a repeated section that invokes another skill unless its replacement ships in the same commit.
