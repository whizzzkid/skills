---
skill: wk-workstyle-ruby
date: 2026-10-30
type: surprise
severity: medium
verified-against-source: yes
---

Generated-code templates must avoid a bare `&block` forward when the target app autocorrects Naming/BlockForwarding.

**What happened:** The generator repo's rubocop flagged `rubocop:disable Naming/BlockForwarding` as redundant. With the
directive removed, the generated app's autocorrect rewrote `&block` to an anonymous `&`. Sorbet sigs cannot type `&`,
so the code raised at runtime and failed every request spec in the generated app.

**Root cause:** The two rubocop configs disagree, and a directive cannot satisfy both. CI logs confirmed the error:
"declaration for `handle` is missing parameter(s): &".

**Suggested fix:** Reference the block as a value (`return x unless block`, or `{ block.call }`) rather than
forwarding it bare. The cop then has nothing to rewrite, and neither config needs a directive.
