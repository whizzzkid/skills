---
skill: wk-pr-resolve
date: 2026-06-26
type: correction
severity: high
---

Bot finding about swallowed errors in a critical publish script must be classified obvious-fix, not judgment-required.

**What happened:** A bot flagged that a publish script's error-handling path was fail-open (query errors silently resolved to "not published", allowing the upload to proceed on uncertain state). The agent treated it as judgment-required due to the "always exit 0" behavior being intentional-looking. User corrected: "this should fail the build if we're unable to publish, the error should not be swallowed."

**Root cause:** The agent saw existing silent-return behavior and classified "change to fail-closed" as a design tradeoff requiring consultation. In a CI publish step, fail-closed is the correct default for any query or API uncertainty — swallowing errors and proceeding risks data-integrity issues (duplicate publishes, missed publishes). The skip rationale was empty and the bot was correct.

**Suggested fix:** In Step 4 classification, add a heuristic: a bot finding that names swallowed errors, silent returns, or fail-open behavior in a script that writes/publishes external artifacts → classify as obvious-fix unless the calling context explicitly requires idempotent pass-through. Empty skip rationale + CI publish context = obvious-fix, not judgment-required.
