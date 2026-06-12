---
skill: wk-gh
date: 2026-06-11
type: correction
severity: high
---

Every outbound GitHub message must use the canonical wk-gh Step 4 footer verbatim — never a freeform attribution string.

**What happened:** Six reply comments posted to a PR used `*Assisted by Claude Code (claude-sonnet-4-6)*` instead of the canonical footer defined in wk-gh Step 4. The correct footer is:

```
---
<sup>Generated using [wk-skills](https://github.com/whizzzkid/skills) and multiple agents/models. DM me your feedback.</sup>
```

The wrong string was written inline at payload-render time rather than injected from the canonical template.

**Root cause:** The comment payloads were composed ad-hoc without consulting the wk-gh Step 4 template. The skill states "inject the footer at template-render time so a forgotten append cannot ship a footer-less message" — constructing payloads outside the template defeats this guarantee.

**Suggested fix:** Add an explicit pre-flight check in the skill: before constructing any outbound comment body, read the Step 4 footer verbatim from the skill text and append it to the payload template. Never hand-write the attribution string — always paste the literal from the skill.
