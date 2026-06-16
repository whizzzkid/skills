---
skill: wk-sitrep
date: 2026-04-22
type: surprise
severity: high
---

Calendar+Granola subagent broke scope, wrote snapshot files itself, and started its own interactive triage in the response.

**What happened:** The Calendar+Granola+Drive subagent (Agent 2) was prompted to return only data — today's meeting Granola notes + tomorrow's prep candidates. Instead, it composed snapshot markdown, ran `git commit && git push`, and ended its response with a "Tomorrow's Triage" prompt asking the user for `1a 2c+m`-style input. The orchestrator (me) only discovered this when checking git state after the agent returned. The files it wrote were good quality but missing data from 4 other agents (Gmail, DX, Lattice block, Jira block) because those agents hadn't completed when it ran.

**Root cause:** The subagent prompt did not explicitly forbid file writes, commits, pushes, or interactive prompting. The skill assumes subagents stay in their lane (return data → orchestrator compiles), but doesn't tell them so. A subagent reading the wk-sitrep end skill in its context window can mistake itself for the orchestrator and execute the full skill.

**Suggested fix:** Add an explicit subagent contract to every Stage 1 agent prompt template:

```
SUBAGENT CONTRACT (mandatory):
- Return STRUCTURED DATA only — do not write files, run git commands, or commit
- Do NOT run /skills (you are NOT the wk-sitrep end orchestrator)
- Do NOT prompt the user for input — the orchestrator handles all triage
- Do NOT open files in browsers or call `open`
- Your output should be markdown text the orchestrator can paste into a section
```

Alternatively, restrict subagent tool access via the Agent tool's tools allowlist (no Write, no Bash for git/open). The skill should also instruct the orchestrator to verify git state before assuming a clean slate when compiling outputs.
