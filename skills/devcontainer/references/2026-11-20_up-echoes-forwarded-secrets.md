---
class: principle
source: learnings/skills/devcontainer/2026-11-20_up-echoes-forwarded-secrets.learned.md
date: 2026-11-20
skill: wk-devcontainer
---

**Rule** — Every `devcontainer up` call (first run, retry, trace run) falls under the secret-safe startup-output HARD
RULE whenever Compose forwards a host var, including the `KEY: ${KEY:-}` pass-through form. A leak that already
reached tool output is reported to the user, naming the var, so they can rotate it.

**Why** — The CLI runs `compose config` and logs its full stdout, which interpolates host env values; a forwarded
registry API key landed in a persisted tool-result file.

**Escalation** — Re-violation of the HARD RULE installed 2026-08-05 (well before the report): added one rung
(`**Important:**`) scoping the rule to every call site and the pass-through form. The disclosure clause is a genuine
gap.

**Rejected suggestion** — `devcontainer up ... 2>&1 | tail -n 5` as the remedy: it keeps the secret out of display only
if the last lines happen to be value-free and skips the redaction and canary proof; installed rule wins.

**Where** — `SKILL.md` → Steps 2-4 HARD RULE (Important sub-bullet + disclosure bullet); Common Mistakes credential row;
README Noteworthy.
