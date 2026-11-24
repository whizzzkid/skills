---
skill: wk-retro
date: 2026-11-23
type: correction
severity: high
verified-against-source: yes
---

A hand-typed session number overwrote another session's undistilled retro file.

**What happened:** The agent counted the day's existing session files (2) but hard-coded `session-1` in the `cp`
instead of using the computed N. The copy silently replaced an untracked file another session had written. It was
recovered only by finding that session's transcript.

**Root cause:** The write step ran `cp` without a no-clobber guard. The computed N and the target path were not tied
together in one command.

**Suggested fix:** Make the write step `FILE=...; [ -e "$FILE" ] && exit 1; cp -n "$DRAFT" "$FILE"`, built only from
the computed N. Never hand-type the session number. A shared draft path is also a cross-session hazard, so suffix it
with a unique token.
