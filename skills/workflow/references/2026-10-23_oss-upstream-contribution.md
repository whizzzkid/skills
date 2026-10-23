---
class: principle
---

# Upstream OSS contribution etiquette

**Rule** — when the agent contributes to a public project the user does not own, the project's contributor guides
govern: read them before the first edit, follow every obligation they set, keep the maintainer-facing footprint
minimal, ship docs and website changes with the code, and tie the PR to an upstream issue (found, else filed after
local validation).

## Detection

- `gh repo view --json visibility,owner,isFork,parent` — `visibility == PUBLIC` and `owner.login` is neither the user
  nor `$GITHUB_ORG`. A fork → the upstream is `parent`; read guides and search issues there, not on the fork.
- The user's own public repos are not "upstream": the regular workflow applies.

## Guides to read (all that exist)

- `CONTRIBUTING*`, `DEVELOPMENT*`, `HACKING*`, `docs/contributing/`, `.github/CONTRIBUTING*`.
- `CODE_OF_CONDUCT*`, `SECURITY*` (security fixes may require private disclosure, not a public issue).
- `.github/ISSUE_TEMPLATE/`, `.github/PULL_REQUEST_TEMPLATE*`, `AGENTS.md` / `CLAUDE.md`, AI-contribution policy.
- Docs style guide and the website/docs-site README (build command, preview command).

## Obligations to extract

- Issue-first or discussion-first requirement; maintainer ack before a PR.
- Commit format, DCO `Signed-off-by:` or CLA — these are repo mandates, so `wk-commit`'s closed trailer set admits them.
- Changelog / release-note fragment, test and lint commands, supported toolchain versions.
- Branch naming, PR title convention, closing keyword.

## Low-noise rules

- One focused PR; no unrelated refactors, reformatting, or dependency bumps.
- No self-review inline comments, no progress-only comments, no repeated draft/ready toggles.
- Batch fix-ups locally; push rarely. Follow the PR template exactly.
- No internal names, ticket keys, company data, or internal URLs in public text.

## Upstream issue

- Search first: `gh issue list --repo <owner/repo> --search "<terms>" --state all` and the same for `gh pr list`.
  An open PR solving it → stop and ask; never open a competing PR.
- None found → after local implementation and validation pass, `gh issue create --repo <owner/repo>` using the
  matching template, labels, and title convention. Describe the problem (repro or motivation), not the patch.
- Link from the PR body with the project's closing keyword.

## Docs and website

- Update README, `docs/`, website/docs-site source, CLI help, examples, changelog the change affects.
- Build the site locally with its documented command; "website: N/A" only after confirming no site source covers it.
- Never bootstrap a new docs layout in someone else's project.

**Why** — maintainers judge drive-by contributions by how much triage they cost. Ignoring the project's own rules
(missing sign-off, wrong template, no issue, stale docs) or adding review-comment noise gets PRs closed and spends the
user's reputation.

**Where** — `SKILL.md` → Phase 2 (upstream OSS pre-flight, low noise), Phase 5 (upstream issue), Phase 7 (docs and
website), Checklist.
