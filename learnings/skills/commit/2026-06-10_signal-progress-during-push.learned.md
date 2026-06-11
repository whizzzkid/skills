---
skill: wk-commit
date: 2026-06-10
type: gap
severity: medium
---

Signal intent before long-running git push + pre-push-hook sequences.

**What happened:** Agent emitted a single "pushing and creating draft PR" message, then ran `git push` with pre-push hooks that take ~30s. No further output until hooks finished. User interrupted asking "is this stuck?"

**Root cause:** No progress signal between stating intent and the long operation completing; silence reads as frozen.

**Suggested fix:** Before `git push`, emit a brief note that pre-push hooks are running and may take up to ~30s; follow up with the result summary so the user has a clear end-of-operation signal.
