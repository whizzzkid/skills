---
skill: wk-self-review
date: 2026-04-30
type: gap
severity: medium
---

Verify that code comments make claims that are actually true given the current implementation.

**What happened:** PR #NNN's `setup_env.sh` had a comment claiming the treeless fetch "makes `git merge-base` available inside the sandbox." The spec and other doc references also stated `git merge-base origin/${$TARGET_BRANCH} HEAD` works. However, the implementation uses `--depth 1 --filter=tree:0` for the base-branch fetch, which only fetches one commit object — `git merge-base` requires shared ancestry in the commit graph and is unreliable with this shallow fetch. Two separate bots caught this in two separate rounds.

**Root cause:** The comment was written when the design assumed a deeper fetch; when the implementation changed to `--depth 1`, the comments were not updated.

**Suggested fix:** During self-review, for every comment that makes a behavioral claim (especially about git, network, or OS operations), mentally execute the described scenario: does the actual code make that claim true? If the implementation changed since the comment was written, update the comment to match reality. Flag any comment that asserts something "always works" or "is guaranteed" — these are high-risk claims worth verifying.
