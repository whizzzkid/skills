---
skill: wk-workflow
date: 2026-06-08
type: correction
severity: medium
---

Prefer extending an existing skill with a new mode over creating a new skill when the functionality is a new verb on the same noun.

**What happened:** Agent created a separate `{skill}-{verb}` skill for a new sub-command, then had to revert and fold it into the existing `{skill}` skill when the user redirected.

**Root cause:** Planning step didn't probe whether the new capability belongs as a mode of an existing skill vs. a standalone skill. The user expected `/{skill} {verb}` — a subcommand — not a new `/{skill}-{verb}` entry point.

**Suggested fix:** Before scaffolding a new skill for a new command/action, ask: "Is this a new verb on an existing noun that already has a skill?" If yes, add a routing mode to the existing skill rather than creating a parallel one. New skills are warranted only for genuinely distinct workflows with different argument shapes, tool sets, or user mental models.
