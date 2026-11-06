---
skill: wk-sitrep
date: 2026-11-06
type: gap
severity: low
verified-against-source: n/a
---

Connectors a gathering subagent cannot see may still be callable in the orchestrator; probe them there before labelling a gap.

**What happened:** A gathering subagent reported one connector as unavailable, so three carry-over items would have stayed "not reverified". Loading the connector in the main session resolved one item with hard evidence (a submitted scorecard with a timestamp).

**Root cause:** Subagents do not reliably inherit the orchestrator's connectors, so `tool_unavailable` from an agent is not proof the connector is missing.

**Suggested fix:** On a subagent `tool_unavailable`, replay that domain's carry-over checks in the main session before recording a gap. Also: when driving an in-place transform with an awk spec file, pass the spec only via `-v`/getline, never as an input file argument, or its lines leak into the output.
