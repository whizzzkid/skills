---
skill: wk:sharpen
date: 2026-04-30
type: correction
severity: high
---

Step 5 audit failed to catch overfitted tokens (specific bot login, organization-prefixed names, project-specific IDs) that landed in distilled skill instructions across multiple sessions.

**What happened:** During multiple back-to-back sharpen runs into `wk:pr-resolve`, the distilled instructions embedded the literal bot login of a specific organization's review-automation bot (`{bot}`) — once in a suggestion-format example, twice in failure-mode descriptions. The user caught the violation on a later turn ("why did you add specific names of the bots in the learnings? sharpen is supposed to distill the learnings not match exact scenarios"). On audit, the same overfit pattern existed in three places in `pr-resolve/SKILL.md`. The whole point of `wk:sharpen` is to extract principles, not embed examples — Step 3's "Remove" list explicitly names "Names of reviewers, PRs, or commits"; Step 5's audit and the Anti-Patterns table both restate the rule. The audit fired on every run and missed it every time.

**Root cause:** Step 3's removal list and Step 5's audit are described in prose, with no mechanical check the agent runs against the proposed diff. The agent reads the rule, internalizes it as a *principle*, and then writes instructions that paraphrase the source incident's specific tokens — at which point the audit step asks "does this look overfitted?" with the same brain that just wrote the overfit. Confirmation bias does the rest. Two structural gaps: (a) no concrete grep / scan step against the proposed diff before Step 6 presents it; (b) no checklist of token *categories* the audit must scan for (org prefixes, bot logins, repo names, ticket prefixes, runner-group names, file paths). Without a categorical checklist, the audit defaults to "looks fine to me."

**Suggested fix:** Add a mechanical pre-presentation scan to Step 5. Before any `Step 6: Present for Review`, the agent must run a checklist-driven grep against the **proposed diff**, not against memory or intent. Categories to scan for (this list lives in the skill; it grows as new categories surface):

- **Reviewer/bot logins** — anything matching `\[bot\]`, `@[a-z0-9_-]+`, or a known automation name. If matched, replace with a generic descriptor (`{reviewer}`, "review-automation bots that re-create their review per push").
- **Organization prefixes** — known org tokens (e.g., `$EMPLOYER-`, `acme-`, etc.), org-managed runner group naming patterns. Replace with the *behavior* (e.g., "an organization-managed runner group that enforces an action allowlist").
- **Specific ticket IDs** — `[A-Z]+-\d+` outside of placeholder examples explicitly framed as illustrative format references.
- **Specific repo / file / package names** — concrete project names that don't generalize.
- **Specific line numbers / SHAs / PR numbers** — `:\d+`, short SHAs, `#\d+` outside of legitimate template slots.
- **Specific tool versions** — exact versions cited in failure descriptions when the failure pattern is version-agnostic.

For each match, the agent must either (a) replace with the generic mechanism / pattern, or (b) explicitly justify why the literal token is required (e.g., it is a stable API name like `PRRT_*`, an error message that is verbatim from the API, or a placeholder `{like-this}`).

This is a structural change to the skill's process, not a refinement of guidance — the audit must be code-level, not vibes-level. Without the mechanical scan, every sharpen run is one careless paraphrase away from re-introducing the same class of overfit. Also: when the user calls out an overfit, the agent should treat that as a signal to **audit every other recent sharpen edit for the same pattern**, not just patch the one the user pointed at — overfits travel in cohorts.
