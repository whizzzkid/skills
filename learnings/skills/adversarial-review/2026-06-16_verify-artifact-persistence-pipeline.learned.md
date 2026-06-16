---
skill: wk-adversarial-review
date: 2026-06-16
type: pattern
severity: medium
---

Verify cross-step file persistence by reading the pipeline template before flagging it as a gap.

**What happened:** Adversarial subagent raised a `question`-severity finding about whether `tmp/tier.txt` written by one CI step would persist to a downstream step. The file was indeed uploaded as a Buildkite artifact by the first step and downloaded by the second — confirmed by reading the pipeline template files under `.buildkite/pipelines/<pipeline>/templates/`.

**Root cause:** The review looked at the Ruby source but not the CI orchestration layer. Script-level file I/O that crosses step boundaries always has a pipeline artifact contract.

**Suggested fix:** When a finding claims a file written in step A won't reach step B, grep the pipeline templates for `artifact_upload` / `artifact_download` / `artifacts: upload/download` matching that path before classifying the finding as `blocker` or `question`. If confirmed uploaded+downloaded, the concern is resolved and should not be surfaced.
