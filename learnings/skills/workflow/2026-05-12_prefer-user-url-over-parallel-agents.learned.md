---
skill: wk-workflow
date: 2026-05-12
type: correction
severity: medium
---

When the user provides a URL or resource directly, use it immediately — do not spawn parallel exploration agents.

**What happened:** On a PR where the user shared a specific GitHub PR URL to examine ("here's a sample PR: https://github.com/..."), the agent had already dispatched two parallel Agent subagents to explore patch generation and LFS config. Both were immediately interrupted. The user's URL contained exactly the evidence needed and required a single `gh pr diff` call, not parallel agents.

**Root cause:** Agent treated the task as an open-ended investigation and defaulted to parallel exploration. The user had already scoped the investigation by providing a concrete artifact.

**Suggested fix:** Before spawning exploration agents, check whether the user has provided a concrete reference (URL, PR number, file path, error message with line number). If yes, start with that reference — read/fetch it first. Exploration agents are appropriate when no concrete artifact exists. Spawning them when the user has already pointed to evidence is slower and signals inattention to the user's message.
