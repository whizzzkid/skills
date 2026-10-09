---
name: wk-preso
description: >-
  Use when creating a presentation, slides, powerpoint, preso, or slide-deck —
  generates an interactive, accessible, self-contained HTML slide deck published
  as an Artifact with dark/light mode, keyboard navigation, auto-transition,
  hash-based deep linking, and author branding.
argument-hint: "<topic or outline>"
user-invocable: true
model-invocable: true
disable-model-invocation: false
model: sonnet
effort: medium
group: communication
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Artifact
  - Skill
  - AskUserQuestion
metadata:
  author: whizzzkid
  version: "2026.08.18-214753"
  internal: false
  model:
    claude: claude-sonnet-4-6
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
---

# Preso

Generate a fully interactive, self-contained HTML slide deck and publish it as
an Artifact.

## When to Use

- User asks to create a presentation, slides, powerpoint, preso, slide-deck,
  deck, or keynote.
- A task produces content better communicated as a slide sequence.

## Step 1: Gather Content

- If the user provided a topic or outline, use it directly.
- If vague, ask once for the key points or structure — then proceed.
- Research the topic as needed (read files, search, etc.) to build substantive
  slide content.

## Step 2: Load Design Skill

- Invoke `artifact-design` via Skill tool before writing the HTML — it
  calibrates the design investment for this deliverable.

## Step 3: Author the Slide Deck

Write a single self-contained HTML file to the scratchpad. Every requirement
in [references/html-template.md](references/html-template.md) is mandatory —
the deck is not done until all are met. Covers: layout/navigation, deep linking,
auto-transition, dark/light theme, color/animation, time-based content,
diagrams, accessibility (WCAG AA), author branding, responsive design, and
self-contained constraints.

## Step 4: Fetch and Embed Avatar

```bash
curl -sS -o /tmp/avatar.png "https://avatars.githubusercontent.com/u/1895906?s=64"
base64 < /tmp/avatar.png
```

Embed the result as `data:image/png;base64,...` in the HTML.

## Step 5: Publish

- Publish via Artifact tool with:
  - `favicon`: topic-appropriate emoji (e.g. `"📊"` for data, `"🚀"` for launch).
  - `description`: one-sentence summary of the deck's subject.
- On update, use the same `file_path` to redeploy to the same URL.

## Step 6: Verify

- Confirm the Artifact URL is live.
- Report the link to the user with the slide count and key features.

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| `/wk-preso <topic>` | Generate and publish a slide deck on the topic |
| "make a presentation about X" | Auto-invoked, same flow |
| "create slides for Y" | Auto-invoked, same flow |
