---
skill: wk-pr
date: 2026-07-22
type: gap
severity: low
---

In a repo with generated type-signature artifacts, adding a view-exposed helper method fails the CI verify step on the now-stale generated file.

**What happened:** A new helper method exposed to views (via `helper_method`) fed a codegen/DSL compiler that produces committed type-signature files. The generated file was not regenerated before push, so CI's `verify` step failed on the stale artifact — a red CI step for a pure-mechanical, zero-logic omission.

**Root cause:** The CI-fix loop's known-causes did not flag codegen-artifact staleness as a predictable consequence of adding a construct that feeds a DSL/type compiler; it was discovered reactively via a failing build instead of pre-empted.

**Suggested fix:** Add to the CI-fix-loop known-causes: after adding/removing a `helper_method` (or any construct feeding a DSL/codegen/type compiler), regenerate the artifact (e.g. `bin/tapioca dsl <Class>`) and commit it standalone (per the generated-artifact staging rule) BEFORE pushing, rather than discovering the stale file as a red verify step.
