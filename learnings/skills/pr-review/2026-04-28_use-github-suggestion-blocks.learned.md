---
skill: wk:pr-review
date: 2026-04-28
type: gap
severity: medium
---

When proposing actionable fixes, use GitHub `suggestion` blocks anchored on the
lines being replaced so the author can apply via the "Commit suggestion"
button in the GitHub UI.

**What happened:** Comments emitted in Phase 5 included Go code blocks showing
the proposed fix, but used standard ` ```go ` fences. The user redirected:
"make the actionable fixes align as ```suggestion``` comments so that those
can be applied automatically in the github UI." The original comments could
not be one-clicked — the author had to copy/paste manually.

**Root cause:** Phase 5 ("Comment format") shows fix snippets with language
fences (`go`, `python`, etc.) rather than the GitHub-specific `suggestion`
fence. The skill never explicitly recommends `suggestion` fences nor explains
the constraints that make them applicable.

**Suggested fix:** Add a new sub-section to Phase 5 — "Use applicable
suggestion blocks for fixes" — covering:

  - Use ` ```suggestion ` fences (not ` ```go ` etc.) when the comment
    proposes a concrete code replacement. Multiple suggestion blocks per
    comment are allowed; each becomes its own commit.
  - The comment must be anchored on the exact lines being replaced. For a
    one-line fix, set `line` to that line and `side: "RIGHT"`. For a
    multi-line replacement, set `start_line` + `line` (and matching
    `start_side` + `side`) to span the range — both endpoints must be in
    the PR diff.
  - The suggestion body must match the file's exact indentation (tabs
    vs. spaces, depth) of the lines it replaces. Pre-fetch the raw lines
    (e.g., `awk 'NR>=X && NR<=Y' file | sed 's/\t/<TAB>/g'`) before
    drafting to verify whitespace.
  - If the lines you want to replace are outside the diff, a suggestion
    block won't be applicable. Either (a) anchor the comment on a nearby
    diff-visible line and keep a plain code-fence example, or (b) note
    that the change is outside the diff and apply it manually. Don't post
    an un-applicable suggestion block — readers expect the apply button.
  - Reply comments inherit the parent's anchor. Reply suggestions only
    work for replacements at the parent's line. If the actionable fix
    spans different lines, prefer a new top-level comment with the
    correct multi-line anchor (and reference the bot/reviewer thread in
    the body) over a reply with un-applicable code.
  - Praise/question/observation comments do not need suggestion blocks.

Add a Phase 4 prerequisite: when a finding has a concrete fix and the target
lines are in the diff, capture the **exact existing line content with raw
whitespace** before drafting Phase 5 — getting indentation wrong silently
breaks the apply-button.
