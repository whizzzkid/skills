---
class: principle
---

**Rule:** Before editing a config file a user named by shorthand (e.g. "in
pipeline.rb", "the CI config"), probe for the canonical location. The shorthand
names the concept, not the path — CI/pipeline step config is often split into
generator/template files. Grep for the step key or command
(`grep -rn '<step-key>' <config-dir>`) and edit the file the grep returns, not
the one the user named.

**Why:** A user's verbal shorthand identifies the pipeline concept, not the
actual file path. Accepting it literally lands edits in the wrong file and
forces a correction. The grep reveals where the step's config truly lives.

**Where:** Step 6 (Execute — Apply Fixes), beside the issue-class scan.
