---
skill: wk-adversarial-review
date: 2026-06-02
type: gap
severity: medium
---

PR-metadata sweep (2.10) missed PR-body drift after a scope-narrowing commit: the body still described the old, broader rule.

**Class:** PR-metadata drift / cross-doc enumeration miss.

**Mechanism:** A commit narrowed a rule (banned set went from "URLs + absolute paths + relative-escape paths" down to "URLs + absolute paths only"). The code and reference docs were updated, but the PR description's "What"/"Why" sections still enumerated the original, broader rule. The agent ran external-reference greps on the *code* diff but never diffed the PR body's rule description against the post-commit rule. A reviewer bot caught it instead.

**Detection sketch:** When a commit in the session changes the scope of an enumerated rule/list (banned items, allowed items, supported flags), extract the rule's item set from the changed source/docs and grep the PR body for any item no longer in the set. Specifically, after a "restrict/narrow/relax/expand X to only Y" commit, re-read the PR body's description of X and confirm it matches the new set — body enumerations drift because body edits are not part of the file diff that the sweeps scan.

**Confidence:** judgment (requires comparing the body's prose enumeration against the code's current rule; partly mechanizable by grepping the body for removed tokens like the dropped `../`).
