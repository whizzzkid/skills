---
skill: wk-goodmorning
date: 2026-04-24
type: gap
severity: medium
---

wk-goodmorning always generates morning.html from scratch using an inline template in the skill, even when the user has a preferred template stored in the repo. Same for morning.md. This causes daily drift (minor styling changes, reordered sections, regenerated CSS) and blocks the user from evolving their own design without editing the skill.

**What happened:** Over several days, the morning.html produced by wk-goodmorning shifted in small ways — CSS tokens slightly different, section ordering inconsistent across runs, some cards present one day and missing the next. The user said "I like this template more than the ones generated before" and asked for a reusable skeleton at `<repo_root>/_templates/morning/brief.html` that the skill should adopt day-over-day instead of regenerating.

**Root cause:** The skill's Stage 2c ("write morning.html") specifies the full HTML structure inline and re-emits it on every run. There is no step that checks for a user-maintained template in the repo. Same applies to Stage 2b (morning.md) — the markdown outline lives in the skill, not the repo. The user's design preferences have no durable place to live.

**Suggested fix — Template discovery and population (Stage 2 rewrite):**

1. **Template discovery** — at the start of Stage 2, look for templates in this order and use the first one found:
   - `<repo_root>/_templates/morning/brief.html` (HTML)
   - `<repo_root>/_templates/morning/brief.md` (markdown)
   - Built-in skill template (current behaviour) — fallback only

2. **Contract** — a template is valid if it contains:
   - Scalar placeholders as `{{KEY}}` (e.g. `{{DATE_ISO}}`, `{{DATE_LONG}}`, `{{STORAGE_KEY}}`)
   - Block slots as `<!-- SLOT:name -->` HTML comments (or `<!-- SLOT:name -->` even in markdown — treated as text marker)
   - Standard slot names: `resolved_badges`, `priorities`, `calendar`, `meeting_followthrough`, `carryover`, `slack_response`, `slack_followup`, `slack_announce`, `slack_count`, `slack_response_count`, `slack_followup_count`, `email_response`, `email_followup`, `email_announce`, `email_count`, `email_response_count`, `email_followup_count`, `github_review`, `github_yours`, `github_issues`, `github_count`, `github_review_count`, `github_yours_count`, `github_issues_count`, `jira_assigned`, `jira_mentions`, `jira_count`, `jira_assigned_count`, `jira_mentions_count`, `lattice`, `peer_feedback`.

3. **Population flow** — Stage 2 becomes:
   1. Discover template (path above or fallback).
   2. Load template as string.
   3. Replace scalar `{{KEY}}` tokens.
   4. For each slot, build the HTML fragment for that section from the triaged data and replace the slot marker (or the whole line containing it, to keep indentation clean).
   5. If a slot has no content, inject `<div class="empty">...</div>` — never leave a naked `<!-- SLOT:name -->` in the output.
   6. Write the resulting string to the date-stamped output path as today.

4. **Consistency guarantee** — because the skeleton is loaded from disk, design changes the user makes to the template persist automatically. The skill's job is reduced to: gather data, triage, emit slot fragments. Rendering is external.

5. **Bootstrap** — if no template exists, optionally offer to create one from the skill's built-in template on first run (so users can then tweak it).

6. **Slack-first priority links (ties to previous learning)** — the template makes the source-link rule structural: the `priorities` slot fragment builder MUST emit inline `slack ↗ · doc ↗ · zoom ↗` chips alongside every priority that maps to an external artifact. Embed this rule in the slot builder so it is impossible to forget.

**Benefits:**
- User owns the design — style tweaks live in the repo, not in skill code.
- Daily output is deterministic — same template in = same shell out, only content varies.
- Other sitrep skills (wk-goodevening) can follow the same pattern: `<repo_root>/_templates/evening/brief.html`.
- Skill code becomes simpler (data + slot fragments) and easier to evolve.

**Related learning:** `2026-04-24_priorities-need-source-links.md` — should be folded into the priorities slot builder so link-injection is enforced at render time rather than trusted to per-run judgment.
