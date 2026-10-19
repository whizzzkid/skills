---
class: principle
---

# Push only to an approved destination

**Rule**

- Before any `git push`, resolve the workspace repo's `origin` owner and require it in the approved set:
  `.sitrep.yml` `push_owners:` (comma-separated), else `$GITHUB_ORG`. Fail closed — an empty set, no `origin`, a
  local-path remote, or any other owner sets `PUSH_ALLOWED=0`.
- `PUSH_ALLOWED=0` → still commit locally, skip every push for the run, name the unapproved owner, and tell the user
  to move the repo to an employer-managed org. Never add the current owner to the approved list on the user's behalf.
- Keep confidential figures (spend, cost, forecasts) out of the live page and snapshots; link the source system.

**Why**

- The page and snapshots aggregate work data (chat excerpts, ticket details, figures). An auto-push stage assumed the
  configured repo was an approved destination; its remote was a private repo under a personal account, so work data
  reached a personal destination. Repo visibility is not the criterion — ownership is.
- An "unconditional push" rule plus no destination check means one misconfigured remote leaks every run, silently.

**Guard check**

- Tightens, never relaxes: the commit stays unconditional (local work is unaffected); only egress is gated.

**Where**

`skills/sitrep/SKILL.md` → Core hard rules, Step 0, start Stage 6, end Stage 8; `references/bootstrap.md` → Verify push
destination.
