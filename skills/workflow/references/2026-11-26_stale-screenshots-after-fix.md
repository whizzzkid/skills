---
class: principle
---

- **Rule** — Every screenshot a PR lists must show HEAD. After any commit that changes rendered output, re-run the
  single re-runnable capture script for every listed screenshot, overwrite the files, delete superseded captures, and
  never list a capture older than the last visual commit.
- **Why** — Screenshots were treated as one-time evidence from the first pass. A later visual fix retook only the
  overview shots, so the state captures (hover, post-click) still showed the pre-fix render. The reviewer opened them
  and saw the bug the PR claimed to fix; a prose note about staleness did not outweigh the image. A hand-picked
  re-shoot subset is how captures drift, so the capture sequence stays one script and a re-shoot is one call.
- **Where** — `SKILL.md` → Phase 3.6 (Frontend Live Preview), next to the measured-property bullet. Classified
  `partial`: Phase 5's post-push artifact sync audits PR title and body text, but nothing required regenerating the
  image artifacts the body links. Byte reclaim for the fold: the slow-build command list moved to
  `environment-guardrails.md` and the per-OS `pgrep` detail moved to `platform-api-traps.md` (c).
