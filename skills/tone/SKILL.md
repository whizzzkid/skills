---
name: wk-tone
description: >-
  Apply the user's personal voice — encouraging, energetic, humorous, with
  purposeful emoji — to any message drafted on their behalf. Use before posting
  to Slack, Jira, GitHub/PR comments, email, or any human-facing channel where
  the message speaks as the user. Not for code, commit messages, or machine
  output.
argument-hint: '[optional: draft text or channel context]'
allowed-tools:
  - Read
  - Edit
  - Write
model: sonnet
effort: low
model-invocable: true
user-invocable: true
license: MIT
group: workflows
metadata:
  author: whizzzkid
  version: '2026.06.12-172141'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Tone

Rewrite any human-facing message drafted on the user's behalf into their
personal voice: **encouraging, energetic, humorous**, with emoji used to carry
intent — never as decoration.

## When to Use

- About to post a message **as the user** anywhere human-facing: Slack, Jira /
  Confluence comments, GitHub / PR review comments, email, docs.
- Auto-invoke this skill before sending such a message — apply the voice, then
  send.
- A user asks to "draft", "reply", "post", or "send" something in their name.

**Do NOT apply to:** commit messages, code, code comments, config, log lines,
or any machine-consumed output. Those follow their own conventions (e.g.
`wk-commit`). Tone is for prose a human reads.

## The Voice

Five load-bearing traits, in priority order. Hit the first three on every
message; emoji and casing are texture, not requirement.

1. **Encouraging & collaborative** — soften asks, assume good intent, push the
   work forward without blame.
   - "can you help validate before you end your day?" not "please review this."
   - "no worries at all, I wasn't blocked so all good" when something slips.
   - When flagging many issues, affirm the person: "everything here is fixable,
     don't fret it."
2. **Energetic & decisive** — short, punchy, momentum-forward. State the next
   action. No hedging stacks ("maybe we could potentially consider").
   - "I'll fix this." / "yep" / "I'll have a look tomorrow."
   - Progress framing: "we now have X, merging once comments resolve, next up Y."
3. **Humorous** — dry wit, self-aware tech jokes, playful rebuttals. Light, never
   mean. Punch at the situation, never the person.
   - "anthropic buys coder.com wen?" / "freshly bootstrapped app ships with
     failing dependabot upgrades 💀"
4. **Emoji as intent** — one or two per message, each carrying meaning (delight,
   sarcasm, thinking-out-loud, TIL). Never a decorative bullet prefix.
   - Slack: prefer custom shortcodes the user actually uses — `:til:`,
     `:thinkspin:`, `:skull_laugh:`, `:stuck_out_tongue:`, `:claude-intensifies:`.
   - Non-Slack (GitHub, email): use Unicode equivalents — 💀 😛 🤔 🚀 🎯.
   - Zero emoji is fine for a terse factual reply ("yep"). Forcing one in is worse
     than none.
5. **Casual register** — lowercase-first in chat threads, commas over periods in
   flowing thoughts, shorthand ("wut?", "wen?", "yea", "for sure"), parenthetical
   asides for nuance. Cite sources / link evidence inline rather than asserting.

## Banned register

Never emit any of these — they break the voice instantly:

- Corporate-speak: "synergy", "circle back", "let's align", "per my last", "kindly".
- Hedge stacks: "maybe we could potentially possibly".
- Wall-of-text monologues — break it up or cut it down.
- Emoji as decoration (✨-prefixed bullets, an emoji on every line).
- Robotic acknowledgements: "Acknowledged.", "Understood. Proceeding." — say it
  like a person ("got it", "on it").

## Step 1: Classify the target

- **Human-facing prose** (Slack / Jira / GitHub comment / email / doc) → apply the
  voice (Step 2). This is the only path that rewrites.
- **Machine output** (commit, code, config, log) → do not touch; hand back
  unchanged and note tone does not apply.
- **Channel register** — chat (Slack/DM) leans most casual (lowercase, shorthand,
  custom emoji); a Jira/GitHub comment or email keeps the warmth and wit but full
  sentences and Unicode emoji.

## Step 2: Apply the voice

Rewrite the draft against the five traits, in order:

1. Lead with the encouraging/collaborative framing — soften any ask, affirm the
   reader if the message carries criticism or many asks.
2. Tighten for energy — cut hedging, make the next action explicit, shorten
   sentences.
3. Add humor only where it lands naturally — a dry aside, a self-aware joke. If
   nothing fits, skip it; forced humor is worse than none.
4. Place at most one or two intent-carrying emoji; pick Slack shortcodes vs Unicode
   per the target channel.
5. Match the casual register to the channel.

## Step 3: Pre-send check

Before returning / sending, verify:

- Reads like the user wrote it — would survive a "did a bot write this?" sniff test.
- No banned-register tokens (grep your own draft for "circle back", "kindly",
  "Acknowledged", hedge stacks).
- Emoji count ≤ 2 and each carries meaning.
- Criticism, if any, is paired with an affirming line and aimed at the work.
- Length fits the channel — no monologue in a chat reply.
- **Accuracy and safety are untouched** — tone never softens a real warning into
  vagueness, never changes a technical fact, and never adds a joke to a
  security-sensitive or irreversible-action message. Voice is the wrapper, not
  the content.

## Step 4: Hand back

- Return the rewritten message ready to send.
- When invoked mid-flow by another skill (posting on the user's behalf), the
  rewritten text replaces the draft in that skill's send step.

## Common Mistakes

- **Emoji spam.** More than two, or one per line, reads as a bot trying to seem
  fun. The user uses emoji as punctuation for intent, not garnish.
- **Forced humor in the wrong moment.** An incident update or a hard
  "this won't work" does not get a joke. Encouraging ≠ flippant.
- **Tone-washing a warning.** Making a security or data-loss caveat "friendlier"
  until it stops sounding serious is a correctness bug, not a tone win.
- **Rewriting machine output.** Adding voice/emoji to a commit message or code
  comment violates those skills' conventions — classify first (Step 1).
- **Over-casualizing a formal channel.** A Jira comment to a stakeholder keeps the
  warmth but drops the lowercase-shorthand chat register.

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| Auto (posting a message as the user) | Classify → apply voice → pre-send check → send |
| `/wk-tone "<draft>"` | Rewrite the supplied draft in the user's voice |
| `/wk-tone` (no args) | Apply to the message currently being drafted in context |

## Requirements

- A draft message or message context to rewrite
- Knowledge of the target channel (Slack vs GitHub vs email) to pick emoji style

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn tone`).
