---
skill: wk-gh
date: 2026-05-20
type: correction
severity: high
---

Model skipped wk-gh invocation before a `gh pr comment` call, rationalizing it as "just a comment."

**What happened:** Agent ran `gh pr comment` directly without invoking `wk-gh` first. The comment posted successfully but was missing the mandatory outbound footer. User had to point out the omission.

**Root cause:** The skill description says "activates whenever the agent uses the gh CLI or interacts with GitHub PRs" but the model applied an implicit size filter — "it's just a comment, not a PR create/edit" — which is not in the skill's rules. Any gh write is the trigger, regardless of perceived complexity.

**Suggested fix:** Add an explicit callout to the skill's trigger section making clear that ALL gh writes — including `gh pr comment`, `gh issue comment`, and reply posts — are in scope. Consider adding "no size exemption" language mirroring how wk-workflow states "there are no exceptions."
