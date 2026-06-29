---
skill: wk-pr-resolve
date: 2026-06-29
type: correction
severity: medium
---

Probe for the actual pipeline step config file location before editing based on the user's description.

**What happened:** User said to edit retry config "in pipeline.rb". The step's retry config actually lived in a templates directory (`templates/tier_check.rb`), not the top-level pipeline file. The agent needed to be corrected after starting in the wrong file.

**Root cause:** Pipeline config is often split across generator/template files in CI setups. The user's shorthand ("pipeline.rb") named the pipeline concept, not the actual file path. The agent accepted the shorthand literally without verifying where the step's config actually lives.

**Suggested fix:** Before editing any CI/pipeline file for a specific step, grep for the step key or command to find the canonical config location: `grep -r "command.*<step_name>\|key.*<step>" .buildkite/`. Edit the file the grep returns, not the file the user named by shorthand.
