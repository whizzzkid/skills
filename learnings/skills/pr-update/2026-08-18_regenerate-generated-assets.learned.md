---
skill: wk-pr-update
date: 2026-08-18
type: gap
severity: medium
verified-against-source: yes
---

Generated-asset conflicts (digest manifests, screenshots) should be regenerated from source, not side-picked.

**What happened:** A base merge produced conflicts in a store-asset manifest (source digest hash) and generated screenshots. The agent resolved by taking one side then regenerating, but this pattern repeated 3 times across successive base merges in the same session because each non-asset source change (formatting fix, doc edit) invalidated the digest again — each requiring another regenerate-and-commit cycle.

**Root cause:** The skill's Stage 4 conflict resolution does not distinguish generated artifacts from hand-authored files. Generated files whose content is deterministically derived from source (digest manifests, compiled screenshots, lockfiles with checksums) should always be regenerated from the post-merge source tree rather than textually merged or side-picked. Additionally, any source-file commit after the regeneration (even a formatting fix) invalidates the digest, requiring yet another regeneration — the skill should batch all source fixes before the single final regeneration.

**Suggested fix:** Add a "generated-asset resolution" pattern to Stage 4: (1) identify conflicts in files that are outputs of a build/generate task (manifests with digest hashes, compiled screenshots, lockfiles); (2) resolve by taking either side temporarily and marking for regeneration; (3) defer the regeneration to after ALL other conflict resolutions and source fixes are complete; (4) run the project's regeneration command once, commit the result as the final commit before push. This prevents the repeated regenerate-commit-invalidate cycle.
