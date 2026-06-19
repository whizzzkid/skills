---
skill: wk-workflow
date: 2026-06-18
type: correction
severity: medium
---

Implemented a version format derived from user-provided examples without verifying the exact scheme before writing code.

**What happened:** The initial feature request showed a version string as `beta-PR<N>-<sha-7>`. The agent implemented this literally. The user then corrected to `beta-<sha-7>` (drop the PR number), then again to `beta-<full_sha>` (use the full 40-char SHA). Two separate corrections were needed to arrive at the right format.

**Root cause:** The original request contained an example format in a CLI snippet (`cloudsmith ls pkgs ... -q 'name:... AND version:beta-PR<N>-<sha-7>'`). The agent used that example as the spec without asking the user to confirm the exact production version format. The example was illustrative, not normative.

**Suggested fix:** When a feature request includes an example version/naming string, treat it as illustrative unless the user confirms it is the exact production format. Ask one clarifying question up front ("Is `beta-PR<N>-<sha-7>` the exact format, or is this an example?") before implementing anything that encodes the format across multiple files (code, specs, docs).
