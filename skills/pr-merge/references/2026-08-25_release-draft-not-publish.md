---
class: principle
source: learnings/skills/pr-merge/2026-08-25_release-draft-not-publish.md
---

# Draft release does not create a git tag

GitHub only materializes a git tag when a release is published, not when it
is created as a draft. When the user requests "create a release that also
creates a tag," a --draft release does not satisfy the tag requirement.

The skill now has Step 7.5 to handle post-merge release creation, including
the draft-vs-publish confirmation gate.
