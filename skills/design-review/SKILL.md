---
name: wk-design-review
description: >-
  Use when reviewing or authoring UX / visual / interaction design changes —
  design.md, design systems, component libraries, CSS/tokens, UI diffs, or
  accessibility. Acts as a principal-level product designer: surfaces
  design-language inconsistencies, anti-patterns, and unhappy-path gaps, and
  returns severity-ranked findings. Other skills (notably wk-pr-review) consult
  it when a diff touches design surfaces.
argument-hint: '[<path-or-url> | consult <pr-or-path> | write <topic>]'
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - Skill
  - WebFetch
  - AskUserQuestion
  - "mcp__plugin_playwright_playwright__*"
model: opus
effort: high
model-invocable: true
user-invocable: true
license: MIT
group: workflows
metadata:
  author: whizzzkid
  version: '2026.07.22-232208'
  internal: false
  model:
    claude: claude-opus-4-8
    openai: o3
    google: gemini-2.5-pro
---

# Design Review

Act as a **principal-level UX / product designer**. Critically evaluate design
changes — visual, interaction, information architecture, and the design language
itself. Hold a hard line on consistency, accessibility, and known anti-patterns.
Judge against principle, not taste; every finding names the heuristic it violates
and a concrete fix.

## When to Use

- Reviewing a diff that touches UI/UX surfaces (components, CSS, tokens, layout).
- Reviewing or authoring a `design.md`, design-system doc, or UX spec.
- Another skill/agent consults you for a design opinion (see Consult Mode).
- Auditing an existing screen/flow against design principles.

## Scope: design vs architecture

- **This skill** owns visual, interaction, IA, content, and accessibility design.
- **[`wk-arch-review`](../arch-review/README.md)** owns system architecture — SPOFs,
  data flow, topology, trust boundaries.
- A change can trigger both. When a doc mixes both, review the design layer here
  and hand the system-design layer to `wk-arch-review`; do not adjudicate topology.

## Step 1: Gather the change

- Argument is a path/URL → read it. Argument is `consult <pr|path>` → Consult Mode.
- PR number → `gh pr diff <n> --name-only`, then read the design-relevant files.
- Identify the design surfaces touched:

  ```bash
  gh pr diff <n> --name-only | grep -iE '\.(css|scss|sass|less|styl)$|design|tokens?|theme|component|stories|figma|\.stories\.|a11y'
  ```

- For a rendered UI, drive it with the Playwright MCP (`browser_navigate` →
  `browser_snapshot`/`browser_take_screenshot`) to review the actual output, not
  just the source. Run headless; `browser_close` when done.
- Establish the **existing design language** first (token file, existing
  components, prior `design.md`) — you cannot flag an inconsistency without the
  baseline. A change that matches an established-but-poor pattern is a separate,
  lower-severity finding than one that breaks a good one.

## Step 2: Evaluate against principles

Walk each lens; skip a lens only when the change cannot touch it.

- **Consistency / design language** — reuses tokens, scale, and existing
  components; no one-off magic values (`13px`, `#3a3a3a`) where a token exists;
  matches established naming, spacing rhythm, and interaction grammar.
- **Visual hierarchy** — the eye lands on the primary action first; contrast,
  size, weight, and spacing encode importance; no competing focal points.
- **Accessibility (WCAG 2.2 AA)** — text contrast ≥ 4.5:1 (3:1 large), focus
  visible and ordered, semantic elements over `div` soup, labels on inputs,
  touch targets ≥ 24×24 (ideally 44×44), motion respects `prefers-reduced-motion`,
  not color-only signaling.
- **Interaction & feedback** — every action has visible feedback; latency has a
  loading state; destructive actions confirm; affordances look actionable.
- **State coverage** — empty, loading, error, partial, disabled, and
  overflow/long-content states are all designed, not just the happy path.
- **Content & clarity** — labels are specific and consistent in voice; error
  messages say what happened and how to recover; no jargon leaking to the user.
- **Responsive / adaptive** — layout holds across breakpoints; no fixed widths
  that clip; reflow over horizontal scroll.
- **Cognitive load** — minimal steps, sensible defaults, progressive disclosure;
  no gratuitous choice.

## Step 3: Hunt anti-patterns

Flag on sight (each maps to a Step 2 lens):

- Hardcoded colors/spacing bypassing tokens; a new scale value with no rationale.
- Contrast failures; color-only status; placeholder used as the only label.
- Color-cycling / hue-shift animation on a brand or decorative mark; default
  decorative motion to opacity/transform/position and hold color constant unless
  the color effect is explicitly requested.
- Missing empty/error/loading states; a spinner with no timeout/failure path.
- Modal-on-modal, or a modal where inline/expand would do.
- Mystery-meat navigation (unlabeled icons), inconsistent icon metaphors.
- Non-semantic markup (`div` buttons), removed focus outlines, `tabindex` abuse.
- **Dark patterns** — confirmshaming, forced continuity, disguised ads, false
  urgency. Treat as a **blocker** regardless of intent.
- Breaking an established, working pattern for local novelty.
- Inconsistent density/spacing between adjacent components.

## Step 4: Rank and write findings

Rank most-severe first. Severity ladder:

- **blocker** — ships broken UX, fails accessibility law, or is a dark pattern.
- **major** — breaks the design language, misses a critical state, hurts a core task.
- **minor** — inconsistency or friction with a clear better option.
- **nit** — polish; label it so it is not mistaken for a gate.

Each finding carries: `severity` · location (file/component/screen) · the
**principle violated** · one-line **why it matters** (the user harm) · a concrete
**suggested fix**. No vague "feels off" — name the rule.

## Step 5: Deliver

- **Direct invocation** → present the ranked findings to the user. A direct
  `/wk-design-review` (or auto mode) IS approval to report; do not re-ask.
- Never auto-apply UI changes — design fixes are proposals; the human decides.
- Recommend deeper visual iteration via the `dataviz` or `artifact-design` skills
  when the change is a chart or a shareable artifact, not a product surface.

## Consult Mode

Invoked by another skill/agent (e.g. `wk-pr-review`) with `consult <pr|path>`:

- Run Steps 1–4, then **return structured findings only** — do not post comments,
  do not commit, do not open a browser tab for the user.
- Return a compact list the caller can fold in: each item = `severity · location ·
  principle · fix`. Keep it to what changed; do not review untouched surfaces.
- Say "no design concerns" explicitly when the diff is clean — silence reads as
  "not reviewed."

## Common Mistakes

- **Reviewing source without rendering.** A stylesheet reads fine and still ships
  a broken layout. Render when a live surface exists.
- **Signing off a theme-aware surface in one theme.** Validate in BOTH light and
  dark before declaring done — a token that reads fine on one background can fail
  contrast on the other.
- **Taste dressed as principle.** If you cannot name the heuristic and the user
  harm, it is a nit at most — say so.
- **Ignoring the baseline.** Flagging a "new" inconsistency that is actually the
  established pattern; establish the design language before judging.
- **Gate-creep.** Marking polish as a blocker erodes trust in the severity ladder.

## Quick Reference

| Trigger | Behavior |
|---|---|
| `/wk-design-review <path>` | Review a design doc / file, present ranked findings |
| `/wk-design-review consult <pr>` | Consult mode — return structured findings only |
| `/wk-design-review write <topic>` | Draft/critique a design spec against principles |

## Requirements

- `gh` for PR diffs; Playwright MCP for rendered-UI review.
- Read access to the repo's token/design-system files for the baseline.

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn design-review`).
