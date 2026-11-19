---
skill: wk-sitrep
date: 2026-11-19
type: gap
severity: low
verified-against-source: no
---

Final-stage learning capture failed when batched with a commit command in one response.

**What happened:** The last stage issued the learning-capture Skill call in the same response as the shell command that patched, opened and committed the page. The auto-mode classifier returned no verdict for the Skill call and asked for a retry in its own response; the retry succeeded.

**Root cause:** (unverified — inferred from symptom) A Skill call batched with a state-changing shell call in the same response is not reviewed reliably by the classifier.

**Suggested fix:** In the closing stage, say the capture/learning Skill call goes in its own response after the commit output is seen, not alongside it.
